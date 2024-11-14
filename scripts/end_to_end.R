library(dplyr)
library(data.table)
source("scripts/make_grouped.R")
source("scripts/model_outcomes.R")
source("scripts/caliper.R")
source("scripts/get_distances.R")
source("scripts/maxflow.R")


assimilate_df <- function(data, grouping, group_level, unit_level, outcome, treatment){
  if(("Group" %in% colnames(data)) && grouping != "Group"){
    stop("Must not have any column named Group unless it is the grouping variable")
  }
  if(("Y" %in% colnames(data)) && outcome != "Y"){
    stop("Must not have any column named Y unless it is the outcome variable")
  }
  
  data <- data %>%
    rename(Group = sym(grouping)) %>%
    rename(Y = sym(outcome)) %>%
    rename(Treatment = sym(treatment))
  
  return(data)
}

end_to_end <- function(old_data, new_data, grouping, group_level, unit_level, outcome, treatment, num_cores = 1, max_rows_in_memory = 1155000){
  # Read in the data
  old_df <- assimilate_df(old_data, grouping, group_level, unit_level, outcome, treatment)
  old_df <- make_grouped(data = old_df,
                         group_level = group_level,
                         unit_level = unit_level)
  
  new_df <- assimilate_df(new_data, grouping, group_level, unit_level, outcome, treatment)
  new_df <- make_grouped(data = new_df,
                         group_level = group_level,
                         unit_level = unit_level)
  
  # Create model
  unit_model <- model_outcomes(data = old_df)
  unit_caliper <- calc_caliper(model = unit_model)
  print("caliper")
  print(unit_caliper)
  
  # Make new group-level dataframe
  new_group_df <- new_df %>%
    group_by(Group) %>%
    slice_head(n = 1) %>%
    ungroup() %>%
    mutate(across(all_of(unit_level), ~ 0))
  
  groups <- new_group_df %>%
    pull(Group)
  treatments <- new_group_df %>%
    pull(Treatment)
  
  treatment_groups <- groups[as.logical(treatments)]
  control_groups <- groups[!as.logical(treatments)]
  
  num_treatments <- length(treatment_groups)
  num_controls <- length(control_groups)
  
  total_pairs <- num_treatments * num_controls
  cat("Total number of pairs:", total_pairs, "\n")
  
  if (total_pairs > max_rows_in_memory) {
    # The output matrix is too big to hold in memory
    # We need to process in chunks and write to disk
    cat("Total pairs exceed max_rows_in_memory. Processing in batches and writing to disk.\n")
    
    # Determine batch size based on max_rows_in_memory
    batch_size <- floor(max_rows_in_memory / num_controls)
    if (batch_size < 1) {
      batch_size <- 1
    }
    
    # Split the treatment groups into batches
    treatment_batches <- split(treatment_groups, ceiling(seq_along(treatment_groups)/batch_size))
    
    # Get predictions for the new data
    group_preds <- predict(unit_model, newdata = new_group_df)
    names(group_preds) <- groups
    unit_preds <- predict(unit_model, newdata = new_df)
    
    # Initialize an empty list to store file paths
    result_files <- list()
    
    for (i in seq_along(treatment_batches)) {
      cat(paste("Processing batch", i, "of", length(treatment_batches), "\n"))
      
      current_treatments <- treatment_batches[[i]]
      
      dt_treatment <- data.table(treatment_group = current_treatments)
      dt_control <- data.table(control_group = control_groups)
      pairs_dt <- CJ(
        treatment_group = dt_treatment$treatment_group,
        control_group = dt_control$control_group,
        unique = TRUE,
        sorted = FALSE
      )
      
      # Process distances (use parallel processing if applicable)
      if (num_cores > 1) {
        chunk_distances <- parallel_get_distances(data = new_df,
                                                  pairs_data = pairs_dt,
                                                  unit_preds = unit_preds,
                                                  group_preds = group_preds,
                                                  unit_caliper = unit_caliper,
                                                  K = num_cores)
      } else {
        chunk_distances <- get_distances(data = new_df,
                                         pairs_data = pairs_dt,
                                         unit_preds = unit_preds,
                                         group_preds = group_preds,
                                         unit_caliper = unit_caliper)
      }
      
      # Write chunk to disk
      file_name <- paste0("e2e_chunk_", i, ".csv")
      fwrite(chunk_distances, file_name)
      result_files[[i]] <- file_name
    }
    
    # Return list of file paths
    return(result_files)
    
  } else {
    # The output matrix can be held in memory
    cat("Total pairs within memory limit. Processing in memory.\n")
    
    # Get predictions for the new data
    group_preds <- predict(unit_model, newdata = new_group_df)
    names(group_preds) <- groups
    unit_preds <- predict(unit_model, newdata = new_df)
    
    dt_treatment <- data.table(treatment_group = treatment_groups)
    dt_control <- data.table(control_group = control_groups)
    pairs_dt <- CJ(
      treatment_group = dt_treatment$treatment_group,
      control_group = dt_control$control_group,
      unique = TRUE,
      sorted = FALSE
    )
    
    # Use parallel processing
    if (num_cores > 1) {
      final_distances <- parallel_get_distances(data = new_df,
                                                pairs_data = pairs_dt,
                                                unit_preds = unit_preds,
                                                group_preds = group_preds,
                                                unit_caliper = unit_caliper,
                                                K = num_cores)
    } else {
      final_distances <- get_distances(data = new_df,
                                       pairs_data = pairs_dt,
                                       unit_preds = unit_preds,
                                       group_preds = group_preds,
                                       unit_caliper = unit_caliper)
    }
    
    return(final_distances)
  }
}