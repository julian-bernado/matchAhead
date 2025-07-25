library(dplyr)
library(future.apply)
source("scripts/maxflow.R")

split_df <- function(df, K) {
  n <- nrow(df)
  indices <- cut(seq_len(n), breaks = K, labels = FALSE)
  split(df, indices)
}

bias_distance <- function(group1, group2, group_preds){
  score1 <- group_preds[school_id == group1, school_score]
  score2 <- group_preds[school_id == group2, school_score]
  abs(score1 - score2)
}

# Optimized `calipered_dist_matrix` function, implemented in C++
cppFunction('
NumericMatrix calipered_dist_matrix(NumericVector ts,
                                    NumericVector cs,
                                    double caliper) {
  int n = ts.size();
  int m = cs.size();
  NumericMatrix out(n, m);
  
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < m; j++) {
      if (fabs(ts[i] - cs[j]) < caliper) {
        out(i, j) = 0;
      } else {
        out(i, j) = NA_REAL;
      }
    }
  }
  return out;
}
')


# Optimized `dist_mat` function, implemented in C++
cppFunction('
NumericMatrix dist_mat(NumericVector ts,
                       NumericVector cs) {
  int n = ts.size();
  int m = cs.size();
  NumericMatrix out(n, m);
  
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < m; j++) {
        out(i, j) = fabs(ts[i] - cs[j]);
    }
  }
  return out;
}
')

variance_measure <- function(treatment_group, control_group, data, group_preds, unit_preds, unit_caliper){
  # Add unit_preds to the dataframe
  df_wscores <- data
  df_wscores$unit_preds <- unit_preds
  
  # Extract predictions for each group
  group1_vals <- unit_preds[school_id == treatment_group, student_score]
  group2_vals <- unit_preds[school_id == control_group, student_score]
  Nt <- length(group1_vals)
  
  # Compute distance matrix with calipers
  distance_matrix <- calipered_dist_matrix(group1_vals, group2_vals, unit_caliper)
  
  # Count valid matches
  num_w_matches <- sum(rowSums(!is.na(distance_matrix)) > 0)
  # Output
  bias = bias_distance(treatment_group, control_group, group_preds)
  if(is.na(bias)){
	print(treatment_group)
  	print(control_group)
	print(group_preds)
  }
  ess <- NA
  if(num_w_matches == 0){
    ess <- Inf
  } 
  # if(num_w_matches < Nt){
  #   if(num_w_matches == 0){
  #     ess <- Inf
  #   } else{
  #     ess <- Nt / num_w_matches
  #   }
  # } else{
  mc <- max_controls(distance_matrix, max.controls = 1)
  ess <- 1/mc
  # }
  
  # Output Matrix
  output <- matrix(c(bias, ess), nrow = 2)
  
  return(output)
}

get_distances <- function(data, pairs_data, unit_preds, group_preds, unit_caliper){
  # Pre-allocate columns
  pairs_data[, `:=`(bias = NA_real_, ess = NA_real_)]
  
  results <- mapply(
    FUN = variance_measure,
    treatment_group = pairs_data$treatment_group,
    control_group = pairs_data$control_group,
    MoreArgs = list(
      data = data,
      unit_preds = unit_preds,
      group_preds = group_preds,
      unit_caliper = unit_caliper
    ),
    SIMPLIFY = TRUE
  )
  
  # Assign results
  pairs_data[, `:=`(
    bias = results[1, ],
    ess = results[2, ]
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

# KEELE CODE

distance_keele <- function(treatment_group, control_group, unit_preds, data){
  
  # Extract predictions for each group
  group1_vals <- unit_preds[school_id == treatment_group, student_score]
  group2_vals <- unit_preds[school_id == control_group, student_score]
  Nt <- length(group1_vals)
  Nc <- length(group2_vals)
  names(group1_vals) <- 1:Nt
  names(group2_vals) <- (Nt+1):(Nt+Nc)
  
  total_vals <- matrix(c(group1_vals, group2_vals), ncol = 1)
  rownames(total_vals) <- 1:(Nt+Nc)
  
  # Compute distance matrix
  distance_matrix <- dist_mat(group1_vals, group2_vals)
  rownames(distance_matrix) <- 1:Nt
  colnames(distance_matrix) <- (Nt+1):(Nt+Nc)
  
  # Pair match
  pairings <- pairmatch(distance_matrix, data = total_vals)
  matched_treated <- group1_vals[!is.na(pairings[1:Nt])]
  matched_controls <- group2_vals[!is.na(pairings[(Nt+1):(Nt+Nc)])]
  
  treatment_sd <- sd(matched_treated)
  control_sd <- sd(matched_controls)
  pooled_sd <- sqrt(((Nt - 1)*treatment_sd^2 + (Nc - 1)*control_sd^2)/(Nt + Nc - 2))
  standardized_difference <- abs((mean(matched_treated) - mean(matched_controls))/pooled_sd)
  
  # Output Matrix
  output <- matrix(c(standardized_difference, 1/length(matched_treated)), nrow = 2)
  
  return(output)
}

get_distances_keele <- function(data, pairs_data, unit_preds) {
  # Pre-allocate columns
  pairs_data[, `:=`(bias = NA_real_, ess = NA_real_)]
  
  # Apply distance_keele and assign directly
  results <- mapply(
    FUN = distance_keele,
    treatment_group = pairs_data$treatment_group,
    control_group = pairs_data$control_group,
    MoreArgs = list(
      data = data,
      unit_preds = unit_preds
    ),
    SIMPLIFY = TRUE
  )
  
  # Assign results
  pairs_data[, `:=`(
    bias = results[1, ],
    ess = results[2, ]
  )]
  
  return(pairs_data)
}

parallel_get_distances_keele <- function(data, pairs_data, unit_preds, K = 1){
  # Split pairs_data into K chunks
  pairs_list <- split_df(pairs_data, K)
  
  # Plan for parallel execution using multiprocess
  plan(multisession, workers = K)
  
  # Function to process one chunk
  process_chunk <- function(chunk){
    get_distances(data = data,
                  pairs_data = chunk,
                  unit_preds = unit_preds)
  }
  
  # Process each chunk in parallel
  result_list <- future_lapply(pairs_list, process_chunk, future.seed = TRUE)
  
  # Combine the results
  result <- bind_rows(result_list)
  
  return(result)
}
