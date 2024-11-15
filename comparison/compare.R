# compare.R

# Load necessary libraries
library(dplyr)
library(data.table)

# Source required scripts
source("scripts/end_to_end.R")

# Define the compare function
compare <- function(old_data, 
                    new_data, 
                    grouping, 
                    group_level, 
                    unit_level, 
                    outcome, 
                    treatment, 
                    num_cores = 1, 
                    max_rows_in_memory = 1500000, 
                    data_grouped = FALSE) {
  # Calculate the number of unique treatment and control groups
  num_treatment_groups <- new_data %>%
    filter(Treatment == 1) %>%
    pull(Group) %>%
    unique() %>%
    length()
  
  num_control_groups <- new_data %>%
    filter(Treatment == 0) %>%
    pull(Group) %>%
    unique() %>%
    length()
  
  # Compute total_pairs
  total_pairs <- num_treatment_groups * num_control_groups
  cat("Total number of pairs:", total_pairs, "\n")
  
  # Time the execution of end_to_end_modular with use_keele = FALSE
  cat("Running end_to_end (our version)...\n")
  time_end_to_end <- system.time({
    output_end_to_end <- end_to_end(
      old_data = old_data,
      new_data = new_data,
      grouping = grouping,
      group_level = group_level,
      unit_level = unit_level,
      outcome = outcome,
      treatment = treatment,
      num_cores = num_cores,
      max_rows_in_memory = max_rows_in_memory,
      use_keele = FALSE,
      data_grouped = data_grouped
    )
  })["elapsed"]
  cat("end_to_end (standard) completed in", time_end_to_end, "seconds.\n")
  
  # Time the execution of end_to_end_modular with use_keele = TRUE
  cat("Running end_to_end_modular (Keele version)...\n")
  time_end_to_end_keele <- system.time({
    output_end_to_end_keele <- end_to_end(
      old_data = old_data,
      new_data = new_data,
      grouping = grouping,
      group_level = group_level,
      unit_level = unit_level,
      outcome = outcome,
      treatment = treatment,
      num_cores = num_cores,
      max_rows_in_memory = max_rows_in_memory,
      use_keele = TRUE,
      data_grouped = data_grouped
    )
  })["elapsed"]
  cat("end_to_end (Keele) completed in", time_end_to_end_keele, "seconds.\n")
  
  # Calculate time per pair for each function
  time_per_pair_end_to_end <- as.numeric(time_end_to_end) / total_pairs
  time_per_pair_end_to_end_keele <- as.numeric(time_end_to_end_keele) / total_pairs
  
  # Return the results as a list
  return(list(
    output_end_to_end = output_end_to_end,
    output_end_to_end_keele = output_end_to_end_keele,
    time_end_to_end_per_pair = time_per_pair_end_to_end,
    time_end_to_end_keele_per_pair = time_per_pair_end_to_end_keele
  ))
}