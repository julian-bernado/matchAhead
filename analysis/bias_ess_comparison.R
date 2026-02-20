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
    geom_abline(slope = 1, intercept = 0, linetype = "dashed",
                color = "gray50", linewidth = 0.6) +
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
      legend.position = "bottom",
      plot.subtitle   = element_text(size = 9, color = "gray40")
    )
}

if (nrow(agg_data) > 0) {
  p_bias <- make_parity_panel(
    agg_data,
    x_col       = "bias_pim",
    y_col       = "bias_ma",
    x_lab       = "Pimentel weighted bias",
    y_lab       = "matchAhead weighted bias",
    title       = "Weighted Bias",
    better_note = "Below diagonal: matchAhead lower bias"
  )

  p_ess <- make_parity_panel(
    agg_data,
    x_col       = "ess_pim",
    y_col       = "ess_ma",
    x_lab       = "Pimentel ESS",
    y_lab       = "matchAhead ESS",
    title       = "Effective Sample Size",
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

# ─── Section 3: Collect pair-level data ───────────────────────────────────────

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

    # Join on (school_1, school_2), pulling distance, bias, and ESS from both
    joined <- inner_join(
      ma_dist  |> select(school_1, school_2,
                         ma_dist = distance, ma_bias = bias, ma_ess = ess),
      pim_dist |> select(school_1, school_2,
                         pim_dist = distance, pim_bias = bias, pim_ess = ess),
      by = c("school_1", "school_2")
    )

    # Build set of matched pair keys for each method
    # school_1 = treatment school, school_2 = control school
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

# ─── Section 4: Helpers ───────────────────────────────────────────────────────

# Filter to finite values of x_col and y_col, add rank_x / rank_y columns.
prep_metric <- function(df, x_col, y_col) {
  df <- df |> filter(is.finite(.data[[x_col]]), is.finite(.data[[y_col]]))
  df$rank_x <- rank(df[[x_col]], ties.method = "average")
  df$rank_y <- rank(df[[y_col]], ties.method = "average")
  df
}

# Scatter plot for a pair-level metric (raw or rank columns).
make_scatter <- function(df, x_col, y_col, x_lab, y_lab, title,
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

  if (facet) p <- p + facet_wrap(~ label)

  p
}

# Save the 4 standard variants (raw/rank × all/matched) for one metric.
save_metric_plots <- function(df, x_col, y_col, x_lab, y_lab,
                               prefix, title_stem,
                               out_dir  = "plots",
                               facet    = TRUE,
                               pt_alpha = 0.4,
                               pt_size  = 1.0) {
  w <- if (facet) 14 else 7
  h <- if (facet) 8  else 6

  d <- prep_metric(df, x_col, y_col)
  m <- d |> filter(match_status != "Neither")

  ggsave(
    file.path(out_dir, paste0(prefix, "_raw_all_pairs.png")),
    make_scatter(d, x_col, y_col,
      x_lab = paste("matchAhead", x_lab), y_lab = paste("Pimentel", y_lab),
      title = paste0(title_stem, ": matchAhead vs Pimentel (all pairs)"),
      facet = facet, pt_alpha = pt_alpha, pt_size = pt_size),
    width = w, height = h, dpi = 150
  )

  if (nrow(m) > 0) {
    ggsave(
      file.path(out_dir, paste0(prefix, "_raw_matched_pairs.png")),
      make_scatter(m, x_col, y_col,
        x_lab = paste("matchAhead", x_lab), y_lab = paste("Pimentel", y_lab),
        title = paste0(title_stem, ": matchAhead vs Pimentel (matched pairs only)"),
        facet = facet, pt_alpha = pt_alpha, pt_size = pt_size),
      width = w, height = h, dpi = 150
    )
  }

  ggsave(
    file.path(out_dir, paste0(prefix, "_rank_all_pairs.png")),
    make_scatter(d, "rank_x", "rank_y",
      x_lab = paste0("Rank(matchAhead ", x_lab, ")"),
      y_lab = paste0("Rank(Pimentel ", y_lab, ")"),
      title = paste0(title_stem, " ranks: matchAhead vs Pimentel (all pairs)"),
      facet = facet, pt_alpha = pt_alpha, pt_size = pt_size),
    width = w, height = h, dpi = 150
  )

  if (nrow(m) > 0) {
    ggsave(
      file.path(out_dir, paste0(prefix, "_rank_matched_pairs.png")),
      make_scatter(m, "rank_x", "rank_y",
        x_lab = paste0("Rank(matchAhead ", x_lab, ")"),
        y_lab = paste0("Rank(Pimentel ", y_lab, ")"),
        title = paste0(title_stem, " ranks: matchAhead vs Pimentel (matched pairs only)"),
        facet = facet, pt_alpha = pt_alpha, pt_size = pt_size),
      width = w, height = h, dpi = 150
    )
  }

  message("Saved ", prefix, " plots to ", out_dir)
}

# ─── Section 5: Combined plots (all 6 grade/subjects, faceted) ─────────────────

if (nrow(pair_data) > 0) {
  save_metric_plots(pair_data, "ma_dist", "pim_dist", "distance", "distance",
                    prefix = "distance", title_stem = "School-pair distances")
  save_metric_plots(pair_data, "ma_bias", "pim_bias", "bias",     "bias",
                    prefix = "bias",     title_stem = "School-pair bias")
  save_metric_plots(pair_data, "ma_ess",  "pim_ess",  "ESS",      "ESS",
                    prefix = "ess",      title_stem = "School-pair ESS")
} else {
  message("No pair data available; skipping pair-level scatter plots")
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

  title_stem <- as.character(unique(df_combo$label))

  save_metric_plots(df_combo, "ma_dist", "pim_dist", "distance", "distance",
                    prefix = "distance", title_stem = title_stem,
                    out_dir = out_dir, facet = FALSE, pt_alpha = 0.5, pt_size = 1.2)
  save_metric_plots(df_combo, "ma_bias", "pim_bias", "bias",     "bias",
                    prefix = "bias",     title_stem = title_stem,
                    out_dir = out_dir, facet = FALSE, pt_alpha = 0.5, pt_size = 1.2)
  save_metric_plots(df_combo, "ma_ess",  "pim_ess",  "ESS",      "ESS",
                    prefix = "ess",      title_stem = title_stem,
                    out_dir = out_dir, facet = FALSE, pt_alpha = 0.5, pt_size = 1.2)
}

message("Done.")
