# analysis/bias_ess_comparison.R
# Compare matchAhead vs Pimentel at aggregate (bias/ESS) and pair-level distances

library(targets)
library(ggplot2)
library(dplyr)
library(patchwork)
library(ggrepel)

alpha_str <- "a05"

grade_subjects <- list(
  c("3", "glmath"), c("3", "readng"),
  c("4", "glmath"), c("4", "readng"),
  c("5", "glmath"), c("5", "readng")
)

subject_labels <- c(glmath = "Math", readng = "Reading")
label_order <- c(
  "Grade 3 Math", "Grade 4 Math", "Grade 5 Math",
  "Grade 3 Reading", "Grade 4 Reading", "Grade 5 Reading"
)
subject_colors <- c(glmath = "#2E86AB", readng = "#E9943F")
grade_shapes   <- c(`3` = 16L, `4` = 17L, `5` = 15L)
status_colors  <- c(
  "Both"     = "#2CA02C",
  "MA only"  = "#0047AB",
  "Pim only" = "#CC0000",
  "Neither"  = "gray80"
)

# Create output directories
dir.create("plots", showWarnings = FALSE)
dir.create("plots/per_combo", showWarnings = FALSE)
for (gs in grade_subjects) {
  dir.create(
    file.path("plots", "per_combo", paste0(gs[1], "_", gs[2])),
    showWarnings = FALSE
  )
}

# ─── Section 1: Collect aggregate data (comparison_* targets) ─────────────────

agg_data <- lapply(grade_subjects, function(gs) {
  grade   <- gs[1]
  subject <- gs[2]
  name    <- paste0("comparison_", grade, "_", subject, "_", alpha_str)

  tryCatch({
    comp <- tar_read_raw(name)
    data.frame(
      grade    = grade,
      subject  = subject,
      label    = paste0("G", grade, " ", subject_labels[subject]),
      bias_ma  = comp$matchahead_quality$weighted_bias,
      ess_ma   = comp$matchahead_quality$effective_sample_size,
      bias_pim = comp$pimentel_quality$weighted_bias,
      ess_pim  = comp$pimentel_quality$effective_sample_size,
      stringsAsFactors = FALSE
    )
  }, error = function(e) {
    message("Could not load ", name, ": ", e$message)
    NULL
  })
}) |> bind_rows()

# ─── Section 2: Plot 1 — bias_ess_comparison.png ──────────────────────────────

make_parity_panel <- function(df, x_col, y_col, x_lab, y_lab, title, better_note) {
  ggplot(df, aes(
    x     = .data[[x_col]],
    y     = .data[[y_col]],
    color = subject,
    shape = grade
  )) +
    geom_point(size = 3) +
    geom_text_repel(aes(label = label), size = 3.2, max.overlaps = 20) +
    scale_color_manual(values = subject_colors, labels = subject_labels) +
    scale_shape_manual(values = grade_shapes,
                       labels = paste("Grade", names(grade_shapes))) +
    labs(
      title    = title,
      subtitle = better_note,
      x        = x_lab,
      y        = y_lab,
      color    = "Subject",
      shape    = "Grade"
    ) +
    theme_minimal(base_size = 11) +
    theme(
      legend.position  = "bottom",
      plot.subtitle    = element_text(size = 9, color = "gray40")
    )
}

if (nrow(agg_data) > 0) {
  p_bias <- make_parity_panel(
    agg_data,
    x_col      = "bias_pim",
    y_col      = "bias_ma",
    x_lab      = "Pimentel weighted bias",
    y_lab      = "matchAhead weighted bias",
    title      = "Weighted Bias",
    better_note = "Below diagonal: matchAhead lower bias"
  )

  p_ess <- make_parity_panel(
    agg_data,
    x_col      = "ess_pim",
    y_col      = "ess_ma",
    x_lab      = "Pimentel ESS",
    y_lab      = "matchAhead ESS",
    title      = "Effective Sample Size",
    better_note = "Above diagonal: matchAhead higher ESS"
  )

  p_combined <- (p_bias + p_ess) +
    plot_layout(guides = "collect") &
    theme(legend.position = "bottom")

  ggsave("plots/bias_ess_comparison.png", p_combined,
         width = 12, height = 6, dpi = 150)
  message("Saved plots/bias_ess_comparison.png")
} else {
  message("No aggregate data available; skipping bias_ess_comparison.png")
}

# ─── Section 3: Collect pair-level distance data ───────────────────────────────

pair_data <- lapply(grade_subjects, function(gs) {
  grade   <- gs[1]
  subject <- gs[2]

  ma_name  <- paste0("dist_matchahead_", grade, "_", subject, "_", alpha_str)
  pim_name <- paste0("dist_pimentel_",   grade, "_", subject, "_", alpha_str)
  mma_name <- paste0("school_match_ma_", grade, "_", subject, "_", alpha_str)
  mpi_name <- paste0("school_match_pim_", grade, "_", subject, "_", alpha_str)

  tryCatch({
    ma_dist  <- tar_read_raw(ma_name)
    pim_dist <- tar_read_raw(pim_name)
    match_ma <- tar_read_raw(mma_name)
    match_pi <- tar_read_raw(mpi_name)

    # Join on (school_1, school_2)
    joined <- inner_join(
      ma_dist  |> select(school_1, school_2, ma_dist  = distance),
      pim_dist |> select(school_1, school_2, pim_dist = distance),
      by = c("school_1", "school_2")
    )

    # Drop pairs where either distance is Inf (calipered out)
    joined <- joined |> filter(is.finite(ma_dist), is.finite(pim_dist))

    # Build set of matched pair keys for each method
    # school_1 = treatment school, school_2 = control school (consistent with distances_to_matrix)
    ma_pairs  <- paste(match_ma$treatment_school, match_ma$control_school, sep = "__")
    pim_pairs <- paste(match_pi$treatment_school, match_pi$control_school, sep = "__")
    pair_keys <- paste(joined$school_1, joined$school_2, sep = "__")

    in_ma  <- pair_keys %in% ma_pairs
    in_pim <- pair_keys %in% pim_pairs

    joined$match_status <- dplyr::case_when(
      in_ma  &  in_pim ~ "Both",
      in_ma  & !in_pim ~ "MA only",
      !in_ma &  in_pim ~ "Pim only",
      TRUE             ~ "Neither"
    )
    joined$match_status <- factor(
      joined$match_status,
      levels = c("Both", "MA only", "Pim only", "Neither")
    )

    # Rank within this grade/subject
    joined$rank_ma  <- rank(joined$ma_dist,  ties.method = "average")
    joined$rank_pim <- rank(joined$pim_dist, ties.method = "average")

    joined$grade   <- grade
    joined$subject <- subject
    joined$label   <- paste0("Grade ", grade, " ", subject_labels[subject])

    joined
  }, error = function(e) {
    message("Could not load pair data for ", grade, "_", subject, ": ", e$message)
    NULL
  })
}) |> bind_rows()

pair_data$label <- factor(pair_data$label, levels = label_order)

# ─── Section 4: Distance scatter helper ───────────────────────────────────────

#' Make a distance scatter plot (raw or rank)
#'
#' @param df       data frame with x_col, y_col, match_status, label
#' @param x_col    column for x-axis (ma_dist or rank_ma)
#' @param y_col    column for y-axis (pim_dist or rank_pim)
#' @param x_lab    x-axis label
#' @param y_lab    y-axis label
#' @param title    plot title
#' @param facet    logical; add facet_wrap by label?
#' @param pt_alpha point transparency
#' @param pt_size  point size
make_distance_scatter <- function(df, x_col, y_col, x_lab, y_lab, title,
                                  facet = TRUE, pt_alpha = 0.4, pt_size = 1.0) {
  p <- ggplot(df, aes(
    x     = .data[[x_col]],
    y     = .data[[y_col]],
    color = match_status
  )) +
    geom_smooth(
      method      = "lm",
      se          = FALSE,
      color       = "black",
      linewidth   = 0.8,
      inherit.aes = FALSE,
      aes(x = .data[[x_col]], y = .data[[y_col]])
    ) +
    geom_point(alpha = pt_alpha, size = pt_size) +
    scale_color_manual(values = status_colors, drop = FALSE) +
    labs(title = title, x = x_lab, y = y_lab, color = "Match status") +
    theme_minimal(base_size = 11) +
    theme(legend.position = "bottom")

  if (facet) {
    p <- p + facet_wrap(~ label)
  }

  p
}

# ─── Section 5: Combined plots (all 6 grade/subjects, faceted) ─────────────────

if (nrow(pair_data) > 0) {

  matched_data <- pair_data |> filter(match_status != "Neither")

  # 5a. All pairs — raw distance
  ggsave(
    "plots/distance_raw_all_pairs.png",
    make_distance_scatter(
      pair_data, "ma_dist", "pim_dist",
      x_lab = "matchAhead distance",
      y_lab = "Pimentel distance",
      title = "School-pair distances: matchAhead vs Pimentel (all pairs)"
    ),
    width = 14, height = 8, dpi = 150
  )
  message("Saved plots/distance_raw_all_pairs.png")

  # 5b. Matched pairs only — raw distance
  ggsave(
    "plots/distance_raw_matched_pairs.png",
    make_distance_scatter(
      matched_data, "ma_dist", "pim_dist",
      x_lab = "matchAhead distance",
      y_lab = "Pimentel distance",
      title = "School-pair distances: matchAhead vs Pimentel (matched pairs only)"
    ),
    width = 14, height = 8, dpi = 150
  )
  message("Saved plots/distance_raw_matched_pairs.png")

  # 5c. All pairs — rank distance
  ggsave(
    "plots/distance_rank_all_pairs.png",
    make_distance_scatter(
      pair_data, "rank_ma", "rank_pim",
      x_lab = "Rank(matchAhead distance)",
      y_lab = "Rank(Pimentel distance)",
      title = "School-pair distance ranks: matchAhead vs Pimentel (all pairs)"
    ),
    width = 14, height = 8, dpi = 150
  )
  message("Saved plots/distance_rank_all_pairs.png")

  # 5d. Matched pairs only — rank distance
  ggsave(
    "plots/distance_rank_matched_pairs.png",
    make_distance_scatter(
      matched_data, "rank_ma", "rank_pim",
      x_lab = "Rank(matchAhead distance)",
      y_lab = "Rank(Pimentel distance)",
      title = "School-pair distance ranks: matchAhead vs Pimentel (matched pairs only)"
    ),
    width = 14, height = 8, dpi = 150
  )
  message("Saved plots/distance_rank_matched_pairs.png")

} else {
  message("No pair data available; skipping distance scatter plots")
}

# ─── Section 6: Per-combo plots (one directory per grade/subject) ──────────────

for (gs in grade_subjects) {
  grade_i   <- gs[1]
  subject_i <- gs[2]
  combo     <- paste0(grade_i, "_", subject_i)
  out_dir   <- file.path("plots", "per_combo", combo)

  df_combo <- pair_data |> filter(grade == grade_i, subject == subject_i)

  if (nrow(df_combo) == 0) {
    message("No data for ", combo, "; skipping per-combo plots")
    next
  }

  matched_combo <- df_combo |> filter(match_status != "Neither")
  combo_label   <- unique(df_combo$label)

  # raw — all pairs
  ggsave(
    file.path(out_dir, "distance_raw_all_pairs.png"),
    make_distance_scatter(
      df_combo, "ma_dist", "pim_dist",
      x_lab    = "matchAhead distance",
      y_lab    = "Pimentel distance",
      title    = paste0(combo_label, " \u2014 all pairs"),
      facet    = FALSE,
      pt_alpha = 0.5,
      pt_size  = 1.2
    ),
    width = 7, height = 6, dpi = 150
  )

  # raw — matched pairs
  if (nrow(matched_combo) > 0) {
    ggsave(
      file.path(out_dir, "distance_raw_matched_pairs.png"),
      make_distance_scatter(
        matched_combo, "ma_dist", "pim_dist",
        x_lab    = "matchAhead distance",
        y_lab    = "Pimentel distance",
        title    = paste0(combo_label, " \u2014 matched pairs only"),
        facet    = FALSE,
        pt_alpha = 0.5,
        pt_size  = 1.2
      ),
      width = 7, height = 6, dpi = 150
    )
  }

  # rank — all pairs
  ggsave(
    file.path(out_dir, "distance_rank_all_pairs.png"),
    make_distance_scatter(
      df_combo, "rank_ma", "rank_pim",
      x_lab    = "Rank(matchAhead distance)",
      y_lab    = "Rank(Pimentel distance)",
      title    = paste0(combo_label, " \u2014 all pairs (ranked)"),
      facet    = FALSE,
      pt_alpha = 0.5,
      pt_size  = 1.2
    ),
    width = 7, height = 6, dpi = 150
  )

  # rank — matched pairs
  if (nrow(matched_combo) > 0) {
    ggsave(
      file.path(out_dir, "distance_rank_matched_pairs.png"),
      make_distance_scatter(
        matched_combo, "rank_ma", "rank_pim",
        x_lab    = "Rank(matchAhead distance)",
        y_lab    = "Rank(Pimentel distance)",
        title    = paste0(combo_label, " \u2014 matched pairs only (ranked)"),
        facet    = FALSE,
        pt_alpha = 0.5,
        pt_size  = 1.2
      ),
      width = 7, height = 6, dpi = 150
    )
  }

  message("Saved per-combo plots for ", combo)
}

message("Done.")
