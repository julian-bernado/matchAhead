# _targets.R
# matchAhead pipeline orchestration using targets
#
# EXECUTION ORDER: Deep (one grade/subject/alpha at a time)
#
# Run with: targets::tar_make()
# Visualize with: targets::tar_visnetwork()

library(targets)
library(tarchetypes)

# Set packages to load in each target
tar_option_set(packages = c("propertee"))

# Source all R functions
tar_source("R/")

# Number of cores for parallel processing (evaluated once at pipeline definition)
n_cores <- 14

# Alpha values to sweep (single value or sequence)
alphas <- 0.5
# alphas <- seq(0.1, 0.9, by = 0.1)  # full sweep

# Base configuration (alpha is set per-chain)
base_config <- list(
  grades = c("3", "4", "5"),
  subjects = c("glmath", "readng"),
  model_year = "2019",
  pred_year = "2022",
  max_controls = 5,
  prop_treatment = 0.03,
  sample_prop = 1.0,
  seed = 2026,
  cores = n_cores,
  synthetic_effect = 0.0
)

# identity function that creates dependency without using the value
wait_for <- function(data, gate = NULL) {
  data
}

# Factory function to generate all targets for one grade/subject/alpha chain
make_chain <- function(grade, subject, alpha, gate = NULL, base_config) {
  # Create config with this alpha value
  config <- c(base_config, list(alpha = alpha))

  # Suffix includes alpha (e.g., "3_glmath_a05" for alpha=0.5)
  alpha_str <- sprintf("a%02d", round(alpha * 10))
  s <- paste0(grade, "_", subject, "_", alpha_str)

  # Suffix without alpha for shared targets (data, model, etc.)
  s_shared <- paste0(grade, "_", subject)

  # Extract years from config for use in target names
  pred_year <- config$pred_year

  # Helper to create symbol from name
  sym <- function(name) as.symbol(name)

  # Build gated command - wraps in wait_for() if gate provided
  gated_cmd <- function(cmd, gate) {
    if (is.null(gate)) cmd
    else substitute(wait_for(cmd, gate), list(cmd = cmd, gate = sym(gate)))
  }

  list(
    # Raw school counts (before any filtering/sampling)
    tar_target_raw(
      paste0("raw_school_count_", s, "_model"),
      gated_cmd(
        substitute(count_raw_schools(g, yr),
                   list(g = grade, yr = config$model_year)),
        gate
      )
    ),
    tar_target_raw(
      paste0("raw_school_count_", s, "_pred"),
      gated_cmd(
        substitute(count_raw_schools(g, yr),
                   list(g = grade, yr = config$pred_year)),
        gate
      )
    ),
    tar_target_raw(
      paste0("cleaned_data_", s, "_2019"),
      gated_cmd(
        substitute(create_dataset(g, subj, "2019", sample_prop = sp, seed = sd),
                   list(g = grade, subj = subject, sp = config$sample_prop, sd = config$seed)),
        gate
      ),
      format = "rds"
    ),
    tar_target_raw(
      paste0("report_data_prep_", s, "_2019"),
      substitute(generate_data_prep_report(data, g, subj, "2019"),
                 list(data = sym(paste0("cleaned_data_", s, "_2019")), g = grade, subj = subject)),
      format = "file"
    ),
    tar_target_raw(
      paste0("cleaned_data_", s, "_", pred_year),
      gated_cmd(
        substitute(create_dataset(g, subj, yr, sample_prop = sp, seed = sd),
                   list(g = grade, subj = subject, yr = pred_year, sp = config$sample_prop, sd = config$seed)),
        gate
      ),
      format = "rds"
    ),
    tar_target_raw(
      paste0("report_data_prep_", s, "_", pred_year),
      substitute(generate_data_prep_report(data, g, subj, yr),
                 list(data = sym(paste0("cleaned_data_", s, "_", pred_year)), g = grade, subj = subject, yr = pred_year)),
      format = "file"
    ),
    tar_target_raw(
      paste0("model_", s),
      substitute(fit_prognostic_model(data, g, subj),
                 list(data = sym(paste0("cleaned_data_", s, "_2019")), g = grade, subj = subject)),
      format = "rds"
    ),
    tar_target_raw(
      paste0("report_model_", s),
      substitute(generate_model_report(model, g, subj),
                 list(model = sym(paste0("model_", s)), g = grade, subj = subject)),
      format = "file"
    ),
    tar_target_raw(
      paste0("caliper_", s),
      substitute(calculate_caliper(model), list(model = sym(paste0("model_", s))))
    ),
    tar_target_raw(
      paste0("report_caliper_", s),
      substitute(generate_caliper_report(caliper, model, g, subj),
                 list(caliper = sym(paste0("caliper_", s)), model = sym(paste0("model_", s)),
                      g = grade, subj = subject)),
      format = "file"
    ),
    tar_target_raw(
      paste0("student_preds_", s),
      substitute(make_student_predictions(model, data, subj),
                 list(model = sym(paste0("model_", s)), data = sym(paste0("cleaned_data_", s, "_", pred_year)),
                      subj = subject)),
      format = "rds"
    ),
    tar_target_raw(
      paste0("school_preds_", s),
      substitute(make_school_predictions(model, data),
                 list(model = sym(paste0("model_", s)), data = sym(paste0("cleaned_data_", s, "_", pred_year))))
    ),
    tar_target_raw(
      paste0("report_predictions_", s),
      substitute(generate_predictions_report(spreds, schpreds, g, subj),
                 list(spreds = sym(paste0("student_preds_", s)), schpreds = sym(paste0("school_preds_", s)),
                      g = grade, subj = subject)),
      format = "file"
    ),
    tar_target_raw(
      paste0("treatment_", s),
      substitute(assign_treatment_from_data(data, prop_trt, sd),
                 list(data = sym(paste0("cleaned_data_", s, "_", pred_year)),
                      prop_trt = config$prop_treatment, sd = config$seed))
    ),
    tar_target_raw(
      paste0("report_treatment_", s),
      substitute(generate_treatment_report(trt, data, g, subj),
                 list(trt = sym(paste0("treatment_", s)), data = sym(paste0("cleaned_data_", s, "_", pred_year)),
                      g = grade, subj = subject)),
      format = "file"
    ),
    tar_target_raw(
      paste0("dist_matchahead_", s),
      substitute(compute_matchahead_distances(preds, trt, caliper, max_ctrl, alpha = alph, cores = ncores),
                 list(preds = sym(paste0("student_preds_", s)), trt = sym(paste0("treatment_", s)),
                      caliper = sym(paste0("caliper_", s)),
                      max_ctrl = config$max_controls, alph = config$alpha, ncores = config$cores)),
      format = "rds"
    ),
    tar_target_raw(
      paste0("dist_pimentel_", s),
      substitute(compute_pimentel_distances(preds, trt, max_ctrl, alpha = alph, cores = ncores),
                 list(preds = sym(paste0("student_preds_", s)), trt = sym(paste0("treatment_", s)),
                      max_ctrl = config$max_controls, alph = config$alpha, ncores = config$cores)),
      format = "rds"
    ),
    tar_target_raw(
      paste0("report_distances_", s),
      substitute(generate_distances_report(dma, dpim, g, subj),
                 list(dma = sym(paste0("dist_matchahead_", s)), dpim = sym(paste0("dist_pimentel_", s)),
                      g = grade, subj = subject)),
      format = "file"
    ),
    tar_target_raw(
      paste0("school_match_ma_", s),
      substitute(match_schools(dist, trt),
                 list(dist = sym(paste0("dist_matchahead_", s)), trt = sym(paste0("treatment_", s))))
    ),
    tar_target_raw(
      paste0("school_match_pim_", s),
      substitute(match_schools(dist, trt),
                 list(dist = sym(paste0("dist_pimentel_", s)), trt = sym(paste0("treatment_", s))))
    ),
    tar_target_raw(
      paste0("report_school_matching_", s),
      substitute(generate_school_matching_report(ma, pim, preds, g, subj),
                 list(ma = sym(paste0("school_match_ma_", s)), pim = sym(paste0("school_match_pim_", s)),
                      preds = sym(paste0("student_preds_", s)), g = grade, subj = subject)),
      format = "file"
    ),
    tar_target_raw(
      paste0("student_match_ma_", s),
      substitute(match_all_students(smatch, preds, max_ctrl, caliper),
                 list(smatch = sym(paste0("school_match_ma_", s)), preds = sym(paste0("student_preds_", s)),
                      caliper = sym(paste0("caliper_", s)), max_ctrl = config$max_controls)),
      format = "rds"
    ),
    tar_target_raw(
      paste0("student_match_pim_", s),
      substitute(match_all_students(smatch, preds, max_ctrl),
                 list(smatch = sym(paste0("school_match_pim_", s)), preds = sym(paste0("student_preds_", s)),
                      max_ctrl = config$max_controls)),
      format = "rds"
    ),
    tar_target_raw(
      paste0("report_student_matching_", s),
      substitute(generate_student_matching_report(ma, pim, preds, g, subj),
                 list(ma = sym(paste0("student_match_ma_", s)), pim = sym(paste0("student_match_pim_", s)),
                      preds = sym(paste0("student_preds_", s)), g = grade, subj = subject)),
      format = "file"
    ),
    tar_target_raw(
      paste0("effect_ma_", s),
      substitute(estimate_treatment_effect_full(match, data, subj, se),
                 list(match = sym(paste0("student_match_ma_", s)), data = sym(paste0("cleaned_data_", s, "_2022")),
                      subj = subject, se = config$synthetic_effect))
    ),
    tar_target_raw(
      paste0("effect_pim_", s),
      substitute(estimate_treatment_effect_full(match, data, subj, se),
                 list(match = sym(paste0("student_match_pim_", s)), data = sym(paste0("cleaned_data_", s, "_2022")),
                      subj = subject, se = config$synthetic_effect))
    ),
    tar_target_raw(
      paste0("report_effects_", s),
      substitute(generate_effects_report(ema, epim, g, subj),
                 list(ema = sym(paste0("effect_ma_", s)), epim = sym(paste0("effect_pim_", s)),
                      g = grade, subj = subject)),
      format = "file"
    ),
    tar_target_raw(
      paste0("n_schools_model_year_", s),
      substitute(length(unique(data$dstschid_state_enroll_p0)),
                 list(data = sym(paste0("cleaned_data_", s, "_2019"))))
    ),
    tar_target_raw(
      paste0("comparison_", s),
      substitute(generate_comparison(
        matchahead_effect = ema,
        pimentel_effect = epim,
        matchahead_distances = dma,
        pimentel_distances = dpim,
        matchahead_matches = sma,
        pimentel_matches = spim,
        student_preds = preds,
        school_match_ma = school_ma,
        treatment_assignment = trt,
        caliper_value = caliper,
        n_raw_schools_model_year = raw_model,
        n_raw_schools_pred_year = raw_pred,
        n_schools_model_year = n_schools_model,
        grade = g,
        subject = subj,
        config = cfg
      ),
                 list(ema = sym(paste0("effect_ma_", s)),
                      epim = sym(paste0("effect_pim_", s)),
                      dma = sym(paste0("dist_matchahead_", s)),
                      dpim = sym(paste0("dist_pimentel_", s)),
                      sma = sym(paste0("student_match_ma_", s)),
                      spim = sym(paste0("student_match_pim_", s)),
                      preds = sym(paste0("student_preds_", s)),
                      school_ma = sym(paste0("school_match_ma_", s)),
                      trt = sym(paste0("treatment_", s)),
                      caliper = sym(paste0("caliper_", s)),
                      raw_model = sym(paste0("raw_school_count_", s, "_model")),
                      raw_pred = sym(paste0("raw_school_count_", s, "_pred")),
                      n_schools_model = sym(paste0("n_schools_model_year_", s)),
                      g = grade,
                      subj = subject,
                      cfg = config))
    )
  )
}

# Generate settings: all combinations of grade, subject, alpha
settings_grid <- expand.grid(
  grade = c("3", "4", "5"),
  subject = c("glmath", "readng"),
  alpha = alphas,
  stringsAsFactors = FALSE
)

# Sort by grade, then subject, then alpha for consistent ordering
settings_grid <- settings_grid[order(settings_grid$grade, settings_grid$subject, settings_grid$alpha), ]

# Convert to list and add gating (each chain waits for the previous)
settings <- lapply(seq_len(nrow(settings_grid)), function(i) {
  row <- settings_grid[i, ]
  alpha_str <- sprintf("a%02d", round(row$alpha * 10))

  # Gate: wait for previous comparison (NULL for first)
  gate <- if (i == 1) {
    NULL
  } else {
    prev <- settings_grid[i - 1, ]
    prev_alpha_str <- sprintf("a%02d", round(prev$alpha * 10))
    paste0("comparison_", prev$grade, "_", prev$subject, "_", prev_alpha_str)
  }

  list(grade = row$grade, subject = row$subject, alpha = row$alpha, gate = gate)
})

# Generate all chains
chains <- lapply(settings, function(s) {
  make_chain(s$grade, s$subject, s$alpha, s$gate, base_config)
})

# Build list of all comparison targets for final report
comparison_symbols <- lapply(seq_len(nrow(settings_grid)), function(i) {
  row <- settings_grid[i, ]
  alpha_str <- sprintf("a%02d", round(row$alpha * 10))
  as.symbol(paste0("comparison_", row$grade, "_", row$subject, "_", alpha_str))
})

# Build the call: compile_final_report(list(comparison_3_glmath_a05, ...))
final_report_call <- as.call(c(
  list(as.symbol("compile_final_report")),
  list(as.call(c(list(as.symbol("list")), comparison_symbols)))
))

# Flatten and add final report
c(
  unlist(chains, recursive = FALSE),
  list(
    tar_target_raw(
      "final_report",
      final_report_call,
      format = "file"
    )
  )
)
