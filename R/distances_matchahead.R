# R/distances_matchahead.R
# matchAhead distance calculation with calipers

#' Calculate ESS and bias for a school pair using matchAhead method
#'
#' Implements the matchAhead algorithm with caliper constraints.
#'
#' @param school_1 ID of first school (treatment)
#' @param school_2 ID of second school (control)
#' @param student_scores data.table/data.frame with school_id, student_score
#' @param caliper Maximum allowed distance between matched students
#' @param u Maximum controls per treatment unit (default 5)
#' @return List with bias, ess, time_sec
calc_matchahead_ess_bias <- function(school_1, school_2, student_scores, caliper, u = 5) {
  t0 <- Sys.time()

  # Extract scores for both schools
  if (inherits(student_scores, "data.table")) {
    ts <- student_scores[school_id == school_1, student_score]
    cs <- student_scores[school_id == school_2, student_score]
  } else {
    ts <- student_scores$student_score[student_scores$school_id == school_1]
    cs <- student_scores$student_score[student_scores$school_id == school_2]
  }

  Nt <- length(ts)
  Nc <- length(cs)

  if (Nt == 0 || Nc == 0) {
    return(list(bias = Inf, ess = Inf, time_sec = as.numeric(difftime(Sys.time(), t0, units = "secs"))))
  }

  # Build calipered distance matrix
  distance_matrix <- calipered_dist_matrix(ts, cs, caliper)

  # Get pairs within calipers
  in_calipers <- which(!is.na(distance_matrix), arr.ind = TRUE)

  # Get e1: number of treatment units with at least one valid control
  e1 <- sum(rowSums(!is.na(distance_matrix)) > 0)

  if (e1 < Nt) {
    if (e1 == 0) {
      # No matches possible
      ess <- Inf
      bias <- Inf
    } else {
      # Blurry look: some treatment units cannot be matched
      t_star_idx <- rowSums(!is.na(distance_matrix)) > 0
      treat_mean <- mean(ts[t_star_idx])
      c_star_idx <- colSums(!is.na(distance_matrix)) > 0
      control_mean <- mean(cs[c_star_idx])
      ess <- Nt / e1
      bias <- abs(treat_mean - control_mean)
    }
  } else {
    # Get e2: max flow with 1 control per treatment
    mf <- max_controls(distance_matrix, max.controls = 1)
    e2 <- mf[["cost"]]

    if (e2 < Nt) {
      # Cloudy look: cannot match all treatment units 1:1
      match_flows <- mf[["flows"]][seq_len(in_calipers)]
      matched_indices <- in_calipers[match_flows == 1, , drop = FALSE]
      bias <- abs(sum(ts[matched_indices[, "row"]] - cs[matched_indices[, "col"]])) / e2
      ess <- 1 / e2
    } else {
      # Clear look: full matching with up to u controls per treatment
      mf_u <- max_controls(distance_matrix, max.controls = u)
      e3 <- mf_u[["cost"]]
      match_flows <- mf_u[["flows"]][1:nrow(in_calipers)]
      matched_indices <- in_calipers[match_flows == 1, , drop = FALSE]

      # Weight by number of matches per treatment
      counts <- as.vector(table(matched_indices[, "row"]))
      w <- 1 / counts

      sum_diff <- sum(ts[matched_indices[, "row"]] - cs[matched_indices[, "col"]])
      bias <- abs(sum(w) * sum_diff) / e3
      ess <- 1 / sum(2 * w / (1 + w))
    }
  }

  t_sec <- as.numeric(difftime(Sys.time(), t0, units = "secs"))

  list(bias = bias, ess = ess, time_sec = t_sec)
}

#' Compute matchAhead distances for treatment × control pairs
#'
#' @param student_predictions Data frame with school_id, study_id, student_score
#' @param treatment_assignment Data frame with school_id, treatment
#' @param caliper Caliper value
#' @param max_controls Maximum controls per treatment (default 5)
#' @param alpha Weight for bias in distance formula (default 0.5)
#' @param cores Number of parallel cores (default 1 for single-threaded)
#' @return Data frame with school_1, school_2, bias, ess, distance, time_sec
compute_matchahead_distances <- function(student_predictions,
                                          treatment_assignment,
                                          caliper,
                                          max_controls = 5,
                                          alpha = 0.5,
                                          cores = 1) {

  # Get treatment and control schools
  tc <- get_treatment_control_schools(treatment_assignment)

  # Generate all T×C pairs
  pairs_df <- expand.grid(
    school_1 = tc$treatment_schools,
    school_2 = tc$control_schools,
    stringsAsFactors = FALSE
  )

  # Convert student predictions to data.table for efficiency
  if (!inherits(student_predictions, "data.table")) {
    student_dt <- data.table::as.data.table(student_predictions)
  } else {
    student_dt <- student_predictions
  }

  n_pairs <- nrow(pairs_df)
  bias <- numeric(n_pairs)
  ess <- numeric(n_pairs)
  time_sec <- numeric(n_pairs)

  if (cores > 1) {
    # Parallel computation
    # Rename to avoid conflict with max_controls function
    u_max <- max_controls

    cl <- parallel::makeCluster(cores)
    # Export data from local environment
    parallel::clusterExport(cl, c("pairs_df", "student_dt", "caliper", "u_max"),
                            envir = environment())
    # Export functions from global environment
    parallel::clusterExport(cl, c("calc_matchahead_ess_bias", "calipered_dist_matrix",
                                   "max_controls", "generate_network"),
                            envir = globalenv())
    parallel::clusterEvalQ(cl, library(data.table))

    results <- parallel::parLapply(cl, 1:n_pairs, function(i) {
      calc_matchahead_ess_bias(
        pairs_df$school_1[i],
        pairs_df$school_2[i],
        student_dt,
        caliper,
        u_max
      )
    })

    parallel::stopCluster(cl)

    for (i in 1:n_pairs) {
      bias[i] <- results[[i]]$bias
      ess[i] <- results[[i]]$ess
      time_sec[i] <- results[[i]]$time_sec
    }
  } else {
    # Sequential computation
    for (i in 1:n_pairs) {
      result <- calc_matchahead_ess_bias(
        pairs_df$school_1[i],
        pairs_df$school_2[i],
        student_dt,
        caliper,
        max_controls
      )
      bias[i] <- result$bias
      ess[i] <- result$ess
      time_sec[i] <- result$time_sec
    }
  }

  # Combine distance as bias^alpha * ess^(1-alpha)
  distance <- bias^alpha * ess^(1 - alpha)

  result <- data.frame(
    school_1 = pairs_df$school_1,
    school_2 = pairs_df$school_2,
    bias = bias,
    ess = ess,
    distance = distance,
    time_sec = time_sec,
    stringsAsFactors = FALSE
  )

  return(result)
}
