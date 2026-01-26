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

  # Combine CI comparisons
  ci_rows <- lapply(comparison_results, function(x) {
    cbind(grade = x$grade, subject = x$subject, x$ci_comparison)
  })
  ci_summary <- do.call(rbind, ci_rows)

  # Combine time comparisons (pivot to wide)
  time_summaries <- lapply(comparison_results, function(x) {
    df <- x$time_comparison
    df$grade <- x$grade
    df$subject <- x$subject
    df
  })
  time_summary <- do.call(rbind, time_summaries)

  # Write CSV files
  ci_path <- file.path(output_dir, "ci_comparison.csv")
  time_path <- file.path(output_dir, "time_comparison.csv")

  write.csv(ci_summary, ci_path, row.names = FALSE)
  write.csv(time_summary, time_path, row.names = FALSE)

  # Create summary text report
  report_path <- file.path(output_dir, "comparison_report.txt")

  sink(report_path)
  cat("matchAhead vs Pimentel Comparison Report\n")
  cat("=========================================\n\n")

  cat("CONFIDENCE INTERVAL COMPARISON\n")
  cat("------------------------------\n")
  print(ci_summary)
  cat("\n")

  cat("COMPUTATION TIME COMPARISON\n")
  cat("---------------------------\n")
  # Print time summary pivot
  time_wide <- reshape(
    time_summary[time_summary$metric %in% c("total_seconds", "mean_per_pair"), ],
    idvar = c("grade", "subject"),
    timevar = "metric",
    direction = "wide"
  )
  print(time_wide)
  cat("\n")

  sink()

  cat("Report written to:", report_path, "\n")

  return(report_path)
}
