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
  
  # Process new_data to compute total_pairs
  processed_new_data <- assimilate_df(new_data, 
                                      grouping = grouping, 
                                      outcome = outcome, 
                                      treatment = treatment)
  
  if(!data_grouped){
    processed_new_data <- make_grouped(data = processed_new_data,
                                       group_level = group_level,
                                       unit_level = unit_level)
  }
  
  # Calculate the number of unique treatment and control groups
  num_treatment_groups <- processed_new_data %>%
    filter(Treatment == 1) %>%
    pull(sym(grouping)) %>%
    unique() %>%
    length()
  
  num_control_groups <- processed_new_data %>%
    filter(Treatment == 0) %>%
    pull(sym(grouping)) %>%
    unique() %>%
    length()
  
  # Compute total_pairs
  total_pairs <- num_treatment_groups * num_control_groups
  cat("Total number of pairs:", total_pairs, "\n")
  print(dim(old_data))
  print(dim(new_data))
  
  # Run end_to_end_modular with use_keele = FALSE
  cat("Running end_to_end_modular (standard version)...\n")
  output1 <- end_to_end_modular(
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
  
  # Extract outputs and time taken
  if (!is.null(output1$result_files)) {
    output_end_to_end <- output1$result_files
  } else {
    output_end_to_end <- output1$distances
  }
  time_end_to_end <- output1$time_taken
  
  cat("end_to_end_modular (standard) completed get_distances in", time_end_to_end, "seconds.\n")
  
  # Run end_to_end_modular with use_keele = TRUE
  cat("Running end_to_end_modular (Keele version)...\n")
  output2 <- end_to_end_modular(
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
  
  # Extract outputs and time taken
  if (!is.null(output2$result_files)) {
    output_end_to_end_keele <- output2$result_files
  } else {
    output_end_to_end_keele <- output2$distances
  }
  time_end_to_end_keele <- output2$time_taken
  
  cat("end_to_end_modular (Keele) completed get_distances_keele in", time_end_to_end_keele, "seconds.\n")
  
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
