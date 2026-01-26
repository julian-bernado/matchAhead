# R/school_matching.R
# School-level optimal pair matching

#' Convert distance data frame to matrix format
#'
#' @param distances Data frame with school_1, school_2, distance columns
#' @param treatment_assignment Data frame with school_id, treatment
#' @return List with matrix and row/column names
distances_to_matrix <- function(distances, treatment_assignment) {
  tc <- get_treatment_control_schools(treatment_assignment)

  # Pivot to wide format
  dist_wide <- reshape(
    distances[, c("school_1", "school_2", "distance")],
    idvar = "school_1",
    timevar = "school_2",
    direction = "wide"
  )

  # Extract matrix
  row_names <- dist_wide$school_1
  dist_mat <- as.matrix(dist_wide[, -1])
  rownames(dist_mat) <- row_names

  # Clean column names (remove "distance." prefix)
  colnames(dist_mat) <- sub("^distance\\.", "", colnames(dist_mat))

  # Reorder to ensure treatment rows and control columns
  t_schools <- intersect(tc$treatment_schools, rownames(dist_mat))
  c_schools <- intersect(tc$control_schools, colnames(dist_mat))

  dist_mat <- dist_mat[t_schools, c_schools, drop = FALSE]

  list(
    matrix = dist_mat,
    treatment_schools = t_schools,
    control_schools = c_schools
  )
}

#' Perform optimal pair matching at school level
#'
#' Solves the assignment problem to minimize total distance.
#'
#' @param distances Data frame from compute_*_distances()
#' @param treatment_assignment Data frame from assign_treatment()
#' @param method Matching method: "pairmatch" (optmatch) or "hungarian" (lpSolve)
#' @return Data frame with treatment_school, control_school, distance
match_schools <- function(distances, treatment_assignment) {

  # Convert to matrix format
  dist_info <- distances_to_matrix(distances, treatment_assignment)
  dist_mat <- dist_info$matrix

  nt <- nrow(dist_mat)
  nc <- ncol(dist_mat)

  # Handle Inf distances - set to large finite value
  max_finite <- max(dist_mat[is.finite(dist_mat)], na.rm = TRUE)
  large_val <- max_finite * 1000
  dist_mat[!is.finite(dist_mat)] <- large_val

  # Use optmatch::pairmatch
  tryCatch({
    # Create treatment indicator
    z <- c(rep(1, nt), rep(0, nc))
    names(z) <- c(rownames(dist_mat), colnames(dist_mat))

    # Convert to optmatch distance
    dist_obj <- optmatch::match_on(dist_mat)

    # Run pairmatch (1:1 matching)
    pm <- optmatch::pairmatch(dist_obj, controls = 1, data = NULL)

    # Parse matched pairs
    matched <- !is.na(pm)
    strata <- unique(pm[matched])

    treatment_school <- character(length(strata))
    control_school <- character(length(strata))
    match_distance <- numeric(length(strata))

    for (i in seq_along(strata)) {
      members <- names(pm)[pm == strata[i] & !is.na(pm)]
      t_member <- members[members %in% rownames(dist_mat)]
      c_member <- members[members %in% colnames(dist_mat)]

      if (length(t_member) == 1 && length(c_member) == 1) {
        treatment_school[i] <- t_member
        control_school[i] <- c_member
        match_distance[i] <- dist_mat[t_member, c_member]
      }
    }})

    # Remove empty entries
    valid <- treatment_school != ""
    result <- data.frame(
      treatment_school = treatment_school[valid],
      control_school = control_school[valid],
      distance = match_distance[valid],
      stringsAsFactors = FALSE
    )


  result
}

#' Get summary of school matching results
#'
#' @param school_matches Data frame from match_schools()
#' @return List with summary statistics
summarize_school_matches <- function(school_matches) {
  list(
    n_pairs = nrow(school_matches),
    total_distance = sum(school_matches$distance),
    mean_distance = mean(school_matches$distance),
    median_distance = median(school_matches$distance),
    max_distance = max(school_matches$distance),
    min_distance = min(school_matches$distance)
  )
}
