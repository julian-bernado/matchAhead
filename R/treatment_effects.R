# R/treatment_effects.R
# Treatment effect estimation using propertee package

#' Merge student matches with outcome data
#'
#' @param student_matches Data frame from match_all_students()
#' @param outcome_data Cleaned data frame with study_id and outcome variable
#' @param subject Subject name to identify outcome column
#' @return Data frame with matches and outcomes merged
merge_outcomes <- function(student_matches, outcome_data, subject) {
  outcome_var <- paste0(subject, "_scr_p0")

  # Extract needed columns from outcome data
  outcome_df <- data.frame(
    study_id = as.character(outcome_data$study_id),
    outcome = outcome_data[[outcome_var]],
    stringsAsFactors = FALSE
  )

  # Merge
  merged <- merge(student_matches, outcome_df, by = "study_id", all.x = TRUE)

  merged
}

#' Add synthetic treatment effect to outcomes
#'
#' Adds a constant to the outcome of treated students for testing recovery.
#'
#' @param merged_data Data frame with 'outcome' and 'treatment' columns
#' @param effect_size Numeric constant to add to treated students' outcomes
#' @return Data frame with modified outcomes for treated students
add_synthetic_effect <- function(merged_data, effect_size = 0) {
  if (effect_size == 0) {
    return(merged_data)
  }

  treated_idx <- merged_data$treatment == 1
  merged_data$outcome[treated_idx] <- merged_data$outcome[treated_idx] + effect_size
  merged_data
}

#' Estimate treatment effect using propertee
#'
#' Uses lmitt with block structure and cluster-robust SEs at school level.
#'
#' @param matched_data Data frame with study_id, school_id, treatment, match_block, outcome
#' @return List with estimate, se, ci_lower, ci_upper, n_treatment, n_control
estimate_treatment_effect <- function(matched_data) {

  if (nrow(matched_data) == 0 || all(is.na(matched_data$outcome))) {
    return(list(
      estimate = NA_real_,
      se = NA_real_,
      ci_lower = NA_real_,
      ci_upper = NA_real_,
      n_treatment = 0,
      n_control = 0,
      n_blocks = 0,
      n_clusters = 0
    ))
  }

  # Remove rows with missing outcomes
  matched_data <- matched_data[!is.na(matched_data$outcome), ]

  n_treatment <- sum(matched_data$treatment == 1)
  n_control <- sum(matched_data$treatment == 0)
  n_blocks <- length(unique(matched_data$match_block))
  n_clusters <- length(unique(matched_data$school_id))

  if (n_treatment == 0 || n_control == 0) {
    return(list(
      estimate = NA_real_,
      se = NA_real_,
      ci_lower = NA_real_,
      ci_upper = NA_real_,
      n_treatment = n_treatment,
      n_control = n_control,
      n_blocks = n_blocks,
      n_clusters = n_clusters
    ))
  }

  tryCatch({
    # propertee uses NSE that looks in global env, so assign data there temporarily
    assign("._propertee_data_.", matched_data, envir = globalenv())
    on.exit(rm("._propertee_data_.", envir = globalenv()), add = TRUE)

    # Fit lmitt with student-level blocks and student as unit of assignment
    # absorb = TRUE includes block fixed effects
    # Load propertee functions into local scope for NSE formula parsing
    block <- propertee::block
    uoa <- propertee::uoa
    cluster <- propertee::cluster

    output <- propertee::lmitt(
      outcome ~ 1,
      data = ._propertee_data_.,
      specification = treatment ~ block(match_block) + uoa(study_id),
      absorb = TRUE
    )

    # Replace specification to get school-clustered SEs
    # (treatment was assigned at school level, not student level)
    # Use school_pair_id as block (school-level matching), not match_block (student-level)
    spec <- propertee::obs_spec(
      treatment ~ cluster(school_id) + block(school_pair_id),
      data = ._propertee_data_.
    )
    output@StudySpecification <- spec

    # Extract results - coefficient name is "treatment." (propertee convention)
    coef_summary <- summary(output)$coefficients
    estimate <- coef_summary["treatment.", "Estimate"]
    se <- coef_summary["treatment.", "Std. Error"]

    # 95% confidence interval
    ci_lower <- estimate - 1.96 * se
    ci_upper <- estimate + 1.96 * se

    list(
      estimate = estimate,
      se = se,
      ci_lower = ci_lower,
      ci_upper = ci_upper,
      n_treatment = n_treatment,
      n_control = n_control,
      n_blocks = n_blocks,
      n_clusters = n_clusters
    )

  }, error = function(e) {
    warning("propertee estimation failed: ", e$message)
    # Return NA results on error
    list(
      estimate = NA_real_,
      se = NA_real_,
      ci_lower = NA_real_,
      ci_upper = NA_real_,
      n_treatment = n_treatment,
      n_control = n_control,
      n_blocks = n_blocks,
      n_clusters = n_clusters
    )
  })
}

#' Estimate treatment effect with outcome data merge
#'
#' Convenience function that merges matches with outcomes and estimates effect.
#'
#' @param student_matches Data frame from match_all_students()
#' @param outcome_data Cleaned data frame with outcomes
#' @param subject Subject name
#' @param synthetic_effect Numeric constant to add to treated students' outcomes (default 0)
#' @return List with treatment effect estimates
estimate_treatment_effect_full <- function(student_matches, outcome_data, subject,
                                           synthetic_effect = 0) {
  merged <- merge_outcomes(student_matches, outcome_data, subject)
  merged <- add_synthetic_effect(merged, synthetic_effect)
  estimate_treatment_effect(merged)
}

#' Compare treatment effects between two methods
#'
#' @param matchahead_matches Student matches from matchAhead method
#' @param pimentel_matches Student matches from Pimentel method
#' @param outcome_data Cleaned outcome data
#' @param subject Subject name
#' @return Data frame comparing both methods
compare_treatment_effects <- function(matchahead_matches, pimentel_matches,
                                       outcome_data, subject) {

  ma_result <- estimate_treatment_effect_full(matchahead_matches, outcome_data, subject)
  pim_result <- estimate_treatment_effect_full(pimentel_matches, outcome_data, subject)

  data.frame(
    method = c("matchahead", "pimentel"),
    estimate = c(ma_result$estimate, pim_result$estimate),
    se = c(ma_result$se, pim_result$se),
    ci_lower = c(ma_result$ci_lower, pim_result$ci_lower),
    ci_upper = c(ma_result$ci_upper, pim_result$ci_upper),
    ci_width = c(ma_result$ci_upper - ma_result$ci_lower,
                 pim_result$ci_upper - pim_result$ci_lower),
    n_treatment = c(ma_result$n_treatment, pim_result$n_treatment),
    n_control = c(ma_result$n_control, pim_result$n_control),
    n_blocks = c(ma_result$n_blocks, pim_result$n_blocks),
    stringsAsFactors = FALSE
  )
}
