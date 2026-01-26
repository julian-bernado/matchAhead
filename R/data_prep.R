# R/data_prep.R
# Data preparation functions for the matchAhead pipeline

#' Create cleaned dataset for a grade/subject/year combination
#'
#' Reads raw data, filters to grade, handles missing values, one-hot encodes
#' categorical variables, and creates school-level aggregates with student deviations.
#'
#' @param grade Grade level as character ("3", "4", or "5")
#' @param subject Subject name ("glmath" or "readng")
#' @param year Year as character (e.g., "2019" or "2020")
#' @param data_dir Directory containing raw data (default "data/raw")
#' @param sample_prop Proportion of schools to sample (0 to 1, default 1.0 = all schools)
#' @param seed Random seed for reproducibility (default NULL = no sampling)
#' @return Cleaned data frame ready for modeling
create_dataset <- function(grade, subject, year, data_dir = "data/raw",
                           sample_prop = 1.0, seed = NULL) {
  grade <- as.character(grade)
  subject <- as.character(subject)
  year <- as.character(year)

  outcome_var <- paste0(subject, "_scr_p0")
  grade_name <- write_grade(grade)

  # Define columns to read
  columns_of_interest <- c(
    "study_id",
    "dstschid_state_enroll_p0",
    "gradelevel",
    "age",
    "gender",
    "raceth",
    outcome_var,
    "specialed_ever",
    "homeless_ever",
    "lep_ever",
    "migrant_ever",
    "attend_p0"
  )

  if (as.numeric(grade) > 3) {
    outcome_lagged_var <- paste0(subject, "_scr_m1")
    outcome_impute_var <- paste0(subject, "_smhstu_m1")
    columns_of_interest <- c(columns_of_interest, outcome_lagged_var, outcome_impute_var)
  }

  # Read data - try local first, then remote
  local_path <- file.path(data_dir, paste0("TX", year, "_DRV.dta"))
  remote_path <- file.path("/home", "tea", "data", "current", paste0("TX", year, "_DRV.dta"))
  data_path <- if (file.exists(local_path)) local_path else remote_path

  df <- haven::read_dta(data_path, col_select = dplyr::all_of(columns_of_interest))

  # Filter to grade of interest
  df <- df[df$gradelevel == as.numeric(grade), ]
  df$gradelevel <- NULL

  # Sample schools if sample_prop < 1
  if (sample_prop < 1.0 && !is.null(seed)) {
    all_schools <- unique(df$dstschid_state_enroll_p0)
    n_schools <- length(all_schools)
    n_sample <- max(1, round(n_schools * sample_prop))

    # Create reproducible seed from base seed + grade + subject + year
    grade_offset <- as.numeric(grade) * 1000

    subject_offset <- ifelse(subject == "glmath", 100, 200)
    year_offset <- as.numeric(year)
    combined_seed <- seed + grade_offset + subject_offset + year_offset

    set.seed(combined_seed)
    sampled_schools <- sample(all_schools, n_sample)
    df <- df[df$dstschid_state_enroll_p0 %in% sampled_schools, ]

    message(sprintf("Sampled %d of %d schools (%.1f%%) for grade %s, %s, %s",
                    n_sample, n_schools, sample_prop * 100, grade, subject, year))
  }

  # Handle missing raceth
  df$raceth <- as.character(df$raceth)
  df$raceth[is.na(df$raceth)] <- "Unknown"
  df$raceth <- factor(df$raceth)

  # One-hot encode gender and raceth
  df <- one_hot(df, c("gender", "raceth"))

  current_columns <- colnames(df)
  covariates <- current_columns[!current_columns %in% c("study_id", "dstschid_state_enroll_p0", outcome_var)]

  # Handle attendance > 1 (invalid values)
  df$attend_p0_na <- ifelse(df$attend_p0 > 1, 1, 0)
  median_attend <- median(df$attend_p0[df$attend_p0 <= 1], na.rm = TRUE)
  df$attend_p0[df$attend_p0 > 1] <- NA
  df$attend_p0[is.na(df$attend_p0)] <- median_attend

  # Scale age and outcome
  df$age <- df$age / max(df$age, na.rm = TRUE)
  df[[outcome_var]] <- df[[outcome_var]] / max(df[[outcome_var]], na.rm = TRUE)

  # Handle lagged outcome for grades > 3
  if (as.numeric(grade) > 3) {
    outcome_lagged_var <- paste0(subject, "_scr_m1")
    outcome_impute_var <- paste0(subject, "_smhstu_m1")

    # Create NA indicator
    na_indicator <- paste0(outcome_lagged_var, "_na")
    df[[na_indicator]] <- as.integer(is.na(df[[outcome_lagged_var]]))

    # Impute with smhstu scores
    df[[outcome_lagged_var]] <- ifelse(
      is.na(df[[outcome_lagged_var]]),
      df[[outcome_impute_var]],
      df[[outcome_lagged_var]]
    )

    # Scale lagged outcome
    df[[outcome_lagged_var]] <- df[[outcome_lagged_var]] / max(df[[outcome_lagged_var]], na.rm = TRUE)

    # Update covariates list
    covariates <- current_columns[!current_columns %in%
                                    c("study_id", "dstschid_state_enroll_p0", outcome_var, outcome_impute_var)]
  }

  # Convert to factors
  df$dstschid_state_enroll_p0 <- as.factor(df$dstschid_state_enroll_p0)
  df$study_id <- as.factor(df$study_id)

  # Create grouped data with school-level averages
  df <- make_grouped(
    data = df,
    grouping = "dstschid_state_enroll_p0",
    group_level = c(),
    unit_level = covariates,
    outcome = outcome_var,
    identifier = "study_id"
  )

  return(df)
}

#' Save cleaned dataset to file
#'
#' @param data Data frame from create_dataset()
#' @param grade Grade level
#' @param subject Subject name
#' @param year Year
#' @param output_dir Output directory (default "data")
#' @return File path where data was saved
save_dataset <- function(data, grade, subject, year, output_dir = "data") {
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  grade_name <- write_grade(grade)
  filename <- paste0("tx", year, "_", subject, "_gr", grade_name, "_df.csv")
  filepath <- file.path(output_dir, filename)

  readr::write_csv(data, filepath)
  return(filepath)
}
