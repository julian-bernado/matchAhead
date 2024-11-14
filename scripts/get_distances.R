library(dplyr)
library(future.apply)
source("scripts/maxflow.R")

split_df <- function(df, K) {
  n <- nrow(df)
  indices <- cut(seq_len(n), breaks = K, labels = FALSE)
  split(df, indices)
}

bias_distance <- function(group1, group2, group_preds){
  return(abs(group_preds[group1] - group_preds[group2]))
}

calipered_dist <- function(x, y, caliper){
  caliper <- as.numeric(caliper)
  if(abs(x-y) < caliper){
    return(0)
  } else{
    return(NA)
  }
}

variance_measure <- function(treatment_group, control_group, data, unit_preds, unit_caliper){
  # Add unit_preds to the dataframe
  df_wscores <- data
  df_wscores$unit_preds <- unit_preds
  
  # Extract predictions for each group
  group1_vals <- df_wscores$unit_preds[df_wscores$Group == treatment_group]
  group2_vals <- df_wscores$unit_preds[df_wscores$Group == control_group]
  
  Nt <- length(group1_vals)
  
  # Compute distance matrix with caliper
  distance_matrix <- outer(group1_vals, group2_vals, 
                           Vectorize(function(x, y) calipered_dist(x, y, caliper = unit_caliper)))
  
  # Count valid matches
  num_w_matches <- sum(rowSums(!is.na(distance_matrix)) > 0)
  
  if(num_w_matches < Nt){
    if(num_w_matches == 0){
      return(Nt)
    }
    return(Nt / num_w_matches)
  } else{
    mc <- max_controls(distance_matrix, max.controls = 1)
    return(1/mc)
  }
}

get_distances <- function(data, pairs_data, unit_preds, group_preds, unit_caliper){
  pairs_data[, `:=`(
    bias = mapply(
      FUN = bias_distance,
      treatment_group,
      control_group,
      MoreArgs = list(group_preds = group_preds)
    ),
    ess = mapply(
      FUN = variance_measure,
      treatment_group,
      control_group,
      MoreArgs = list(
        data = data,
        unit_preds = unit_preds,
        unit_caliper = unit_caliper
      )
    )
  )]
  
  return(pairs_data)
}

parallel_get_distances <- function(data, pairs_data, unit_preds, group_preds, unit_caliper, K = 1){
  # Split pairs_data into K chunks
  pairs_list <- split_df(pairs_data, K)
  
  # Plan for parallel execution using multiprocess
  plan(multisession, workers = K)
  
  # Function to process one chunk
  process_chunk <- function(chunk){
    get_distances(data = data,
                  pairs_data = chunk,
                  unit_preds = unit_preds,
                  group_preds = group_preds,
                  unit_caliper = unit_caliper)
  }
  
  # Process each chunk in parallel
  result_list <- future_lapply(pairs_list, process_chunk, future.seed = TRUE)
  
  # Combine the results
  result <- bind_rows(result_list)
  
  return(result)
}