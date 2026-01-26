# R/predictions.R
# Functions for generating prognostic score predictions

#' Make student-level predictions
#'
#' Uses the fitted model to predict prognostic scores for each student.
#'
#' @param model Fitted lmer model from fit_prognostic_model()
#' @param data Cleaned data frame (prediction year)
#' @param subject Subject name (to identify outcome column)
#' @return Data frame with school_id, study_id, student_score
make_student_predictions <- function(model, data, subject = NULL) {
  # Identify outcome column by subject if provided
  if (!is.null(subject)) {
    outcome_var <- paste0(subject, "_scr_p0")
  }

  # Get covariates the model uses
  model_terms <- names(lme4::fixef(model))

  # Filter out rows with missing covariates
  data_clean <- data
  for (var in model_terms) {
    if (var != "(Intercept)" && var %in% names(data_clean)) {
      data_clean <- data_clean[!is.na(data_clean[[var]]), ]
    }
  }

  # Make predictions
  student_scores <- predict(model, newdata = data_clean, allow.new.levels = TRUE)

  result <- data.frame(
    school_id = as.character(data_clean$dstschid_state_enroll_p0),
    study_id = as.character(data_clean$study_id),
    student_score = as.numeric(student_scores),
    stringsAsFactors = FALSE
  )

  return(result)
}

#' Make school-level predictions
#'
#' Uses the fitted model to predict prognostic scores for each school,
#' setting student-level deviations to zero (average student in each school).
#'
#' @param model Fitted lmer model from fit_prognostic_model()
#' @param data Cleaned data frame (prediction year)
#' @return Data frame with school_id, school_score
make_school_predictions <- function(model, data) {
  # Get one observation per school
  school_data <- data[!duplicated(data$dstschid_state_enroll_p0), ]

  # Set all non-avg columns to 0 (except school ID)
  avg_cols <- grep("^avg_", names(school_data), value = TRUE)
  non_avg_cols <- setdiff(names(school_data), c("dstschid_state_enroll_p0", avg_cols))

  for (col in non_avg_cols) {
    if (is.numeric(school_data[[col]])) {
      school_data[[col]] <- 0
    }
  }

  # Make predictions
  school_scores <- predict(model, newdata = school_data, allow.new.levels = TRUE)

  result <- data.frame(
    school_id = as.character(school_data$dstschid_state_enroll_p0),
    school_score = as.numeric(school_scores),
    stringsAsFactors = FALSE
  )

  return(result)
}

#' Combined prediction function for targets pipeline
#'
#' Returns both student and school predictions in a list.
#'
#' @param model Fitted lmer model
#' @param data Cleaned data frame (prediction year)
#' @param subject Subject name
#' @return List with student_predictions and school_predictions data frames
make_predictions <- function(model, data, subject = NULL) {
  student_preds <- make_student_predictions(model, data, subject)
  school_preds <- make_school_predictions(model, data)

  list(
    student_predictions = student_preds,
    school_predictions = school_preds
  )
}

#' Save predictions to files
#'
#' @param student_predictions Data frame from make_student_predictions()
#' @param school_predictions Data frame from make_school_predictions()
#' @param grade Grade level
#' @param subject Subject name
#' @param year Prediction year
#' @param output_dir Base output directory (default "predictions")
#' @return List with file paths for student and school predictions
save_predictions <- function(student_predictions, school_predictions,
                             grade, subject, year, output_dir = "predictions") {

  student_dir <- file.path(output_dir, "student")
  school_dir <- file.path(output_dir, "school")

  if (!dir.exists(student_dir)) dir.create(student_dir, recursive = TRUE)
  if (!dir.exists(school_dir)) dir.create(school_dir, recursive = TRUE)

  grade_name <- write_grade(grade)
  student_filename <- paste0("tx", year, "_studnt_", subject, "_gr", grade_name, "_preds.csv")
  school_filename <- paste0("tx", year, "_school_", subject, "_gr", grade_name, "_preds.csv")

  student_path <- file.path(student_dir, student_filename)
  school_path <- file.path(school_dir, school_filename)

  readr::write_csv(student_predictions, student_path)
  readr::write_csv(school_predictions, school_path)

  list(
    student_path = student_path,
    school_path = school_path
  )
}
