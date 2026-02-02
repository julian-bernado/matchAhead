# R/distances_pimentel.R
# Pimentel benchmark distance calculation (no caliper)

#' Calculate Pimentel distance for a school pair
#'
#' Uses fullmatch without caliper constraints to find minimum-cost matching,
#' then computes bias and ESS measures.
#'
#' @param school_1 ID of first school (treatment)
#' @param school_2 ID of second school (control)
#' @param student_scores data.table/data.frame with school_id, student_score
#' @param u Maximum controls per treatment unit (default 5)
#' @return List with bias, ess, time_sec
calc_pimentel_distance <- function(school_1, school_2, student_scores, u = 5) {
  t0 <- Sys.time()

  # Extract scores for both schools
  if (inherits(student_scores, "data.table")) {
    t_idx <- student_scores$school_id == school_1
    c_idx <- student_scores$school_id == school_2
    ts <- student_scores$student_score[t_idx]
    cs <- student_scores$student_score[c_idx]
    t_ids <- if ("study_id" %in% names(student_scores)) student_scores$study_id[t_idx] else 1:sum(t_idx)
    c_ids <- if ("study_id" %in% names(student_scores)) student_scores$study_id[c_idx] else 1:sum(c_idx)
  } else {
    t_idx <- student_scores$school_id == school_1
    c_idx <- student_scores$school_id == school_2
    ts <- student_scores$student_score[t_idx]
    cs <- student_scores$student_score[c_idx]
    t_ids <- if ("study_id" %in% names(student_scores)) student_scores$study_id[t_idx] else 1:sum(t_idx)
    c_ids <- if ("study_id" %in% names(student_scores)) student_scores$study_id[c_idx] else 1:sum(c_idx)
  }

  Nt <- length(ts)
  Nc <- length(cs)

  if (Nt == 0 || Nc == 0) {
    return(list(bias = Inf, ess = Inf, time_sec = as.numeric(difftime(Sys.time(), t0, units = "secs"))))
  }

  # Build full distance matrix (no caliper - all pairs valid)
  dist_mat <- outer(ts, cs, function(x, y) abs(x - y))
  rownames(dist_mat) <- paste0("T_", seq_len(Nt))
  colnames(dist_mat) <- paste0("C_", seq_len(Nc))

  # Mean controls per treatment (for fullmatch)
  mean_controls <- floor(Nc / Nt)
  mean_controls <- max(1, min(mean_controls, u))

  # Use optmatch::fullmatch
  tryCatch({
    # Create treatment indicator
    z <- c(rep(1, Nt), rep(0, Nc))
    names(z) <- c(rownames(dist_mat), colnames(dist_mat))

    # Convert to optmatch distance structure
    dist_obj <- optmatch::match_on(dist_mat)

    # Run fullmatch
    fm <- optmatch::fullmatch(
      dist_obj,
      min.controls = 1,
      max.controls = u,
      mean.controls = mean_controls,
      data = NULL
    )

    # Parse matched pairs
    matched <- !is.na(fm)
    if (sum(matched) == 0) {
      return(list(bias = Inf, ess = Inf, time_sec = as.numeric(difftime(Sys.time(), t0, units = "secs"))))
    }

    # Get unique strata
    strata <- unique(fm[matched])

    total_weighted_diff <- 0
    total_weight <- 0
    ess_sum <- 0

    for (stratum in strata) {
      members <- names(fm)[fm == stratum & !is.na(fm)]
      t_members <- members[grepl("^T_", members)]
      c_members <- members[grepl("^C_", members)]

      n_t <- length(t_members)
      n_c <- length(c_members)

      if (n_t == 0 || n_c == 0) next

      # Get scores for this stratum
      t_scores <- ts[as.integer(sub("T_", "", t_members))]
      c_scores <- cs[as.integer(sub("C_", "", c_members))]

      # Weight for this block
      m_j <- n_c / n_t  # controls per treatment
      w_j <- 2 * m_j / (1 + m_j)

      # Contribution to bias (weighted absolute difference)
      stratum_diff <- abs(mean(t_scores) - mean(c_scores))
      total_weighted_diff <- total_weighted_diff + n_t * stratum_diff
      total_weight <- total_weight + n_t

      # Contribution to ESS
      ess_sum <- ess_sum + n_t * w_j
    }

    # Final measures
    if (total_weight > 0 && total_weighted_diff > 0) {
      bias <- total_weight / total_weighted_diff
    } else {
      bias <- Inf
    }

    if (ess_sum > 0) {
      ess <- 1 / ess_sum
    } else {
      ess <- Inf
    }

  }, error = function(e) {
    bias <<- Inf
    ess <<- Inf
  })

  t_sec <- as.numeric(difftime(Sys.time(), t0, units = "secs"))

  list(bias = bias, ess = ess, time_sec = t_sec)
}

#' Compute Pimentel distances for treatment × control pairs
#'
#' @param student_predictions Data frame with school_id, study_id, student_score
#' @param treatment_assignment Data frame with school_id, treatment
#' @param max_controls Maximum controls per treatment (default 5)
#' @param alpha Weight for bias in distance formula (default 0.5)
#' @param cores Number of parallel cores (default 1)
#' @return Data frame with school_1, school_2, bias, ess, distance, time_sec
compute_pimentel_distances <- function(student_predictions,
                                        treatment_assignment,
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

  # Convert to data.table for efficiency
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
    cl <- parallel::makeCluster(cores)
    parallel::clusterExport(cl, c("calc_pimentel_distance", "pairs_df",
                                   "student_dt", "max_controls"),
                            envir = environment())
    parallel::clusterEvalQ(cl, {
      library(data.table)
      library(optmatch)
    })

    results <- parallel::parLapply(cl, 1:n_pairs, function(i) {
      calc_pimentel_distance(
        pairs_df$school_1[i],
        pairs_df$school_2[i],
        student_dt,
        max_controls
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
      result <- calc_pimentel_distance(
        pairs_df$school_1[i],
        pairs_df$school_2[i],
        student_dt,
        max_controls
      )
      bias[i] <- result$bias
      ess[i] <- result$ess
      time_sec[i] <- result$time_sec
    }
  }

  # Combine distance as sqrt(bias^alpha * ess^(1-alpha))
  distance <- sqrt(bias^alpha * ess^(1 - alpha))

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
