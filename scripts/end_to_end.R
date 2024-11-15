# Load necessary libraries
library(dplyr)
library(data.table)
source("scripts/make_grouped.R")
source("scripts/model_outcomes.R")
source("scripts/caliper.R")
source("scripts/get_distances.R")
source("scripts/maxflow.R")

# Data assimilation function remains the same
assimilate_df <- function(data, grouping, outcome, treatment){
  print(colnames(data))
  data <- data %>%
    rename(Group = !!sym(grouping)) %>%
    rename(Y = !!sym(outcome)) %>%
    rename(Treatment = !!sym(treatment))
  
  return(data)
}

# Helper function to process data, now includes data_grouped argument
process_data <- function(old_data, new_data, grouping, group_level, unit_level, outcome, treatment, data_grouped){
  old_df <- assimilate_df(old_data, grouping, outcome, treatment)
  if(!data_grouped){
    old_df <- make_grouped(data = old_df,
                           group_level = group_level,
                           unit_level = unit_level)
  }
  
  new_df <- assimilate_df(new_data, grouping, outcome, treatment)
  if(!data_grouped){
    new_df <- make_grouped(data = new_df,
                           group_level = group_level,
                           unit_level = unit_level)
  }
  
  return(list(old_df = old_df, new_df = new_df))
}

# Helper functions remain unchanged
generate_pairs <- function(new_group_df){
  groups <- new_group_df$Group
  treatments <- new_group_df$Treatment
  
  treatment_groups <- groups[as.logical(treatments)]
  control_groups <- groups[!as.logical(treatments)]
  
  num_treatments <- length(treatment_groups)
  num_controls <- length(control_groups)
  
  total_pairs <- num_treatments * num_controls
  
  dt_treatment <- data.table(treatment_group = treatment_groups)
  dt_control <- data.table(control_group = control_groups)
  pairs_dt <- CJ(
    treatment_group = dt_treatment$treatment_group,
    control_group = dt_control$control_group,
    unique = TRUE,
    sorted = FALSE
  )
  
  return(list(pairs_dt = pairs_dt, total_pairs = total_pairs, num_treatments = num_treatments, num_controls = num_controls, dt_treatment = dt_treatment, dt_control = dt_control))
}

get_predictions <- function(unit_model, new_df, new_group_df, use_keele){
  unit_preds <- predict(unit_model, newdata = new_df, allow.new.levels = TRUE)
  if(!use_keele){
    group_preds <- predict(unit_model, newdata = new_group_df, allow.new.levels = TRUE)
    names(group_preds) <- new_group_df$Group
  } else {
    group_preds <- NULL
  }
  return(list(unit_preds = unit_preds, group_preds = group_preds))
}

process_distances <- function(data, pairs_data, unit_preds, group_preds, unit_caliper, num_cores, use_keele){
  if (num_cores > 1) {
    if(use_keele){
      distances <- parallel_get_distances_keele(data = data,
                                                pairs_data = pairs_data,
                                                unit_preds = unit_preds,
                                                K = num_cores)
    } else {
      distances <- parallel_get_distances(data = data,
                                          pairs_data = pairs_data,
                                          unit_preds = unit_preds,
                                          group_preds = group_preds,
                                          unit_caliper = unit_caliper,
                                          K = num_cores)
    }
  } else {
    if(use_keele){
      distances <- get_distances_keele(data = data,
                                       pairs_data = pairs_data,
                                       unit_preds = unit_preds)
    } else {
      distances <- get_distances(data = data,
                                 pairs_data = pairs_data,
                                 unit_preds = unit_preds,
                                 group_preds = group_preds,
                                 unit_caliper = unit_caliper)
    }
  }
  return(distances)
}

# Merged and modularized end_to_end function with data_grouped argument
end_to_end <- function(old_data, new_data, grouping, group_level, unit_level, outcome, treatment, num_cores = 1, max_rows_in_memory = 1500000, use_keele = FALSE, data_grouped = FALSE){
  # Process data with data_grouped option
  data_list <- process_data(old_data, new_data, grouping, group_level, unit_level, outcome, treatment, data_grouped)
  old_df <- data_list$old_df
  new_df <- data_list$new_df
  
  # Create model
  unit_model <- model_outcomes(data = old_df)
  
  # Calculate caliper if not using Keele method
  if(!use_keele){
    unit_caliper <- calc_caliper(model = unit_model)
    print("caliper")
    print(unit_caliper)
  } else {
    unit_caliper <- NULL
  }
  
  # Create group-level dataframe
  new_group_df <- new_df %>%
    group_by(Group) %>%
    slice_head(n = 1) %>%
    ungroup() %>%
    mutate(across(all_of(unit_level), ~ 0))
  
  # Generate pairs
  pairs_info <- generate_pairs(new_group_df)
  pairs_dt <- pairs_info$pairs_dt
  total_pairs <- pairs_info$total_pairs
  num_treatments <- pairs_info$num_treatments
  num_controls <- pairs_info$num_controls
  
  cat("Total number of pairs:", total_pairs, "\n")
  
  # Get predictions
  preds <- get_predictions(unit_model, new_df, new_group_df, use_keele)
  unit_preds <- preds$unit_preds
  group_preds <- preds$group_preds
  
  if (total_pairs > max_rows_in_memory) {
    # Process in batches and write to disk
    cat("Total pairs exceed max_rows_in_memory. Processing in batches and writing to disk.\n")
    batch_size <- floor(max_rows_in_memory / num_controls)
    batch_size <- max(batch_size, 1)
    
    treatment_groups <- pairs_info$dt_treatment$treatment_group
    treatment_batches <- split(treatment_groups, ceiling(seq_along(treatment_groups)/batch_size))
    
    result_files <- list()
    
    for (i in seq_along(treatment_batches)) {
      cat(paste("Processing batch", i, "of", length(treatment_batches), "\n"))
      
      current_treatments <- treatment_batches[[i]]
      
      dt_treatment <- data.table(treatment_group = current_treatments)
      dt_control <- data.table(control_group = pairs_info$dt_control$control_group)
      pairs_dt <- CJ(
        treatment_group = dt_treatment$treatment_group,
        control_group = dt_control$control_group,
        unique = TRUE,
        sorted = FALSE
      )
      
      # Process distances
      chunk_distances <- process_distances(data = new_df,
                                           pairs_data = pairs_dt,
                                           unit_preds = unit_preds,
                                           group_preds = group_preds,
                                           unit_caliper = unit_caliper,
                                           num_cores = num_cores,
                                           use_keele = use_keele)
      
      # Write chunk to disk
      file_name <- if(use_keele) {
        paste0("e2e_chunk_keele_", i, ".csv")
      } else {
        paste0("e2e_chunk_", i, ".csv")
      }
      fwrite(chunk_distances, file_name)
      result_files[[i]] <- file_name
    }
    
    # Return list of file paths
    return(result_files)
    
  } else {
    # Process in memory
    cat("Total pairs within memory limit. Processing in memory.\n")
    
    # Process distances
    final_distances <- process_distances(data = new_df,
                                         pairs_data = pairs_dt,
                                         unit_preds = unit_preds,
                                         group_preds = group_preds,
                                         unit_caliper = unit_caliper,
                                         num_cores = num_cores,
                                         use_keele = use_keele)
    
    return(final_distances)
  }
}
