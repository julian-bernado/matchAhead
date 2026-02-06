# R/treatment_assignment.R
# Functions for assigning treatment status to schools

#' Assign treatment status to schools
#'
#' Randomly assigns schools to treatment (1) or control (0) groups.
#' Default is 10% treatment, 90% control.
#'
#' @param school_ids Vector of unique school IDs
#' @param prop_treatment Proportion of schools assigned to treatment (default 0.10)
#' @param seed Random seed for reproducibility
#' @return Data frame with columns: school_id, treatment (0 or 1)
assign_treatment <- function(school_ids, prop_treatment = 0.10, seed = 2025) {
  set.seed(seed)

  n_schools <- length(school_ids)
  n_treatment <- round(n_schools * prop_treatment)

  # Ensure at least 1 treatment and 1 control if possible
  if (n_schools >= 2) {
    n_treatment <- max(1, min(n_treatment, n_schools - 1))
  }

  # Random assignment
  treatment_indices <- sample(1:n_schools, n_treatment)
  treatment <- rep(0L, n_schools)
  treatment[treatment_indices] <- 1L

  result <- data.frame(
    school_id = school_ids,
    treatment = treatment,
    stringsAsFactors = FALSE
  )

  return(result)
}

#' Assign treatment from cleaned data
#'
#' Extracts school IDs from cleaned data and assigns treatment randomly.
#'
#' @param cleaned_data Data frame from create_dataset() for the prediction year
#' @param prop_treatment Proportion of schools assigned to treatment (default 0.10)
#' @param seed Random seed for reproducibility
#' @return Data frame with school_id and treatment columns
assign_treatment_from_data <- function(cleaned_data, prop_treatment = 0.10, seed = 2025) {
  school_ids <- as.character(unique(cleaned_data$dstschid_state_enroll_p0))
  assign_treatment(school_ids, prop_treatment, seed)
}

#' Get treatment and control school IDs
#'
#' @param treatment_assignment Data frame from assign_treatment()
#' @return List with treatment_schools and control_schools vectors
get_treatment_control_schools <- function(treatment_assignment) {
  list(
    treatment_schools = treatment_assignment$school_id[treatment_assignment$treatment == 1],
    control_schools = treatment_assignment$school_id[treatment_assignment$treatment == 0]
  )
}

#' Filter pairs to only treatment × control combinations
#'
#' @param pairs_df Data frame with school_1 and school_2 columns
#' @param treatment_assignment Data frame from assign_treatment()
#' @return Filtered data frame with only T×C pairs (school_1 = treatment)
filter_treatment_control_pairs <- function(pairs_df, treatment_assignment) {
  tc <- get_treatment_control_schools(treatment_assignment)

  # Keep only pairs where school_1 is treatment and school_2 is control
  filtered <- pairs_df[
    pairs_df$school_1 %in% tc$treatment_schools &
    pairs_df$school_2 %in% tc$control_schools,
  ]

  return(filtered)
}
