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

#' Generate complete comparison for a grade/subject combination
#'
#' @param matchahead_effect Treatment effect from matchAhead
#' @param pimentel_effect Treatment effect from Pimentel
#' @param matchahead_distances Distances from matchAhead
#' @param pimentel_distances Distances from Pimentel
#' @param grade Grade level
#' @param subject Subject name
#' @return List with all comparison results
generate_comparison <- function(matchahead_effect, pimentel_effect,
                                 matchahead_distances, pimentel_distances,
                                 grade, subject) {

  ci_comparison <- compare_confidence_intervals(matchahead_effect, pimentel_effect)
  time_comparison <- compare_computation_times(matchahead_distances, pimentel_distances)

  list(
    grade = grade,
    subject = subject,
    ci_comparison = ci_comparison,
    time_comparison = time_comparison,
    matchahead_effect = matchahead_effect,
    pimentel_effect = pimentel_effect
  )
}

#' Compile final report across all grade/subject combinations
#'
#' @param comparison_results List of comparison results from generate_comparison()
#' @param output_dir Output directory (default "outputs")
#' @return Path to the generated report file
compile_final_report <- function(comparison_results, output_dir = "outputs") {

  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  # Build summary table data
  summary_rows <- lapply(comparison_results, function(x) {
    # Get time comparison data
    time_df <- x$time_comparison
    ma_mean_time <- time_df$matchahead[time_df$metric == "mean_per_pair"]
    pim_mean_time <- time_df$pimentel[time_df$metric == "mean_per_pair"]
    time_ratio <- if (ma_mean_time > 0) pim_mean_time / ma_mean_time else NA_real_

    data.frame(
      grade = x$grade,
      subject = x$subject,
      ma_ci_lower = x$matchahead_effect$ci_lower,
      ma_ci_upper = x$matchahead_effect$ci_upper,
      pim_ci_lower = x$pimentel_effect$ci_lower,
      pim_ci_upper = x$pimentel_effect$ci_upper,
      relative_efficiency = x$ci_comparison$relative_efficiency,
      time_ratio = time_ratio,
      stringsAsFactors = FALSE
    )
  })
  summary_df <- do.call(rbind, summary_rows)

  # Create markdown report
  report_path <- file.path(output_dir, "comparison_report.md")

  lines <- c(
    "# matchAhead vs Pimentel Comparison Report",
    "",
    "## Summary Table",
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
    "## Column Definitions",
    "",
    "- **Grade**: Grade level (3, 4, or 5)",
    "- **Subject**: glmath or readng",
    "- **MA CI Lower/Upper**: matchAhead 95% confidence interval bounds",
    "- **Pim CI Lower/Upper**: Pimentel 95% confidence interval bounds",
    "- **Rel. Efficiency**: Relative efficiency = (Pimentel SE / matchAhead SE)^2",
    "- **Time Ratio**: avg_pim_time_per_pair / avg_ma_time_per_pair (speedup factor)",
    ""
  )

  writeLines(lines, report_path)
  cat("Report written to:", report_path, "\n")

  return(report_path)
}
