# R/helpers.R
# Utility functions for the matchAhead pipeline

#' Write log to file
#'
#' @param log Named list of log entries
#' @param filename Name of the log file (will be placed in logs/ directory)
write_log <- function(log, filename) {
  if (!dir.exists("logs")) {
    dir.create("logs")
  }

  log_file <- file(file.path("logs", filename), "w")

  for (field_name in names(log)) {
    writeLines(field_name, log_file)
    writeLines(as.character(log[[field_name]]), log_file)
    writeLines(paste(rep("-", 40), collapse = ""), log_file)
  }

  close(log_file)
}

#' Log model diagnostics
#'
#' @param log Existing log list
#' @param model An lme4 model object
#' @return Updated log list with model diagnostics
log_model <- function(log, model) {
  log$anova <- anova(model)
  log$REMLcrit <- lme4::REMLcrit(model)
  log$family <- family(model)
  log$logLik <- logLik(model)
  log$nobs <- nobs(model)
  log$ngrps <- lme4::ngrps(model)
  return(log)
}

#' One-hot encode specified columns
#'
#' @param data A data frame
#' @param vars Character vector of column names to one-hot encode
#' @return Data frame with original columns replaced by one-hot encoded versions
one_hot <- function(data, vars) {
  one_hots_only <- data[, vars, drop = FALSE]

  for (var in vars) {
    unique_vals <- unique(one_hots_only[[var]])
    for (val in unique_vals) {
      newvarname <- paste0(var, "_", val)
      data[[newvarname]] <- ifelse(data[[var]] == val, 1, 0)
    }
    data[[var]] <- NULL
  }

  return(data)
}

#' Create grouped data with school-level averages and student deviations
#'
#' @param data A data frame with student-level data
#' @param grouping Name of the grouping variable (school ID)
#' @param group_level Character vector of group-level covariate names
#' @param unit_level Character vector of unit-level covariate names
#' @param outcome Name of the outcome variable
#' @param identifier Name of the identifier variable (study_id)
#' @return Data frame with avg_* columns and unit-level deviations
make_grouped <- function(data, grouping = "Group", group_level, unit_level,
                         outcome = "Y", identifier) {
  all_covars <- c(grouping, group_level, unit_level, outcome, identifier)

  missing_cols <- setdiff(all_covars, names(data))
  if (length(missing_cols) > 0) {
    stop(paste("The following columns are missing in the data:",
               paste(missing_cols, collapse = ", ")))
  }

  df <- data[, all_covars, drop = FALSE]

  # Identify numeric unit-level variables
  numeric_unit_level <- names(df[, unit_level, drop = FALSE])[
    sapply(df[, unit_level, drop = FALSE], is.numeric)
  ]

  non_numeric <- setdiff(unit_level, numeric_unit_level)
  if (length(non_numeric) > 0) {
    warning(paste("Non-numeric unit_level variables excluded from deviation calculations:",
                  paste(non_numeric, collapse = ", ")))
  }

  # Calculate group-wise averages
  avg_df <- stats::aggregate(
    df[, numeric_unit_level, drop = FALSE],
    by = list(Group = df[[grouping]]),
    FUN = function(x) mean(x, na.rm = TRUE)
  )
  names(avg_df) <- c(grouping, paste0("avg_", numeric_unit_level))

  # Join averages back to original data
  df_with_avg <- merge(df, avg_df, by = grouping, all.x = TRUE)

  # Overwrite unit-level columns with deviations
  for (col in numeric_unit_level) {
    avg_col <- paste0("avg_", col)
    df_with_avg[[col]] <- df_with_avg[[col]] - df_with_avg[[avg_col]]
  }

  return(df_with_avg)
}

#' Write model formula for lmer
#'
#' @param data Data frame with column names
#' @param grade Grade level
#' @param subject Subject name
#' @return Formula object for lmer
write_formula <- function(data, grade, subject) {
  outcome_name <- paste0(subject, "_scr_p0")
  columns <- colnames(data)
  to_remove <- c("dstschid_state_enroll_p0", outcome_name, "gender_1",
                 "avg_gender_1", "raceth_1", "avg_raceth_1", "study_id")

  if (as.numeric(grade) < 4) {
    lagged_outcome_name <- paste0(subject, "_scr_m1")
    avg_lagged_outcome_name <- paste0("avg_", lagged_outcome_name)
    to_remove <- c(to_remove, lagged_outcome_name, avg_lagged_outcome_name)
  }

  covariates <- columns[!columns %in% to_remove]

  lhs_formula <- paste0(outcome_name, " ~ (1 | dstschid_state_enroll_p0) + ")
  rhs_formula <- paste(covariates, collapse = " + ")

  return(formula(paste0(lhs_formula, rhs_formula)))
}

#' Format grade number for filenames
#'
#' @param grade Grade level (character or numeric)
#' @return Formatted grade string
write_grade <- function(grade) {
  if (grade == "-1") {
    return("PK")
  } else if (grade == "0") {
    return("K")
  } else {
    return(sprintf("%02d", as.integer(grade)))
  }
}

#' Build calipered distance matrix
#'
#' Creates a distance matrix where entries outside the caliper are NA
#'
#' @param treatment_scores Numeric vector of treatment unit scores
#' @param control_scores Numeric vector of control unit scores
#' @param caliper Maximum allowed distance
#' @return Matrix with distances (NA where outside caliper)
calipered_dist_matrix <- function(treatment_scores, control_scores, caliper) {
  nt <- length(treatment_scores)
  nc <- length(control_scores)

  # Create outer difference matrix
  dist_mat <- outer(treatment_scores, control_scores, function(x, y) abs(x - y))

  # Set entries outside caliper to NA
  dist_mat[dist_mat > caliper] <- NA

  return(dist_mat)
}
