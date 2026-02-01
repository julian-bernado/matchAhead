# _targets.R
# matchAhead pipeline orchestration using targets
#
# EXECUTION ORDER: Deep (one grade/subject at a time)
# 3_glmath → 3_readng → 4_glmath → 4_readng → 5_glmath → 5_readng
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
n_cores <- parallel::detectCores() - 2

# Configuration
config <- list(
  grades = c("3", "4", "5"),
  subjects = c("glmath", "readng"),
  model_year = "2019",
  pred_year = "2021",
  max_controls = 5,
  prop_treatment = 0.10,
  sample_prop = 1.0,
  seed = 2026,
  cores = n_cores
)

# identity function that creates dependency without using the value
wait_for <- function(data, gate = NULL) {
  data
}

# Factory function to generate all targets for one grade/subject chain
make_chain <- function(grade, subject, gate = NULL, config) {
  s <- paste0(grade, "_", subject)

  # Helper to create symbol from name
  sym <- function(name) as.symbol(name)

  # Build gated command - wraps in wait_for() if gate provided
  gated_cmd <- function(cmd, gate) {
    if (is.null(gate)) cmd
    else substitute(wait_for(cmd, gate), list(cmd = cmd, gate = sym(gate)))
  }

  list(
    tar_target_raw(
      paste0("cleaned_data_", s, "_2019"),
      gated_cmd(
        substitute(create_dataset(g, subj, "2019", sample_prop = config$sample_prop, seed = config$seed),
                   list(g = grade, subj = subject)),
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
      paste0("cleaned_data_", s, "_2021"),
      gated_cmd(
        substitute(create_dataset(g, subj, "2021", sample_prop = config$sample_prop, seed = config$seed),
                   list(g = grade, subj = subject)),
        gate
      ),
      format = "rds"
    ),
    tar_target_raw(
      paste0("report_data_prep_", s, "_2021"),
      substitute(generate_data_prep_report(data, g, subj, "2021"),
                 list(data = sym(paste0("cleaned_data_", s, "_2021")), g = grade, subj = subject)),
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
                 list(model = sym(paste0("model_", s)), data = sym(paste0("cleaned_data_", s, "_2021")),
                      subj = subject)),
      format = "rds"
    ),
    tar_target_raw(
      paste0("school_preds_", s),
      substitute(make_school_predictions(model, data),
                 list(model = sym(paste0("model_", s)), data = sym(paste0("cleaned_data_", s, "_2021"))))
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
      substitute(assign_treatment_from_data(data, config$prop_treatment, config$seed),
                 list(data = sym(paste0("cleaned_data_", s, "_2021"))))
    ),
    tar_target_raw(
      paste0("report_treatment_", s),
      substitute(generate_treatment_report(trt, data, g, subj),
                 list(trt = sym(paste0("treatment_", s)), data = sym(paste0("cleaned_data_", s, "_2021")),
                      g = grade, subj = subject)),
      format = "file"
    ),
    tar_target_raw(
      paste0("dist_matchahead_", s),
      substitute(compute_matchahead_distances(preds, trt, caliper, config$max_controls, cores = config$cores),
                 list(preds = sym(paste0("student_preds_", s)), trt = sym(paste0("treatment_", s)),
                      caliper = sym(paste0("caliper_", s)))),
      format = "rds"
    ),
    tar_target_raw(
      paste0("dist_pimentel_", s),
      substitute(compute_pimentel_distances(preds, trt, config$max_controls, cores = config$cores),
                 list(preds = sym(paste0("student_preds_", s)), trt = sym(paste0("treatment_", s)))),
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
      substitute(match_all_students(smatch, preds, config$max_controls),
                 list(smatch = sym(paste0("school_match_ma_", s)), preds = sym(paste0("student_preds_", s)))),
      format = "rds"
    ),
    tar_target_raw(
      paste0("student_match_pim_", s),
      substitute(match_all_students(smatch, preds, config$max_controls),
                 list(smatch = sym(paste0("school_match_pim_", s)), preds = sym(paste0("student_preds_", s)))),
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
      substitute(estimate_treatment_effect_full(match, data, subj),
                 list(match = sym(paste0("student_match_ma_", s)), data = sym(paste0("cleaned_data_", s, "_2021")),
                      subj = subject))
    ),
    tar_target_raw(
      paste0("effect_pim_", s),
      substitute(estimate_treatment_effect_full(match, data, subj),
                 list(match = sym(paste0("student_match_pim_", s)), data = sym(paste0("cleaned_data_", s, "_2021")),
                      subj = subject))
    ),
    tar_target_raw(
      paste0("report_effects_", s),
      substitute(generate_effects_report(ema, epim, g, subj),
                 list(ema = sym(paste0("effect_ma_", s)), epim = sym(paste0("effect_pim_", s)),
                      g = grade, subj = subject)),
      format = "file"
    ),
    tar_target_raw(
      paste0("comparison_", s),
      substitute(generate_comparison(ema, epim, dma, dpim, g, subj),
                 list(ema = sym(paste0("effect_ma_", s)), epim = sym(paste0("effect_pim_", s)),
                      dma = sym(paste0("dist_matchahead_", s)), dpim = sym(paste0("dist_pimentel_", s)),
                      g = grade, subj = subject))
    )
  )
}

# Define the execution order with gates
settings <- list(
  list(grade = "3", subject = "glmath", gate = NULL),
  list(grade = "3", subject = "readng", gate = "comparison_3_glmath"),
  list(grade = "4", subject = "glmath", gate = "comparison_3_readng"),
  list(grade = "4", subject = "readng", gate = "comparison_4_glmath"),
  list(grade = "5", subject = "glmath", gate = "comparison_4_readng"),
  list(grade = "5", subject = "readng", gate = "comparison_5_glmath")
)

# Generate all chains
chains <- lapply(settings, function(s) make_chain(s$grade, s$subject, s$gate, config))

# Flatten and add final report
c(
  unlist(chains, recursive = FALSE),
  list(
    tar_target(
      final_report,
      compile_final_report(list(
        comparison_3_glmath, comparison_3_readng,
        comparison_4_glmath, comparison_4_readng,
        comparison_5_glmath, comparison_5_readng
      )),
      format = "file"
    )
  )
)
