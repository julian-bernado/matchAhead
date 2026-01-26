# R/reports.R
# Functions for generating intermediate .md reports for each pipeline stage

#' Ensure output directory exists
ensure_output_dir <- function(grade, subject) {
  dir_path <- file.path("outputs", paste0(grade, "_", subject))
  if (!dir.exists(dir_path)) {
    dir.create(dir_path, recursive = TRUE)
  }
  dir_path
}

# =============================================================================
# Stage 1: Data Preparation Report
# =============================================================================

#' Generate data preparation report
#'
#' @param cleaned_data Data frame from create_dataset()
#' @param grade Grade level
#' @param subject Subject name
#' @param year Year
#' @return Path to generated .md file
generate_data_prep_report <- function(cleaned_data, grade, subject, year) {
  output_dir <- ensure_output_dir(grade, subject)
  output_path <- file.path(output_dir, paste0("data_prep_", year, ".md"))

  outcome_var <- paste0(subject, "_scr_p0")

  # Compute statistics
  n_students <- nrow(cleaned_data)
  n_schools <- length(unique(cleaned_data$dstschid_state_enroll_p0))

  students_per_school <- table(cleaned_data$dstschid_state_enroll_p0)
  sps_mean <- mean(students_per_school)
  sps_sd <- sd(students_per_school)
  sps_min <- min(students_per_school)
  sps_max <- max(students_per_school)

  # Outcome distribution
  outcome <- cleaned_data[[outcome_var]]
  outcome_mean <- mean(outcome, na.rm = TRUE)
  outcome_sd <- sd(outcome, na.rm = TRUE)
  outcome_min <- min(outcome, na.rm = TRUE)
  outcome_max <- max(outcome, na.rm = TRUE)

  # Missing data rates
  missing_rates <- sapply(cleaned_data, function(x) mean(is.na(x)) * 100)
  missing_rates <- missing_rates[missing_rates > 0]

  # Covariate distributions
  age_mean <- mean(cleaned_data$age, na.rm = TRUE)
  age_sd <- sd(cleaned_data$age, na.rm = TRUE)
  attend_mean <- mean(cleaned_data$attend_p0, na.rm = TRUE)
  attend_sd <- sd(cleaned_data$attend_p0, na.rm = TRUE)

  # Categorical breakdowns
  gender_cols <- grep("^gender_", names(cleaned_data), value = TRUE)
  raceth_cols <- grep("^raceth_", names(cleaned_data), value = TRUE)

  # Build report
  lines <- c(
    paste0("# Data Preparation Report: Grade ", grade, ", ", subject, " (", year, ")"),
    "",
    "## Sample Size",
    "",
    "| Metric | Value |",
    "|--------|-------|",
    sprintf("| Total students | %d |", n_students),
    sprintf("| Total schools | %d |", n_schools),
    "",
    "## Students per School",
    "",
    "| Statistic | Value |",
    "|-----------|-------|",
    sprintf("| Mean | %.1f |", sps_mean),
    sprintf("| SD | %.1f |", sps_sd),
    sprintf("| Min | %d |", sps_min),
    sprintf("| Max | %d |", sps_max),
    "",
    sprintf("## Outcome Distribution (%s)", outcome_var),
    "",
    "| Statistic | Value |",
    "|-----------|-------|",
    sprintf("| Mean | %.4f |", outcome_mean),
    sprintf("| SD | %.4f |", outcome_sd),
    sprintf("| Min | %.4f |", outcome_min),
    sprintf("| Max | %.4f |", outcome_max),
    "",
    "## Covariate Distributions",
    "",
    "| Variable | Mean | SD |",
    "|----------|------|-----|",
    sprintf("| Age (scaled) | %.3f | %.3f |", age_mean, age_sd),
    sprintf("| Attendance | %.3f | %.3f |", attend_mean, attend_sd),
    ""
  )

  # Missing data section
  if (length(missing_rates) > 0) {
    lines <- c(lines,
      "## Missing Data Rates",
      "",
      "| Variable | Missing % |",
      "|----------|-----------|"
    )
    for (var in names(missing_rates)) {
      lines <- c(lines, sprintf("| %s | %.2f%% |", var, missing_rates[var]))
    }
    lines <- c(lines, "")
  } else {
    lines <- c(lines, "## Missing Data", "", "No missing data.", "")
  }

  # Gender breakdown
  lines <- c(lines, "## Gender Distribution", "", "| Category | N | % |", "|----------|---|---|")
  for (col in gender_cols) {
    n <- sum(cleaned_data[[col]] == 1, na.rm = TRUE)
    pct <- n / n_students * 100
    label <- gsub("gender_", "", col)
    lines <- c(lines, sprintf("| %s | %d | %.1f%% |", label, n, pct))
  }
  lines <- c(lines, "")

  # Race/ethnicity breakdown
  lines <- c(lines, "## Race/Ethnicity Distribution", "", "| Category | N | % |", "|----------|---|---|")
  for (col in raceth_cols) {
    n <- sum(cleaned_data[[col]] == 1, na.rm = TRUE)
    pct <- n / n_students * 100
    label <- gsub("raceth_", "", col)
    lines <- c(lines, sprintf("| %s | %d | %.1f%% |", label, n, pct))
  }
  lines <- c(lines, "")

  writeLines(lines, output_path)
  output_path
}

# =============================================================================
# Stage 2: Model Fitting Report
# =============================================================================

#' Generate model fitting report
#'
#' @param model lmer model object
#' @param grade Grade level
#' @param subject Subject name
#' @param time_sec Computation time in seconds
#' @return Path to generated .md file
generate_model_report <- function(model, grade, subject, time_sec = NULL) {
  output_dir <- ensure_output_dir(grade, subject)
  output_path <- file.path(output_dir, "model.md")

  # Extract model info
  model_formula <- as.character(formula(model))
  n_obs <- nobs(model)
  n_groups <- length(unique(model@frame$dstschid_state_enroll_p0))

  # Fixed effects
  fixed_ef <- summary(model)$coefficients

  # Random effects
  var_corr <- lme4::VarCorr(model)
  school_var <- as.numeric(var_corr$dstschid_state_enroll_p0)
  residual_var <- attr(var_corr, "sc")^2

  # ICC
  icc <- school_var / (school_var + residual_var)

  # Model fit
  aic_val <- AIC(model)
  bic_val <- BIC(model)
  loglik <- as.numeric(logLik(model))

  # Convergence
  converged <- is.null(model@optinfo$conv$lme4$messages)
  singular <- lme4::isSingular(model)

  # Build report
  lines <- c(
    paste0("# Model Report: Grade ", grade, ", ", subject),
    "",
    "## Model Formula",
    "",
    "```",
    paste0(model_formula[2], " ~ ", model_formula[3]),
    "```",
    "",
    "## Sample Size",
    "",
    "| Metric | Value |",
    "|--------|-------|",
    sprintf("| Students | %d |", n_obs),
    sprintf("| Schools | %d |", n_groups),
    "",
    "## Fixed Effects",
    "",
    "| Term | Estimate | SE | t-value |",
    "|------|----------|-----|---------|"
  )

  for (i in 1:nrow(fixed_ef)) {
    term <- rownames(fixed_ef)[i]
    est <- fixed_ef[i, "Estimate"]
    se <- fixed_ef[i, "Std. Error"]
    tval <- fixed_ef[i, "t value"]
    lines <- c(lines, sprintf("| %s | %.4f | %.4f | %.2f |", term, est, se, tval))
  }

  lines <- c(lines,
    "",
    "## Random Effects",
    "",
    "| Component | Variance | SD |",
    "|-----------|----------|-----|",
    sprintf("| School (Intercept) | %.6f | %.4f |", school_var, sqrt(school_var)),
    sprintf("| Residual | %.6f | %.4f |", residual_var, sqrt(residual_var)),
    "",
    sprintf("**ICC:** %.4f", icc),
    "",
    "## Model Fit",
    "",
    "| Metric | Value |",
    "|--------|-------|",
    sprintf("| AIC | %.2f |", aic_val),
    sprintf("| BIC | %.2f |", bic_val),
    sprintf("| Log-likelihood | %.2f |", loglik),
    "",
    "## Convergence",
    "",
    sprintf("- Converged: %s", ifelse(converged, "Yes", "No")),
    sprintf("- Singular fit: %s", ifelse(singular, "Yes", "No")),
    ""
  )

  if (!is.null(time_sec)) {
    lines <- c(lines, sprintf("**Computation time:** %.2f seconds", time_sec), "")
  }

  writeLines(lines, output_path)
  output_path
}

# =============================================================================
# Stage 3: Caliper Report
# =============================================================================

#' Generate caliper calculation report
#'
#' @param caliper Caliper value
#' @param model lmer model (for extracting SE and n)
#' @param grade Grade level
#' @param subject Subject name
#' @param time_sec Computation time in seconds
#' @return Path to generated .md file
generate_caliper_report <- function(caliper, model, grade, subject, time_sec = NULL) {
  output_dir <- ensure_output_dir(grade, subject)
  output_path <- file.path(output_dir, "caliper.md")

  # Compute SE and z-score
  n <- nobs(model)
  z_star <- sqrt(2 * log(2 * n))
  se <- caliper / z_star

  lines <- c(
    paste0("# Caliper Report: Grade ", grade, ", ", subject),
    "",
    "## Caliper Calculation",
    "",
    "| Parameter | Value |",
    "|-----------|-------|",
    sprintf("| Caliper | %.6f |", caliper),
    sprintf("| Standard Error | %.6f |", se),
    sprintf("| Bonferroni z-score | %.4f |", z_star),
    sprintf("| Sample size (n) | %d |", n),
    ""
  )

  if (!is.null(time_sec)) {
    lines <- c(lines, sprintf("**Computation time:** %.2f seconds", time_sec), "")
  }

  writeLines(lines, output_path)
  output_path
}

# =============================================================================
# Stage 4: Predictions Report
# =============================================================================

#' Generate predictions report
#'
#' @param student_preds Student-level predictions
#' @param school_preds School-level predictions
#' @param grade Grade level
#' @param subject Subject name
#' @param time_sec Computation time in seconds
#' @return Path to generated .md file
generate_predictions_report <- function(student_preds, school_preds, grade, subject, time_sec = NULL) {
  output_dir <- ensure_output_dir(grade, subject)
  output_path <- file.path(output_dir, "predictions.md")

  # Student-level stats
  s_scores <- student_preds$student_score
  s_mean <- mean(s_scores, na.rm = TRUE)
  s_sd <- sd(s_scores, na.rm = TRUE)
  s_min <- min(s_scores, na.rm = TRUE)
  s_max <- max(s_scores, na.rm = TRUE)
  s_q <- quantile(s_scores, probs = c(0.25, 0.5, 0.75), na.rm = TRUE)

  # By-school variance
  school_means <- tapply(s_scores, student_preds$school_id, mean, na.rm = TRUE)
  between_school_var <- var(school_means)
  within_school_var <- mean(tapply(s_scores, student_preds$school_id, var, na.rm = TRUE), na.rm = TRUE)

  # School-level stats
  sch_scores <- school_preds$school_score
  sch_mean <- mean(sch_scores, na.rm = TRUE)
  sch_sd <- sd(sch_scores, na.rm = TRUE)
  sch_min <- min(sch_scores, na.rm = TRUE)
  sch_max <- max(sch_scores, na.rm = TRUE)

  # School size correlation
  school_sizes <- table(student_preds$school_id)
  school_sizes_ordered <- school_sizes[as.character(school_preds$school_id)]
  size_cor <- cor(sch_scores, as.numeric(school_sizes_ordered), use = "complete.obs")

  # Top/bottom schools
  sorted_schools <- school_preds[order(school_preds$school_score, decreasing = TRUE), ]
  top_3 <- head(sorted_schools, 3)
  bottom_3 <- tail(sorted_schools, 3)

  lines <- c(
    paste0("# Predictions Report: Grade ", grade, ", ", subject),
    "",
    "## Student-Level Predictions",
    "",
    "| Statistic | Value |",
    "|-----------|-------|",
    sprintf("| N | %d |", length(s_scores)),
    sprintf("| Mean | %.4f |", s_mean),
    sprintf("| SD | %.4f |", s_sd),
    sprintf("| Min | %.4f |", s_min),
    sprintf("| Q1 | %.4f |", s_q[1]),
    sprintf("| Median | %.4f |", s_q[2]),
    sprintf("| Q3 | %.4f |", s_q[3]),
    sprintf("| Max | %.4f |", s_max),
    "",
    "### By-School Variance",
    "",
    "| Component | Variance |",
    "|-----------|----------|",
    sprintf("| Between-school | %.6f |", between_school_var),
    sprintf("| Within-school (mean) | %.6f |", within_school_var),
    "",
    "## School-Level Predictions",
    "",
    "| Statistic | Value |",
    "|-----------|-------|",
    sprintf("| N | %d |", length(sch_scores)),
    sprintf("| Mean | %.4f |", sch_mean),
    sprintf("| SD | %.4f |", sch_sd),
    sprintf("| Min | %.4f |", sch_min),
    sprintf("| Max | %.4f |", sch_max),
    "",
    sprintf("**Correlation with school size:** %.3f", size_cor),
    "",
    "### Top 3 Schools",
    "",
    "| School | Score |",
    "|--------|-------|"
  )

  for (i in 1:nrow(top_3)) {
    lines <- c(lines, sprintf("| %s | %.4f |", top_3$school_id[i], top_3$school_score[i]))
  }

  lines <- c(lines,
    "",
    "### Bottom 3 Schools",
    "",
    "| School | Score |",
    "|--------|-------|"
  )

  for (i in 1:nrow(bottom_3)) {
    lines <- c(lines, sprintf("| %s | %.4f |", bottom_3$school_id[i], bottom_3$school_score[i]))
  }

  lines <- c(lines, "")

  if (!is.null(time_sec)) {
    lines <- c(lines, sprintf("**Computation time:** %.2f seconds", time_sec), "")
  }

  writeLines(lines, output_path)
  output_path
}

# =============================================================================
# Stage 5: Treatment Assignment Report
# =============================================================================

#' Generate treatment assignment report
#'
#' @param treatment_assignment Treatment assignment data frame
#' @param cleaned_data Cleaned data for student counts
#' @param grade Grade level
#' @param subject Subject name
#' @return Path to generated .md file
generate_treatment_report <- function(treatment_assignment, cleaned_data, grade, subject) {
  output_dir <- ensure_output_dir(grade, subject)
  output_path <- file.path(output_dir, "treatment.md")

  n_treatment <- sum(treatment_assignment$treatment == 1)
  n_control <- sum(treatment_assignment$treatment == 0)
  n_total <- nrow(treatment_assignment)
  prop_treatment <- n_treatment / n_total

  # Student counts
  t_schools <- treatment_assignment$school_id[treatment_assignment$treatment == 1]
  c_schools <- treatment_assignment$school_id[treatment_assignment$treatment == 0]

  students_in_t <- sum(cleaned_data$dstschid_state_enroll_p0 %in% t_schools)
  students_in_c <- sum(cleaned_data$dstschid_state_enroll_p0 %in% c_schools)

  lines <- c(
    paste0("# Treatment Assignment Report: Grade ", grade, ", ", subject),
    "",
    "## School Assignment",
    "",
    "| Group | Schools | % |",
    "|-------|---------|---|",
    sprintf("| Treatment | %d | %.1f%% |", n_treatment, prop_treatment * 100),
    sprintf("| Control | %d | %.1f%% |", n_control, (1 - prop_treatment) * 100),
    sprintf("| **Total** | **%d** | |", n_total),
    "",
    "## Student Counts",
    "",
    "| Group | Students |",
    "|-------|----------|",
    sprintf("| Treatment schools | %d |", students_in_t),
    sprintf("| Control schools | %d |", students_in_c),
    sprintf("| **Total** | **%d** |", students_in_t + students_in_c),
    ""
  )

  writeLines(lines, output_path)
  output_path
}

# =============================================================================
# Stage 6: Distance Calculation Report
# =============================================================================

#' Generate distance calculation report
#'
#' @param dist_matchahead matchAhead distances
#' @param dist_pimentel Pimentel distances
#' @param grade Grade level
#' @param subject Subject name
#' @return Path to generated .md file
generate_distances_report <- function(dist_matchahead, dist_pimentel, grade, subject) {
  output_dir <- ensure_output_dir(grade, subject)
  output_path <- file.path(output_dir, "distances.md")

  # matchAhead stats
  ma_total <- nrow(dist_matchahead)
  ma_valid <- sum(is.finite(dist_matchahead$distance))
  ma_valid_pct <- ma_valid / ma_total * 100
  ma_dists <- dist_matchahead$distance[is.finite(dist_matchahead$distance)]
  ma_time_total <- sum(dist_matchahead$time_sec, na.rm = TRUE)
  ma_time_per_pair <- mean(dist_matchahead$time_sec, na.rm = TRUE)

  # Look types if available
  if ("look_type" %in% names(dist_matchahead)) {
    look_counts <- table(dist_matchahead$look_type)
  } else {
    look_counts <- NULL
  }

  # Pimentel stats
  pim_total <- nrow(dist_pimentel)
  pim_dists <- dist_pimentel$distance[is.finite(dist_pimentel$distance)]
  pim_time_total <- sum(dist_pimentel$time_sec, na.rm = TRUE)
  pim_time_per_pair <- mean(dist_pimentel$time_sec, na.rm = TRUE)

  # Comparison
  speedup <- pim_time_total / ma_time_total
  pairs_excluded_pct <- (ma_total - ma_valid) / ma_total * 100

  # Distance correlation (among pairs valid in both)
  merged <- merge(dist_matchahead, dist_pimentel, by = c("school_1", "school_2"), suffixes = c("_ma", "_pim"))
  valid_both <- merged[is.finite(merged$distance_ma) & is.finite(merged$distance_pim), ]
  if (nrow(valid_both) > 2) {
    dist_cor <- cor(valid_both$distance_ma, valid_both$distance_pim)
  } else {
    dist_cor <- NA
  }

  lines <- c(
    paste0("# Distance Calculation Report: Grade ", grade, ", ", subject),
    "",
    "## matchAhead",
    "",
    "| Metric | Value |",
    "|--------|-------|",
    sprintf("| Total pairs evaluated | %d |", ma_total),
    sprintf("| Valid pairs (finite distance) | %d (%.1f%%) |", ma_valid, ma_valid_pct),
    sprintf("| Distance mean | %.4f |", mean(ma_dists)),
    sprintf("| Distance SD | %.4f |", sd(ma_dists)),
    sprintf("| Distance median | %.4f |", median(ma_dists)),
    sprintf("| Distance Q1 | %.4f |", quantile(ma_dists, 0.25)),
    sprintf("| Distance Q3 | %.4f |", quantile(ma_dists, 0.75)),
    sprintf("| Total time | %.2f sec |", ma_time_total),
    sprintf("| Time per pair | %.4f sec |", ma_time_per_pair),
    ""
  )

  if (!is.null(look_counts)) {
    lines <- c(lines,
      "### Look Types",
      "",
      "| Type | Count |",
      "|------|-------|"
    )
    for (type in names(look_counts)) {
      lines <- c(lines, sprintf("| %s | %d |", type, look_counts[type]))
    }
    lines <- c(lines, "")
  }

  lines <- c(lines,
    "## Pimentel",
    "",
    "| Metric | Value |",
    "|--------|-------|",
    sprintf("| Total pairs evaluated | %d |", pim_total),
    sprintf("| Distance mean | %.4f |", mean(pim_dists)),
    sprintf("| Distance SD | %.4f |", sd(pim_dists)),
    sprintf("| Distance median | %.4f |", median(pim_dists)),
    sprintf("| Total time | %.2f sec |", pim_time_total),
    sprintf("| Time per pair | %.4f sec |", pim_time_per_pair),
    "",
    "## Comparison",
    "",
    "| Metric | Value |",
    "|--------|-------|",
    sprintf("| Pairs excluded by caliper | %.1f%% |", pairs_excluded_pct),
    sprintf("| Distance correlation | %.3f |", dist_cor),
    sprintf("| Speedup factor | %.1fx |", speedup),
    ""
  )

  writeLines(lines, output_path)
  output_path
}

# =============================================================================
# Stage 7: School Matching Report
# =============================================================================

#' Generate school matching report
#'
#' @param school_match_ma matchAhead school matches
#' @param school_match_pim Pimentel school matches
#' @param student_preds Student predictions (for student counts)
#' @param grade Grade level
#' @param subject Subject name
#' @return Path to generated .md file
generate_school_matching_report <- function(school_match_ma, school_match_pim, student_preds, grade, subject) {
  output_dir <- ensure_output_dir(grade, subject)
  output_path <- file.path(output_dir, "school_matching.md")

  # Helper to compute stats for one method
  compute_stats <- function(matches, label) {
    n_pairs <- nrow(matches)
    dists <- matches$distance

    # Count students in matched schools
    matched_schools <- unique(c(matches$treatment_school, matches$control_school))
    students_matched <- sum(student_preds$school_id %in% matched_schools)

    list(
      n_pairs = n_pairs,
      dist_mean = mean(dists, na.rm = TRUE),
      dist_sd = sd(dists, na.rm = TRUE),
      dist_min = min(dists, na.rm = TRUE),
      dist_max = max(dists, na.rm = TRUE),
      students = students_matched
    )
  }

  ma_stats <- compute_stats(school_match_ma, "matchAhead")
  pim_stats <- compute_stats(school_match_pim, "Pimentel")

  # Overlap analysis
  ma_pairs <- paste(school_match_ma$treatment_school, school_match_ma$control_school)
  pim_pairs <- paste(school_match_pim$treatment_school, school_match_pim$control_school)
  overlap <- sum(ma_pairs %in% pim_pairs)

  lines <- c(
    paste0("# School Matching Report: Grade ", grade, ", ", subject),
    "",
    "## matchAhead",
    "",
    "| Metric | Value |",
    "|--------|-------|",
    sprintf("| Pairs formed | %d |", ma_stats$n_pairs),
    sprintf("| Distance mean | %.4f |", ma_stats$dist_mean),
    sprintf("| Distance SD | %.4f |", ma_stats$dist_sd),
    sprintf("| Distance range | [%.4f, %.4f] |", ma_stats$dist_min, ma_stats$dist_max),
    sprintf("| Students in matched schools | %d |", ma_stats$students),
    "",
    "## Pimentel",
    "",
    "| Metric | Value |",
    "|--------|-------|",
    sprintf("| Pairs formed | %d |", pim_stats$n_pairs),
    sprintf("| Distance mean | %.4f |", pim_stats$dist_mean),
    sprintf("| Distance SD | %.4f |", pim_stats$dist_sd),
    sprintf("| Distance range | [%.4f, %.4f] |", pim_stats$dist_min, pim_stats$dist_max),
    sprintf("| Students in matched schools | %d |", pim_stats$students),
    "",
    "## Comparison",
    "",
    "| Metric | Value |",
    "|--------|-------|",
    sprintf("| Overlapping pairs | %d |", overlap),
    sprintf("| Mean distance difference | %.4f |", ma_stats$dist_mean - pim_stats$dist_mean),
    ""
  )

  writeLines(lines, output_path)
  output_path
}

# =============================================================================
# Stage 8: Student Matching Report
# =============================================================================

#' Generate student matching report
#'
#' @param student_match_ma matchAhead student matches
#' @param student_match_pim Pimentel student matches
#' @param student_preds Student predictions (for SMD calculation)
#' @param grade Grade level
#' @param subject Subject name
#' @return Path to generated .md file
generate_student_matching_report <- function(student_match_ma, student_match_pim, student_preds, grade, subject) {
  output_dir <- ensure_output_dir(grade, subject)
  output_path <- file.path(output_dir, "student_matching.md")

  # Helper to compute stats
  compute_stats <- function(matches) {
    n_total <- nrow(matches)
    n_treatment <- sum(matches$treatment == 1)
    n_control <- sum(matches$treatment == 0)
    n_blocks <- length(unique(matches$match_block))

    block_sizes <- table(matches$match_block)

    # Controls per treatment
    block_info <- aggregate(treatment ~ match_block, data = matches, FUN = function(x) c(sum(x), sum(1-x)))

    list(
      n_total = n_total,
      n_treatment = n_treatment,
      n_control = n_control,
      n_blocks = n_blocks,
      block_mean = mean(block_sizes),
      block_min = min(block_sizes),
      block_max = max(block_sizes)
    )
  }

  ma_stats <- compute_stats(student_match_ma)
  pim_stats <- compute_stats(student_match_pim)

  # SMD on prognostic score
  calc_smd <- function(matches) {
    merged <- merge(matches, student_preds, by.x = "study_id", by.y = "study_id")
    t_scores <- merged$student_score[merged$treatment == 1]
    c_scores <- merged$student_score[merged$treatment == 0]
    pooled_sd <- sqrt((var(t_scores) + var(c_scores)) / 2)
    (mean(t_scores) - mean(c_scores)) / pooled_sd
  }

  ma_smd <- calc_smd(student_match_ma)
  pim_smd <- calc_smd(student_match_pim)

  # Overlap
  ma_students <- unique(student_match_ma$study_id)
  pim_students <- unique(student_match_pim$study_id)
  both <- sum(ma_students %in% pim_students)
  ma_only <- sum(!ma_students %in% pim_students)
  pim_only <- sum(!pim_students %in% ma_students)

  lines <- c(
    paste0("# Student Matching Report: Grade ", grade, ", ", subject),
    "",
    "## matchAhead",
    "",
    "| Metric | Value |",
    "|--------|-------|",
    sprintf("| Total students matched | %d |", ma_stats$n_total),
    sprintf("| Treatment students | %d |", ma_stats$n_treatment),
    sprintf("| Control students | %d |", ma_stats$n_control),
    sprintf("| Match blocks | %d |", ma_stats$n_blocks),
    sprintf("| Block size (mean) | %.1f |", ma_stats$block_mean),
    sprintf("| Block size (range) | [%d, %d] |", ma_stats$block_min, ma_stats$block_max),
    sprintf("| SMD (prognostic score) | %.4f |", ma_smd),
    "",
    "## Pimentel",
    "",
    "| Metric | Value |",
    "|--------|-------|",
    sprintf("| Total students matched | %d |", pim_stats$n_total),
    sprintf("| Treatment students | %d |", pim_stats$n_treatment),
    sprintf("| Control students | %d |", pim_stats$n_control),
    sprintf("| Match blocks | %d |", pim_stats$n_blocks),
    sprintf("| Block size (mean) | %.1f |", pim_stats$block_mean),
    sprintf("| Block size (range) | [%d, %d] |", pim_stats$block_min, pim_stats$block_max),
    sprintf("| SMD (prognostic score) | %.4f |", pim_smd),
    "",
    "## Comparison",
    "",
    "| Metric | Value |",
    "|--------|-------|",
    sprintf("| Students in both | %d |", both),
    sprintf("| matchAhead only | %d |", ma_only),
    sprintf("| Pimentel only | %d |", pim_only),
    ""
  )

  writeLines(lines, output_path)
  output_path
}

# =============================================================================
# Stage 9: Treatment Effects Report
# =============================================================================

#' Generate treatment effects report
#'
#' @param effect_ma matchAhead treatment effect
#' @param effect_pim Pimentel treatment effect
#' @param grade Grade level
#' @param subject Subject name
#' @return Path to generated .md file
generate_effects_report <- function(effect_ma, effect_pim, grade, subject) {
  output_dir <- ensure_output_dir(grade, subject)
  output_path <- file.path(output_dir, "effects.md")

  # Helper to format effect
  format_effect <- function(eff) {
    ci_width <- eff$ci_upper - eff$ci_lower
    p_val <- 2 * (1 - pnorm(abs(eff$estimate / eff$se)))
    list(
      estimate = eff$estimate,
      se = eff$se,
      ci_lower = eff$ci_lower,
      ci_upper = eff$ci_upper,
      ci_width = ci_width,
      p_value = p_val,
      n_eff = eff$n_effective,
      n_clusters = eff$n_clusters
    )
  }

  ma <- format_effect(effect_ma)
  pim <- format_effect(effect_pim)

  # Comparison
  est_diff <- ma$estimate - pim$estimate
  ci_overlap <- min(ma$ci_upper, pim$ci_upper) - max(ma$ci_lower, pim$ci_lower)
  ci_overlap <- max(0, ci_overlap)
  rel_eff <- (pim$se / ma$se)^2

  lines <- c(
    paste0("# Treatment Effects Report: Grade ", grade, ", ", subject),
    "",
    "## matchAhead",
    "",
    "| Metric | Value |",
    "|--------|-------|",
    sprintf("| Point estimate | %.6f |", ma$estimate),
    sprintf("| Standard error | %.6f |", ma$se),
    sprintf("| 95%% CI | [%.6f, %.6f] |", ma$ci_lower, ma$ci_upper),
    sprintf("| CI width | %.6f |", ma$ci_width),
    sprintf("| p-value | %.4f |", ma$p_value),
    sprintf("| Effective N | %.1f |", ma$n_eff),
    sprintf("| Clusters (schools) | %d |", ma$n_clusters),
    "",
    "## Pimentel",
    "",
    "| Metric | Value |",
    "|--------|-------|",
    sprintf("| Point estimate | %.6f |", pim$estimate),
    sprintf("| Standard error | %.6f |", pim$se),
    sprintf("| 95%% CI | [%.6f, %.6f] |", pim$ci_lower, pim$ci_upper),
    sprintf("| CI width | %.6f |", pim$ci_width),
    sprintf("| p-value | %.4f |", pim$p_value),
    sprintf("| Effective N | %.1f |", pim$n_eff),
    sprintf("| Clusters (schools) | %d |", pim$n_clusters),
    "",
    "## Comparison",
    "",
    "| Metric | Value |",
    "|--------|-------|",
    sprintf("| Estimate difference | %.6f |", est_diff),
    sprintf("| CI overlap | %.6f |", ci_overlap),
    sprintf("| Relative efficiency | %.3f |", rel_eff),
    ""
  )

  writeLines(lines, output_path)
  output_path
}
