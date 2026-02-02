# R/comparison.R
# Comparison metrics and final report generation

#' Compare confidence intervals between methods
#'
#' @param matchahead_effect Treatment effect results from matchAhead
#' @param pimentel_effect Treatment effect results from Pimentel
#' @return Data frame with CI comparison metrics
compare_confidence_intervals <- function(matchahead_effect, pimentel_effect) {

  # CI widths
  ma_width <- matchahead_effect$ci_upper - matchahead_effect$ci_lower
  pim_width <- pimentel_effect$ci_upper - pimentel_effect$ci_lower

  # CI overlap
  overlap_lower <- max(matchahead_effect$ci_lower, pimentel_effect$ci_lower)
  overlap_upper <- min(matchahead_effect$ci_upper, pimentel_effect$ci_upper)
  ci_overlap <- max(0, overlap_upper - overlap_lower)

  # Relative efficiency (ratio of variances)
  if (!is.na(matchahead_effect$se) && !is.na(pimentel_effect$se) &&
      pimentel_effect$se > 0) {
    relative_efficiency <- (pimentel_effect$se / matchahead_effect$se)^2
  } else {
    relative_efficiency <- NA_real_
  }

  # Estimate difference
  estimate_diff <- matchahead_effect$estimate - pimentel_effect$estimate

  data.frame(
    matchahead_estimate = matchahead_effect$estimate,
    pimentel_estimate = pimentel_effect$estimate,
    estimate_difference = estimate_diff,
    matchahead_se = matchahead_effect$se,
    pimentel_se = pimentel_effect$se,
    matchahead_ci_width = ma_width,
    pimentel_ci_width = pim_width,
    ci_width_ratio = if (pim_width > 0) ma_width / pim_width else NA_real_,
    ci_overlap = ci_overlap,
    relative_efficiency = relative_efficiency,
    stringsAsFactors = FALSE
  )
}

#' Compare computation times between methods
#'
#' @param matchahead_distances Distances data from matchAhead (with time_sec column)
#' @param pimentel_distances Distances data from Pimentel (with time_sec column)
#' @return Data frame with timing comparison
compare_computation_times <- function(matchahead_distances, pimentel_distances) {

  ma_times <- matchahead_distances$time_sec
  pim_times <- pimentel_distances$time_sec

  # Summary statistics
  ma_total <- sum(ma_times, na.rm = TRUE)
  pim_total <- sum(pim_times, na.rm = TRUE)

  ma_mean <- mean(ma_times, na.rm = TRUE)
  pim_mean <- mean(pim_times, na.rm = TRUE)

  ma_median <- median(ma_times, na.rm = TRUE)
  pim_median <- median(pim_times, na.rm = TRUE)

  # Speedup ratio (how much faster matchAhead is vs Pimentel)
  speedup_total <- if (ma_total > 0) pim_total / ma_total else NA_real_
  speedup_mean <- if (ma_mean > 0) pim_mean / ma_mean else NA_real_

  data.frame(
    metric = c("total_seconds", "mean_per_pair", "median_per_pair",
               "iqr_lower", "iqr_upper", "n_pairs"),
    matchahead = c(ma_total, ma_mean, ma_median,
                   quantile(ma_times, 0.25, na.rm = TRUE),
                   quantile(ma_times, 0.75, na.rm = TRUE),
                   length(ma_times)),
    pimentel = c(pim_total, pim_mean, pim_median,
                 quantile(pim_times, 0.25, na.rm = TRUE),
                 quantile(pim_times, 0.75, na.rm = TRUE),
                 length(pim_times)),
    speedup = c(speedup_total, speedup_mean, NA, NA, NA, NA),
    stringsAsFactors = FALSE
  )
}

#' Calculate weighted bias and effective sample size for a match
#'
#' @param matches Student matches data frame
#' @param preds Student predictions with student_score
#' @return List with weighted_bias and effective_sample_size
calc_match_quality <- function(matches, preds) {
  if (nrow(matches) == 0) {
    return(list(weighted_bias = NA_real_, effective_sample_size = NA_real_, n_treated = 0))
  }

  # Merge to get scores
  merged <- merge(matches, preds[, c("study_id", "student_score")], by = "study_id")
  if (nrow(merged) == 0) {
    return(list(weighted_bias = NA_real_, effective_sample_size = NA_real_, n_treated = 0))
  }

  treated <- merged[merged$treatment == 1, ]
  controls <- merged[merged$treatment == 0, ]

  if (nrow(treated) == 0 || nrow(controls) == 0) {
    return(list(weighted_bias = NA_real_, effective_sample_size = NA_real_, n_treated = 0))
  }

  # For each treated unit j, calculate bias and ESS terms
  bias_terms <- numeric(nrow(treated))
  ess_terms <- numeric(nrow(treated))

  for (i in seq_len(nrow(treated))) {
    j_block <- treated$match_block[i]
    j_score <- treated$student_score[i]

    # Controls in same block
    ctrl_scores <- controls$student_score[controls$match_block == j_block]
    m_j <- length(ctrl_scores)

    if (m_j > 0) {
      # Bias term: (1/m(j)) * sum(Y_j - Y_jk) = Y_j - mean(Y_jk)
      bias_terms[i] <- j_score - mean(ctrl_scores)
      # ESS term: 2*m(j) / (1 + m(j))
      ess_terms[i] <- (2 * m_j) / (1 + m_j)
    }
  }

  N_t <- nrow(treated)
  weighted_bias <- sum(bias_terms) / N_t
  ess <- sum(ess_terms)

  list(weighted_bias = weighted_bias, effective_sample_size = ess, n_treated = N_t)
}

#' Generate complete comparison for a grade/subject combination
#'
#' @param matchahead_effect Treatment effect from matchAhead
#' @param pimentel_effect Treatment effect from Pimentel
#' @param matchahead_distances Distances from matchAhead
#' @param pimentel_distances Distances from Pimentel
#' @param matchahead_matches Student matches from matchAhead
#' @param pimentel_matches Student matches from Pimentel
#' @param student_preds Student predictions
#' @param school_match_ma School matches from matchAhead
#' @param treatment_assignment Treatment assignment data frame
#' @param caliper_value Caliper value used
#' @param n_raw_schools_model_year Raw school count for model year
#' @param n_raw_schools_pred_year Raw school count for prediction year
#' @param n_schools_model_year School count for model year after filtering
#' @param grade Grade level
#' @param subject Subject name
#' @param config Configuration list with all parameters
#' @return List with all comparison results
generate_comparison <- function(matchahead_effect, pimentel_effect,
                                 matchahead_distances, pimentel_distances,
                                 matchahead_matches, pimentel_matches,
                                 student_preds,
                                 school_match_ma,
                                 treatment_assignment,
                                 caliper_value,
                                 n_raw_schools_model_year,
                                 n_raw_schools_pred_year,
                                 n_schools_model_year,
                                 grade, subject,
                                 config) {

  ci_comparison <- compare_confidence_intervals(matchahead_effect, pimentel_effect)
  time_comparison <- compare_computation_times(matchahead_distances, pimentel_distances)

  # Calculate match quality metrics
  ma_quality <- calc_match_quality(matchahead_matches, student_preds)
  pim_quality <- calc_match_quality(pimentel_matches, student_preds)

  # School counts from treatment assignment (pred_year only)
  n_treatment_schools_pred_year <- sum(treatment_assignment$treatment == 1)
  n_control_schools_pred_year <- sum(treatment_assignment$treatment == 0)

  # Matched school counts
  n_treatment_schools_matched <- length(unique(school_match_ma$treatment_school))
  n_control_schools_matched <- length(unique(school_match_ma$control_school))

  # Matched student counts
  n_treatment_students_matched <- sum(matchahead_matches$treatment == 1)
  n_control_students_matched <- sum(matchahead_matches$treatment == 0)

  # Calculate avg per match block
  n_blocks <- length(unique(matchahead_matches$match_block))
  if (n_blocks > 0) {
    block_stats <- aggregate(treatment ~ match_block, data = matchahead_matches,
                             FUN = function(x) c(n_t = sum(x), n_c = sum(1 - x)))
    avg_n_treatment_per_match <- mean(block_stats$treatment[, "n_t"])
    avg_n_control_per_match <- mean(block_stats$treatment[, "n_c"])
  } else {
    avg_n_treatment_per_match <- NA_real_
    avg_n_control_per_match <- NA_real_
  }

  list(
    grade = grade,
    subject = subject,
    config = config,
    caliper = caliper_value,
    n_raw_schools_model_year = n_raw_schools_model_year,
    n_raw_schools_pred_year = n_raw_schools_pred_year,
    n_schools_model_year = n_schools_model_year,
    n_treatment_schools_pred_year = n_treatment_schools_pred_year,
    n_control_schools_pred_year = n_control_schools_pred_year,
    n_treatment_schools_matched = n_treatment_schools_matched,
    n_control_schools_matched = n_control_schools_matched,
    n_treatment_students_matched = n_treatment_students_matched,
    n_control_students_matched = n_control_students_matched,
    avg_n_treatment_per_match = avg_n_treatment_per_match,
    avg_n_control_per_match = avg_n_control_per_match,
    ci_comparison = ci_comparison,
    time_comparison = time_comparison,
    matchahead_effect = matchahead_effect,
    pimentel_effect = pimentel_effect,
    matchahead_quality = ma_quality,
    pimentel_quality = pim_quality
  )
}

#' Compile final report across all grade/subject combinations
#'
#' Generates outputs.csv with append logic (only adds rows if input column
#' combination doesn't already exist) and a markdown summary report.
#'
#' @param comparison_results List of comparison results from generate_comparison()
#' @param output_dir Output directory (default "outputs")
#' @return Path to the generated CSV file
compile_final_report <- function(comparison_results, output_dir = "outputs") {

  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  csv_path <- file.path(output_dir, "outputs.csv")

  # Build rows for this run
  new_rows <- lapply(comparison_results, function(x) {
    cfg <- x$config

    # Get time comparison data
    time_df <- x$time_comparison
    ma_mean_time <- time_df$matchahead[time_df$metric == "mean_per_pair"]
    pim_mean_time <- time_df$pimentel[time_df$metric == "mean_per_pair"]
    time_ratio <- if (ma_mean_time > 0) pim_mean_time / ma_mean_time else NA_real_

    data.frame(
      # Input columns
      grade = x$grade,
      subject = x$subject,
      model_year = cfg$model_year,
      pred_year = cfg$pred_year,
      max_controls = cfg$max_controls,
      alpha = cfg$alpha,
      prop_treatment = cfg$prop_treatment,
      sample_prop = cfg$sample_prop,
      seed = cfg$seed,
      n_cores = cfg$cores,

      # Intermediate columns
      n_raw_schools_model_year = x$n_raw_schools_model_year,
      n_raw_schools_pred_year = x$n_raw_schools_pred_year,
      n_schools_model_year = x$n_schools_model_year,
      n_treatment_schools_pred_year = x$n_treatment_schools_pred_year,
      n_control_schools_pred_year = x$n_control_schools_pred_year,
      caliper = x$caliper,
      n_treatment_schools_matched = x$n_treatment_schools_matched,
      n_control_schools_matched = x$n_control_schools_matched,
      n_treatment_students_matched = x$n_treatment_students_matched,
      n_control_students_matched = x$n_control_students_matched,
      avg_n_treatment_per_match = x$avg_n_treatment_per_match,
      avg_n_control_per_match = x$avg_n_control_per_match,

      # Output columns
      ma_ci_lower = x$matchahead_effect$ci_lower,
      ma_ci_upper = x$matchahead_effect$ci_upper,
      ma_ci_contains_0 = x$matchahead_effect$ci_lower <= 0 & x$matchahead_effect$ci_upper >= 0,
      pim_ci_lower = x$pimentel_effect$ci_lower,
      pim_ci_upper = x$pimentel_effect$ci_upper,
      pim_ci_contains_0 = x$pimentel_effect$ci_lower <= 0 & x$pimentel_effect$ci_upper >= 0,
      relative_efficiency = x$ci_comparison$relative_efficiency,
      ma_avg_time_per_pair = ma_mean_time,
      pim_avg_time_per_pair = pim_mean_time,
      time_ratio = time_ratio,

      stringsAsFactors = FALSE
    )
  })

  new_df <- do.call(rbind, new_rows)

  # Define input columns for uniqueness check
  input_cols <- c("grade", "subject", "model_year", "pred_year", "max_controls",
                  "alpha", "prop_treatment", "sample_prop", "seed", "n_cores")

  # Check existing CSV and append only new combinations
  if (file.exists(csv_path)) {
    existing_df <- read.csv(csv_path, stringsAsFactors = FALSE)

    # Create key for comparison
    make_key <- function(df) {
      apply(df[, input_cols, drop = FALSE], 1, function(row) {
        paste(row, collapse = "|")
      })
    }

    existing_keys <- make_key(existing_df)
    new_keys <- make_key(new_df)

    # Filter to only truly new rows
    is_new <- !(new_keys %in% existing_keys)

    if (any(is_new)) {
      rows_to_add <- new_df[is_new, , drop = FALSE]
      final_df <- rbind(existing_df, rows_to_add)
      message(sprintf("Appending %d new rows to outputs.csv", sum(is_new)))
    } else {
      final_df <- existing_df
      message("All combinations already exist in outputs.csv - no rows added")
    }
  } else {
    final_df <- new_df
    message(sprintf("Creating outputs.csv with %d rows", nrow(new_df)))
  }

  # Write CSV
  write.csv(final_df, csv_path, row.names = FALSE)

  # Also generate markdown report
  report_path <- file.path(output_dir, "comparison_report.md")
  generate_markdown_report(new_df, report_path)

  return(csv_path)
}

#' Generate markdown summary report
#'
#' @param summary_df Data frame with comparison results
#' @param report_path Path to write the report
generate_markdown_report <- function(summary_df, report_path) {

  lines <- c(
    "# matchAhead vs Pimentel Comparison Report",
    "",
    "## Treatment Effect Estimates",
    "",
    "| Grade | Subject | MA CI Lower | MA CI Upper | Pim CI Lower | Pim CI Upper | Rel. Efficiency | Time Ratio |",
    "|-------|---------|-------------|-------------|--------------|--------------|-----------------|------------|"
  )

  for (i in seq_len(nrow(summary_df))) {
    row <- summary_df[i, ]
    lines <- c(lines, sprintf(
      "| %s | %s | %.4f | %.4f | %.4f | %.4f | %.3f | %.2f |",
      row$grade,
      row$subject,
      row$ma_ci_lower,
      row$ma_ci_upper,
      row$pim_ci_lower,
      row$pim_ci_upper,
      row$relative_efficiency,
      row$time_ratio
    ))
  }

  lines <- c(lines,
    "",
    "## Configuration",
    "",
    sprintf("- **Model Year**: %s", summary_df$model_year[1]),
    sprintf("- **Prediction Year**: %s", summary_df$pred_year[1]),
    sprintf("- **Max Controls**: %d", summary_df$max_controls[1]),
    sprintf("- **Alpha**: %.2f", summary_df$alpha[1]),
    sprintf("- **Prop Treatment**: %.2f", summary_df$prop_treatment[1]),
    sprintf("- **Sample Prop**: %.2f", summary_df$sample_prop[1]),
    sprintf("- **Seed**: %d", summary_df$seed[1]),
    sprintf("- **N Cores**: %d", summary_df$n_cores[1]),
    "",
    "## Column Definitions",
    "",
    "### Treatment Effect Estimates",
    "- **Grade**: Grade level (3, 4, or 5)",
    "- **Subject**: glmath or readng",
    "- **MA CI Lower/Upper**: matchAhead 95% confidence interval bounds",
    "- **Pim CI Lower/Upper**: Pimentel 95% confidence interval bounds",
    "- **Rel. Efficiency**: Relative efficiency = (Pimentel SE / matchAhead SE)^2",
    "- **Time Ratio**: pim_avg_time_per_pair / ma_avg_time_per_pair (speedup factor)",
    ""
  )

  writeLines(lines, report_path)
  cat("Report written to:", report_path, "\n")
}
