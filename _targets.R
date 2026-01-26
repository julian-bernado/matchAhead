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

# Build the pipeline with deep execution order
# Want to do each pipeline all the way through rather than all step 1s, all step 2s, etc
list(
  # ############################################################################
  # CHAIN 1: Grade 3, glmath (NO GATE - starts first)
  # ############################################################################
  tar_target(
    cleaned_data_3_glmath_2019,
    create_dataset("3", "glmath", "2019", sample_prop = config$sample_prop, seed = config$seed),
    format = "rds"
  ),
  tar_target(report_data_prep_3_glmath_2019, generate_data_prep_report(cleaned_data_3_glmath_2019, "3", "glmath", "2019"), format = "file"),
  tar_target(
    cleaned_data_3_glmath_2021,
    create_dataset("3", "glmath", "2021", sample_prop = config$sample_prop, seed = config$seed),
    format = "rds"
  ),
  tar_target(report_data_prep_3_glmath_2021, generate_data_prep_report(cleaned_data_3_glmath_2021, "3", "glmath", "2021"), format = "file"),
  tar_target(
    model_3_glmath,
    fit_prognostic_model(cleaned_data_3_glmath_2019, "3", "glmath"),
    format = "rds"
  ),
  tar_target(report_model_3_glmath, generate_model_report(model_3_glmath, "3", "glmath"), format = "file"),
  tar_target(caliper_3_glmath, calculate_caliper(model_3_glmath)),
  tar_target(report_caliper_3_glmath, generate_caliper_report(caliper_3_glmath, model_3_glmath, "3", "glmath"), format = "file"),
  tar_target(
    student_preds_3_glmath,
    make_student_predictions(model_3_glmath, cleaned_data_3_glmath_2021, "glmath"),
    format = "rds"
  ),
  tar_target(
    school_preds_3_glmath,
    make_school_predictions(model_3_glmath, cleaned_data_3_glmath_2021)
  ),
  tar_target(report_predictions_3_glmath, generate_predictions_report(student_preds_3_glmath, school_preds_3_glmath, "3", "glmath"), format = "file"),
  tar_target(
    treatment_3_glmath,
    assign_treatment_from_data(cleaned_data_3_glmath_2021, config$prop_treatment, config$seed)
  ),
  tar_target(report_treatment_3_glmath, generate_treatment_report(treatment_3_glmath, cleaned_data_3_glmath_2021, "3", "glmath"), format = "file"),
  tar_target(
    dist_matchahead_3_glmath,
    compute_matchahead_distances(student_preds_3_glmath, treatment_3_glmath,
                                  caliper_3_glmath, config$max_controls,
                                  cores = config$cores),
    format = "rds"
  ),
  tar_target(
    dist_pimentel_3_glmath,
    compute_pimentel_distances(student_preds_3_glmath, treatment_3_glmath,
                                config$max_controls, cores = config$cores),
    format = "rds"
  ),
  tar_target(report_distances_3_glmath, generate_distances_report(dist_matchahead_3_glmath, dist_pimentel_3_glmath, "3", "glmath"), format = "file"),
  tar_target(
    school_match_ma_3_glmath,
    match_schools(dist_matchahead_3_glmath, treatment_3_glmath)
  ),
  tar_target(
    school_match_pim_3_glmath,
    match_schools(dist_pimentel_3_glmath, treatment_3_glmath)
  ),
  tar_target(report_school_matching_3_glmath, generate_school_matching_report(school_match_ma_3_glmath, school_match_pim_3_glmath, student_preds_3_glmath, "3", "glmath"), format = "file"),
  tar_target(
    student_match_ma_3_glmath,
    match_all_students(school_match_ma_3_glmath, student_preds_3_glmath, config$max_controls),
    format = "rds"
  ),
  tar_target(
    student_match_pim_3_glmath,
    match_all_students(school_match_pim_3_glmath, student_preds_3_glmath, config$max_controls),
    format = "rds"
  ),
  tar_target(report_student_matching_3_glmath, generate_student_matching_report(student_match_ma_3_glmath, student_match_pim_3_glmath, student_preds_3_glmath, "3", "glmath"), format = "file"),
  tar_target(
    effect_ma_3_glmath,
    estimate_treatment_effect_full(student_match_ma_3_glmath, cleaned_data_3_glmath_2021, "glmath")
  ),
  tar_target(
    effect_pim_3_glmath,
    estimate_treatment_effect_full(student_match_pim_3_glmath, cleaned_data_3_glmath_2021, "glmath")
  ),
  tar_target(report_effects_3_glmath, generate_effects_report(effect_ma_3_glmath, effect_pim_3_glmath, "3", "glmath"), format = "file"),
  tar_target(
    comparison_3_glmath,
    generate_comparison(effect_ma_3_glmath, effect_pim_3_glmath,
                        dist_matchahead_3_glmath, dist_pimentel_3_glmath,
                        "3", "glmath")
  ),

  # ############################################################################
  # CHAIN 2: Grade 3, readng (GATE: comparison_3_glmath)
  # ############################################################################
  tar_target(
    cleaned_data_3_readng_2019,
    wait_for(create_dataset("3", "readng", "2019", sample_prop = config$sample_prop, seed = config$seed), comparison_3_glmath),
    format = "rds"
  ),
  tar_target(report_data_prep_3_readng_2019, generate_data_prep_report(cleaned_data_3_readng_2019, "3", "readng", "2019"), format = "file"),
  tar_target(
    cleaned_data_3_readng_2021,
    wait_for(create_dataset("3", "readng", "2021", sample_prop = config$sample_prop, seed = config$seed), comparison_3_glmath),
    format = "rds"
  ),
  tar_target(report_data_prep_3_readng_2021, generate_data_prep_report(cleaned_data_3_readng_2021, "3", "readng", "2021"), format = "file"),
  tar_target(
    model_3_readng,
    fit_prognostic_model(cleaned_data_3_readng_2019, "3", "readng"),
    format = "rds"
  ),
  tar_target(report_model_3_readng, generate_model_report(model_3_readng, "3", "readng"), format = "file"),
  tar_target(caliper_3_readng, calculate_caliper(model_3_readng)),
  tar_target(report_caliper_3_readng, generate_caliper_report(caliper_3_readng, model_3_readng, "3", "readng"), format = "file"),
  tar_target(
    student_preds_3_readng,
    make_student_predictions(model_3_readng, cleaned_data_3_readng_2021, "readng"),
    format = "rds"
  ),
  tar_target(
    school_preds_3_readng,
    make_school_predictions(model_3_readng, cleaned_data_3_readng_2021)
  ),
  tar_target(report_predictions_3_readng, generate_predictions_report(student_preds_3_readng, school_preds_3_readng, "3", "readng"), format = "file"),
  tar_target(
    treatment_3_readng,
    assign_treatment_from_data(cleaned_data_3_readng_2021, config$prop_treatment, config$seed)
  ),
  tar_target(report_treatment_3_readng, generate_treatment_report(treatment_3_readng, cleaned_data_3_readng_2021, "3", "readng"), format = "file"),
  tar_target(
    dist_matchahead_3_readng,
    compute_matchahead_distances(student_preds_3_readng, treatment_3_readng,
                                  caliper_3_readng, config$max_controls,
                                  cores = config$cores),
    format = "rds"
  ),
  tar_target(
    dist_pimentel_3_readng,
    compute_pimentel_distances(student_preds_3_readng, treatment_3_readng,
                                config$max_controls, cores = config$cores),
    format = "rds"
  ),
  tar_target(report_distances_3_readng, generate_distances_report(dist_matchahead_3_readng, dist_pimentel_3_readng, "3", "readng"), format = "file"),
  tar_target(
    school_match_ma_3_readng,
    match_schools(dist_matchahead_3_readng, treatment_3_readng)
  ),
  tar_target(
    school_match_pim_3_readng,
    match_schools(dist_pimentel_3_readng, treatment_3_readng)
  ),
  tar_target(report_school_matching_3_readng, generate_school_matching_report(school_match_ma_3_readng, school_match_pim_3_readng, student_preds_3_readng, "3", "readng"), format = "file"),
  tar_target(
    student_match_ma_3_readng,
    match_all_students(school_match_ma_3_readng, student_preds_3_readng, config$max_controls),
    format = "rds"
  ),
  tar_target(
    student_match_pim_3_readng,
    match_all_students(school_match_pim_3_readng, student_preds_3_readng, config$max_controls),
    format = "rds"
  ),
  tar_target(report_student_matching_3_readng, generate_student_matching_report(student_match_ma_3_readng, student_match_pim_3_readng, student_preds_3_readng, "3", "readng"), format = "file"),
  tar_target(
    effect_ma_3_readng,
    estimate_treatment_effect_full(student_match_ma_3_readng, cleaned_data_3_readng_2021, "readng")
  ),
  tar_target(
    effect_pim_3_readng,
    estimate_treatment_effect_full(student_match_pim_3_readng, cleaned_data_3_readng_2021, "readng")
  ),
  tar_target(report_effects_3_readng, generate_effects_report(effect_ma_3_readng, effect_pim_3_readng, "3", "readng"), format = "file"),
  tar_target(
    comparison_3_readng,
    generate_comparison(effect_ma_3_readng, effect_pim_3_readng,
                        dist_matchahead_3_readng, dist_pimentel_3_readng,
                        "3", "readng")
  ),

  # ############################################################################
  # CHAIN 3: Grade 4, glmath (GATE: comparison_3_readng)
  # ############################################################################
  tar_target(
    cleaned_data_4_glmath_2019,
    wait_for(create_dataset("4", "glmath", "2019", sample_prop = config$sample_prop, seed = config$seed), comparison_3_readng),
    format = "rds"
  ),
  tar_target(report_data_prep_4_glmath_2019, generate_data_prep_report(cleaned_data_4_glmath_2019, "4", "glmath", "2019"), format = "file"),
  tar_target(
    cleaned_data_4_glmath_2021,
    wait_for(create_dataset("4", "glmath", "2021", sample_prop = config$sample_prop, seed = config$seed), comparison_3_readng),
    format = "rds"
  ),
  tar_target(report_data_prep_4_glmath_2021, generate_data_prep_report(cleaned_data_4_glmath_2021, "4", "glmath", "2021"), format = "file"),
  tar_target(
    model_4_glmath,
    fit_prognostic_model(cleaned_data_4_glmath_2019, "4", "glmath"),
    format = "rds"
  ),
  tar_target(report_model_4_glmath, generate_model_report(model_4_glmath, "4", "glmath"), format = "file"),
  tar_target(caliper_4_glmath, calculate_caliper(model_4_glmath)),
  tar_target(report_caliper_4_glmath, generate_caliper_report(caliper_4_glmath, model_4_glmath, "4", "glmath"), format = "file"),
  tar_target(
    student_preds_4_glmath,
    make_student_predictions(model_4_glmath, cleaned_data_4_glmath_2021, "glmath"),
    format = "rds"
  ),
  tar_target(
    school_preds_4_glmath,
    make_school_predictions(model_4_glmath, cleaned_data_4_glmath_2021)
  ),
  tar_target(report_predictions_4_glmath, generate_predictions_report(student_preds_4_glmath, school_preds_4_glmath, "4", "glmath"), format = "file"),
  tar_target(
    treatment_4_glmath,
    assign_treatment_from_data(cleaned_data_4_glmath_2021, config$prop_treatment, config$seed)
  ),
  tar_target(report_treatment_4_glmath, generate_treatment_report(treatment_4_glmath, cleaned_data_4_glmath_2021, "4", "glmath"), format = "file"),
  tar_target(
    dist_matchahead_4_glmath,
    compute_matchahead_distances(student_preds_4_glmath, treatment_4_glmath,
                                  caliper_4_glmath, config$max_controls,
                                  cores = config$cores),
    format = "rds"
  ),
  tar_target(
    dist_pimentel_4_glmath,
    compute_pimentel_distances(student_preds_4_glmath, treatment_4_glmath,
                                config$max_controls, cores = config$cores),
    format = "rds"
  ),
  tar_target(report_distances_4_glmath, generate_distances_report(dist_matchahead_4_glmath, dist_pimentel_4_glmath, "4", "glmath"), format = "file"),
  tar_target(
    school_match_ma_4_glmath,
    match_schools(dist_matchahead_4_glmath, treatment_4_glmath)
  ),
  tar_target(
    school_match_pim_4_glmath,
    match_schools(dist_pimentel_4_glmath, treatment_4_glmath)
  ),
  tar_target(report_school_matching_4_glmath, generate_school_matching_report(school_match_ma_4_glmath, school_match_pim_4_glmath, student_preds_4_glmath, "4", "glmath"), format = "file"),
  tar_target(
    student_match_ma_4_glmath,
    match_all_students(school_match_ma_4_glmath, student_preds_4_glmath, config$max_controls),
    format = "rds"
  ),
  tar_target(
    student_match_pim_4_glmath,
    match_all_students(school_match_pim_4_glmath, student_preds_4_glmath, config$max_controls),
    format = "rds"
  ),
  tar_target(report_student_matching_4_glmath, generate_student_matching_report(student_match_ma_4_glmath, student_match_pim_4_glmath, student_preds_4_glmath, "4", "glmath"), format = "file"),
  tar_target(
    effect_ma_4_glmath,
    estimate_treatment_effect_full(student_match_ma_4_glmath, cleaned_data_4_glmath_2021, "glmath")
  ),
  tar_target(
    effect_pim_4_glmath,
    estimate_treatment_effect_full(student_match_pim_4_glmath, cleaned_data_4_glmath_2021, "glmath")
  ),
  tar_target(report_effects_4_glmath, generate_effects_report(effect_ma_4_glmath, effect_pim_4_glmath, "4", "glmath"), format = "file"),
  tar_target(
    comparison_4_glmath,
    generate_comparison(effect_ma_4_glmath, effect_pim_4_glmath,
                        dist_matchahead_4_glmath, dist_pimentel_4_glmath,
                        "4", "glmath")
  ),

  # ############################################################################
  # CHAIN 4: Grade 4, readng (GATE: comparison_4_glmath)
  # ############################################################################
  tar_target(
    cleaned_data_4_readng_2019,
    wait_for(create_dataset("4", "readng", "2019", sample_prop = config$sample_prop, seed = config$seed), comparison_4_glmath),
    format = "rds"
  ),
  tar_target(report_data_prep_4_readng_2019, generate_data_prep_report(cleaned_data_4_readng_2019, "4", "readng", "2019"), format = "file"),
  tar_target(
    cleaned_data_4_readng_2021,
    wait_for(create_dataset("4", "readng", "2021", sample_prop = config$sample_prop, seed = config$seed), comparison_4_glmath),
    format = "rds"
  ),
  tar_target(report_data_prep_4_readng_2021, generate_data_prep_report(cleaned_data_4_readng_2021, "4", "readng", "2021"), format = "file"),
  tar_target(
    model_4_readng,
    fit_prognostic_model(cleaned_data_4_readng_2019, "4", "readng"),
    format = "rds"
  ),
  tar_target(report_model_4_readng, generate_model_report(model_4_readng, "4", "readng"), format = "file"),
  tar_target(caliper_4_readng, calculate_caliper(model_4_readng)),
  tar_target(report_caliper_4_readng, generate_caliper_report(caliper_4_readng, model_4_readng, "4", "readng"), format = "file"),
  tar_target(
    student_preds_4_readng,
    make_student_predictions(model_4_readng, cleaned_data_4_readng_2021, "readng"),
    format = "rds"
  ),
  tar_target(
    school_preds_4_readng,
    make_school_predictions(model_4_readng, cleaned_data_4_readng_2021)
  ),
  tar_target(report_predictions_4_readng, generate_predictions_report(student_preds_4_readng, school_preds_4_readng, "4", "readng"), format = "file"),
  tar_target(
    treatment_4_readng,
    assign_treatment_from_data(cleaned_data_4_readng_2021, config$prop_treatment, config$seed)
  ),
  tar_target(report_treatment_4_readng, generate_treatment_report(treatment_4_readng, cleaned_data_4_readng_2021, "4", "readng"), format = "file"),
  tar_target(
    dist_matchahead_4_readng,
    compute_matchahead_distances(student_preds_4_readng, treatment_4_readng,
                                  caliper_4_readng, config$max_controls,
                                  cores = config$cores),
    format = "rds"
  ),
  tar_target(
    dist_pimentel_4_readng,
    compute_pimentel_distances(student_preds_4_readng, treatment_4_readng,
                                config$max_controls, cores = config$cores),
    format = "rds"
  ),
  tar_target(report_distances_4_readng, generate_distances_report(dist_matchahead_4_readng, dist_pimentel_4_readng, "4", "readng"), format = "file"),
  tar_target(
    school_match_ma_4_readng,
    match_schools(dist_matchahead_4_readng, treatment_4_readng)
  ),
  tar_target(
    school_match_pim_4_readng,
    match_schools(dist_pimentel_4_readng, treatment_4_readng)
  ),
  tar_target(report_school_matching_4_readng, generate_school_matching_report(school_match_ma_4_readng, school_match_pim_4_readng, student_preds_4_readng, "4", "readng"), format = "file"),
  tar_target(
    student_match_ma_4_readng,
    match_all_students(school_match_ma_4_readng, student_preds_4_readng, config$max_controls),
    format = "rds"
  ),
  tar_target(
    student_match_pim_4_readng,
    match_all_students(school_match_pim_4_readng, student_preds_4_readng, config$max_controls),
    format = "rds"
  ),
  tar_target(report_student_matching_4_readng, generate_student_matching_report(student_match_ma_4_readng, student_match_pim_4_readng, student_preds_4_readng, "4", "readng"), format = "file"),
  tar_target(
    effect_ma_4_readng,
    estimate_treatment_effect_full(student_match_ma_4_readng, cleaned_data_4_readng_2021, "readng")
  ),
  tar_target(
    effect_pim_4_readng,
    estimate_treatment_effect_full(student_match_pim_4_readng, cleaned_data_4_readng_2021, "readng")
  ),
  tar_target(report_effects_4_readng, generate_effects_report(effect_ma_4_readng, effect_pim_4_readng, "4", "readng"), format = "file"),
  tar_target(
    comparison_4_readng,
    generate_comparison(effect_ma_4_readng, effect_pim_4_readng,
                        dist_matchahead_4_readng, dist_pimentel_4_readng,
                        "4", "readng")
  ),

  # ############################################################################
  # CHAIN 5: Grade 5, glmath (GATE: comparison_4_readng)
  # ############################################################################
  tar_target(
    cleaned_data_5_glmath_2019,
    wait_for(create_dataset("5", "glmath", "2019", sample_prop = config$sample_prop, seed = config$seed), comparison_4_readng),
    format = "rds"
  ),
  tar_target(report_data_prep_5_glmath_2019, generate_data_prep_report(cleaned_data_5_glmath_2019, "5", "glmath", "2019"), format = "file"),
  tar_target(
    cleaned_data_5_glmath_2021,
    wait_for(create_dataset("5", "glmath", "2021", sample_prop = config$sample_prop, seed = config$seed), comparison_4_readng),
    format = "rds"
  ),
  tar_target(report_data_prep_5_glmath_2021, generate_data_prep_report(cleaned_data_5_glmath_2021, "5", "glmath", "2021"), format = "file"),
  tar_target(
    model_5_glmath,
    fit_prognostic_model(cleaned_data_5_glmath_2019, "5", "glmath"),
    format = "rds"
  ),
  tar_target(report_model_5_glmath, generate_model_report(model_5_glmath, "5", "glmath"), format = "file"),
  tar_target(caliper_5_glmath, calculate_caliper(model_5_glmath)),
  tar_target(report_caliper_5_glmath, generate_caliper_report(caliper_5_glmath, model_5_glmath, "5", "glmath"), format = "file"),
  tar_target(
    student_preds_5_glmath,
    make_student_predictions(model_5_glmath, cleaned_data_5_glmath_2021, "glmath"),
    format = "rds"
  ),
  tar_target(
    school_preds_5_glmath,
    make_school_predictions(model_5_glmath, cleaned_data_5_glmath_2021)
  ),
  tar_target(report_predictions_5_glmath, generate_predictions_report(student_preds_5_glmath, school_preds_5_glmath, "5", "glmath"), format = "file"),
  tar_target(
    treatment_5_glmath,
    assign_treatment_from_data(cleaned_data_5_glmath_2021, config$prop_treatment, config$seed)
  ),
  tar_target(report_treatment_5_glmath, generate_treatment_report(treatment_5_glmath, cleaned_data_5_glmath_2021, "5", "glmath"), format = "file"),
  tar_target(
    dist_matchahead_5_glmath,
    compute_matchahead_distances(student_preds_5_glmath, treatment_5_glmath,
                                  caliper_5_glmath, config$max_controls,
                                  cores = config$cores),
    format = "rds"
  ),
  tar_target(
    dist_pimentel_5_glmath,
    compute_pimentel_distances(student_preds_5_glmath, treatment_5_glmath,
                                config$max_controls, cores = config$cores),
    format = "rds"
  ),
  tar_target(report_distances_5_glmath, generate_distances_report(dist_matchahead_5_glmath, dist_pimentel_5_glmath, "5", "glmath"), format = "file"),
  tar_target(
    school_match_ma_5_glmath,
    match_schools(dist_matchahead_5_glmath, treatment_5_glmath)
  ),
  tar_target(
    school_match_pim_5_glmath,
    match_schools(dist_pimentel_5_glmath, treatment_5_glmath)
  ),
  tar_target(report_school_matching_5_glmath, generate_school_matching_report(school_match_ma_5_glmath, school_match_pim_5_glmath, student_preds_5_glmath, "5", "glmath"), format = "file"),
  tar_target(
    student_match_ma_5_glmath,
    match_all_students(school_match_ma_5_glmath, student_preds_5_glmath, config$max_controls),
    format = "rds"
  ),
  tar_target(
    student_match_pim_5_glmath,
    match_all_students(school_match_pim_5_glmath, student_preds_5_glmath, config$max_controls),
    format = "rds"
  ),
  tar_target(report_student_matching_5_glmath, generate_student_matching_report(student_match_ma_5_glmath, student_match_pim_5_glmath, student_preds_5_glmath, "5", "glmath"), format = "file"),
  tar_target(
    effect_ma_5_glmath,
    estimate_treatment_effect_full(student_match_ma_5_glmath, cleaned_data_5_glmath_2021, "glmath")
  ),
  tar_target(
    effect_pim_5_glmath,
    estimate_treatment_effect_full(student_match_pim_5_glmath, cleaned_data_5_glmath_2021, "glmath")
  ),
  tar_target(report_effects_5_glmath, generate_effects_report(effect_ma_5_glmath, effect_pim_5_glmath, "5", "glmath"), format = "file"),
  tar_target(
    comparison_5_glmath,
    generate_comparison(effect_ma_5_glmath, effect_pim_5_glmath,
                        dist_matchahead_5_glmath, dist_pimentel_5_glmath,
                        "5", "glmath")
  ),

  # ############################################################################
  # CHAIN 6: Grade 5, readng (GATE: comparison_5_glmath)
  # ############################################################################
  tar_target(
    cleaned_data_5_readng_2019,
    wait_for(create_dataset("5", "readng", "2019", sample_prop = config$sample_prop, seed = config$seed), comparison_5_glmath),
    format = "rds"
  ),
  tar_target(report_data_prep_5_readng_2019, generate_data_prep_report(cleaned_data_5_readng_2019, "5", "readng", "2019"), format = "file"),
  tar_target(
    cleaned_data_5_readng_2021,
    wait_for(create_dataset("5", "readng", "2021", sample_prop = config$sample_prop, seed = config$seed), comparison_5_glmath),
    format = "rds"
  ),
  tar_target(report_data_prep_5_readng_2021, generate_data_prep_report(cleaned_data_5_readng_2021, "5", "readng", "2021"), format = "file"),
  tar_target(
    model_5_readng,
    fit_prognostic_model(cleaned_data_5_readng_2019, "5", "readng"),
    format = "rds"
  ),
  tar_target(report_model_5_readng, generate_model_report(model_5_readng, "5", "readng"), format = "file"),
  tar_target(caliper_5_readng, calculate_caliper(model_5_readng)),
  tar_target(report_caliper_5_readng, generate_caliper_report(caliper_5_readng, model_5_readng, "5", "readng"), format = "file"),
  tar_target(
    student_preds_5_readng,
    make_student_predictions(model_5_readng, cleaned_data_5_readng_2021, "readng"),
    format = "rds"
  ),
  tar_target(
    school_preds_5_readng,
    make_school_predictions(model_5_readng, cleaned_data_5_readng_2021)
  ),
  tar_target(report_predictions_5_readng, generate_predictions_report(student_preds_5_readng, school_preds_5_readng, "5", "readng"), format = "file"),
  tar_target(
    treatment_5_readng,
    assign_treatment_from_data(cleaned_data_5_readng_2021, config$prop_treatment, config$seed)
  ),
  tar_target(report_treatment_5_readng, generate_treatment_report(treatment_5_readng, cleaned_data_5_readng_2021, "5", "readng"), format = "file"),
  tar_target(
    dist_matchahead_5_readng,
    compute_matchahead_distances(student_preds_5_readng, treatment_5_readng,
                                  caliper_5_readng, config$max_controls,
                                  cores = config$cores),
    format = "rds"
  ),
  tar_target(
    dist_pimentel_5_readng,
    compute_pimentel_distances(student_preds_5_readng, treatment_5_readng,
                                config$max_controls, cores = config$cores),
    format = "rds"
  ),
  tar_target(report_distances_5_readng, generate_distances_report(dist_matchahead_5_readng, dist_pimentel_5_readng, "5", "readng"), format = "file"),
  tar_target(
    school_match_ma_5_readng,
    match_schools(dist_matchahead_5_readng, treatment_5_readng)
  ),
  tar_target(
    school_match_pim_5_readng,
    match_schools(dist_pimentel_5_readng, treatment_5_readng)
  ),
  tar_target(report_school_matching_5_readng, generate_school_matching_report(school_match_ma_5_readng, school_match_pim_5_readng, student_preds_5_readng, "5", "readng"), format = "file"),
  tar_target(
    student_match_ma_5_readng,
    match_all_students(school_match_ma_5_readng, student_preds_5_readng, config$max_controls),
    format = "rds"
  ),
  tar_target(
    student_match_pim_5_readng,
    match_all_students(school_match_pim_5_readng, student_preds_5_readng, config$max_controls),
    format = "rds"
  ),
  tar_target(report_student_matching_5_readng, generate_student_matching_report(student_match_ma_5_readng, student_match_pim_5_readng, student_preds_5_readng, "5", "readng"), format = "file"),
  tar_target(
    effect_ma_5_readng,
    estimate_treatment_effect_full(student_match_ma_5_readng, cleaned_data_5_readng_2021, "readng")
  ),
  tar_target(
    effect_pim_5_readng,
    estimate_treatment_effect_full(student_match_pim_5_readng, cleaned_data_5_readng_2021, "readng")
  ),
  tar_target(report_effects_5_readng, generate_effects_report(effect_ma_5_readng, effect_pim_5_readng, "5", "readng"), format = "file"),
  tar_target(
    comparison_5_readng,
    generate_comparison(effect_ma_5_readng, effect_pim_5_readng,
                        dist_matchahead_5_readng, dist_pimentel_5_readng,
                        "5", "readng")
  ),

  # ############################################################################
  # FINAL REPORT (after all chains complete)
  # ############################################################################
  tar_target(
    final_report,
    compile_final_report(list(
      comparison_3_glmath,
      comparison_3_readng,
      comparison_4_glmath,
      comparison_4_readng,
      comparison_5_glmath,
      comparison_5_readng
    )),
    format = "file"
  )
)
