#!/usr/bin/env Rscript
# analysis/num_schools.R
# Usage: Rscript num_schools.R <grade> <subject>
# Example: Rscript num_schools.R 3 glmath

args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 2) {
  stop("Usage: Rscript num_schools.R <grade> <subject>\n  Example: Rscript num_schools.R 3 glmath")
}

grade <- args[1]
subject <- args[2]

# Validate inputs
valid_grades <- c("3", "4", "5")
valid_subjects <- c("glmath", "readng")

if (!grade %in% valid_grades) {
  stop(sprintf("Invalid grade '%s'. Must be one of: %s", grade, paste(valid_grades, collapse = ", ")))
}

if (!subject %in% valid_subjects) {
  stop(sprintf("Invalid subject '%s'. Must be one of: %s", subject, paste(valid_subjects, collapse = ", ")))
}

# Pipeline config (must match _targets.R)
config <- list(
  pred_year = "2022",
  prop_treatment = 0.10,
  sample_prop = 1.0,
  seed = 2026
)

# Source required functions
source("R/helpers.R")
source("R/data_prep.R")
source("R/treatment_assignment.R")

# Load the prediction year data and compute treatment assignment
suppressMessages({
  cleaned_data <- create_dataset(
    grade = grade,
    subject = subject,
    year = config$pred_year,
    sample_prop = config$sample_prop,
    seed = config$seed
  )
})

treatment <- assign_treatment_from_data(
  cleaned_data,
  prop_treatment = config$prop_treatment,
  seed = config$seed
)

# Count schools
n_treated <- sum(treatment$treatment == 1)
n_control <- sum(treatment$treatment == 0)
n_total <- nrow(treatment)

cat(sprintf("Grade %s, Subject %s\n", grade, subject))
cat(sprintf("  Treated schools:  %d\n", n_treated))
cat(sprintf("  Control schools:  %d\n", n_control))
cat(sprintf("  Total schools:    %d\n", n_total))
