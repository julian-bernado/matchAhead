library(data.table)
library(dplyr)
library(future.apply)
library(optmatch)
source("scripts/maxflow.R")
source("scripts/generate_data.R")
source("scripts/end_to_end.R")

split_df <- function(df, K) {
  n <- nrow(df)
  indices <- cut(seq_len(n), breaks = K, labels = FALSE)
  split(df, indices)
}

compute_mahalanobis_matrix <- function(X, Y, inv_covar_matrix) {
  A <- rowSums((X %*% inv_covar_matrix) * X)
  B <- rowSums((Y %*% inv_covar_matrix) * Y)
  C <- X %*% inv_covar_matrix %*% t(Y)
  D_sq <- outer(A, B, "+") - 2 * C
  D_sq[D_sq < 0] <- 0
  D <- sqrt(D_sq)
  return(D)
}

score_measure <- function(treatment_group, control_group, data, inv_covar_matrix, L = 1e5){
  treatment_matrix <- as.matrix(data[data$Group == treatment_group, !(colnames(data) %in% c("Y", "Group", "Treatment"))])
  Nt <- nrow(treatment_matrix)
  rownames(treatment_matrix) <- 1:Nt
  control_matrix <- as.matrix(data[data$Group == control_group,!(colnames(data) %in% c("Y", "Group", "Treatment"))])
  Nc <- nrow(control_matrix)
  rownames(control_matrix) <- (Nt+1):(Nt+Nc)
  
  mahal_matrix <- compute_mahalanobis_matrix(treatment_matrix, control_matrix, inv_covar_matrix)
  rownames(mahal_matrix) <- 1:Nt
  colnames(mahal_matrix) <- (Nt+1):(Nt+Nc)
  matching <- pairmatch(mahal_matrix, data = rbind(treatment_matrix, control_matrix))
  
  output <- L - 
  return(1)
}

mlm_distances <- function(data, pairs_data, inv_covar_matrix){
  pairs_data[, `:=`(
    mlm_dist = mapply(
      FUN = score_measure,
      treatment_group,
      control_group,
      MoreArgs = list(data = data, inv_covar_matrix = inv_covar_matrix)
    )
  )]
  
  return(pairs_data)
}

parallel_mlm_distances <- function(data, pairs_data, inv_covar_matrix, K = 1){
  # Split pairs_data into K chunks
  pairs_list <- split_df(pairs_data, K)
  
  # Plan for parallel execution using multiprocess
  plan(multisession, workers = K)
  
  # Function to process one chunk
  process_chunk <- function(chunk){
    mlm_distances(data = data,
                  pairs_data = chunk,
                  inv_covar_matrix = inv_covar_matrix)
  }
  
  # Process each chunk in parallel
  result_list <- future_lapply(pairs_list, process_chunk, future.seed = TRUE)
  
  # Combine the results
  result <- bind_rows(result_list)
  
  return(result)
}

mlm_e2e <- function(data, grouping, group_level, unit_level, outcome, treatment, num_cores = 1, max_rows_in_memory = 1500000){
  # Read in the data
  df <- assimilate_df(data, grouping, group_level, unit_level, outcome, treatment)
  df <- make_grouped(data = df,
                         group_level = group_level,
                         unit_level = unit_level)
  
  # Get covariance matrix
  covar_matrix <- cov(df[, !(colnames(df) %in% c("Y", "Group", "Treatment"))])
  inv_covar_matrix <- solve(covar_matrix)
  
  # Make new group-level dataframe
  group_df <- df %>%
    group_by(Group) %>%
    slice_head(n = 1) %>%
    ungroup() %>%
    mutate(across(all_of(unit_level), ~ 0))
  
  groups <- group_df %>%
    pull(Group)
  treatments <- group_df %>%
    pull(Treatment)
  
  treatment_groups <- groups[as.logical(treatments)]
  control_groups <- groups[!as.logical(treatments)]
  
  num_treatments <- length(treatment_groups)
  num_controls <- length(control_groups)
  
  total_pairs <- num_treatments * num_controls
  cat("Total number of pairs:", total_pairs, "\n")
  
  if (total_pairs > max_rows_in_memory) {
    cat("Total pairs exceed max_rows_in_memory. Processing in batches and writing to disk.\n")
    
    # Determine batch size based on max_rows_in_memory
    batch_size <- floor(max_rows_in_memory / num_controls)
    if (batch_size < 1) {
      batch_size <- 1
    }
    
    # Split the treatment groups into batches
    treatment_batches <- split(treatment_groups, ceiling(seq_along(treatment_groups)/batch_size))
    
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
        chunk_distances <- parallel_mlm_distances(data = df,
                                                  pairs_data = pairs_dt,
                                                  inv_covar_matrix = inv_covar_matrix,
                                                  K = num_cores)
      } else {
        chunk_distances <- mlm_distances(data = df,
                                         pairs_data = pairs_dt,
                                         inv_covar_matrix = inv_covar_matrix)
      }
      
      # Write chunk to disk
      file_name <- paste0("mlm_chunk_", i, ".csv")
      fwrite(chunk_distances, file_name)
      result_files[[i]] <- file_name
    }
    
    # Return list of file paths
    return(result_files)
    
  } else {
    # The output matrix can be held in memory
    cat("Total pairs within memory limit. Processing in memory.\n")
    
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
      final_distances <- parallel_mlm_distances(data = df,
                                                pairs_data = pairs_dt,
                                                inv_covar_matrix = inv_covar_matrix,
                                                K = num_cores)
    } else {
      final_distances <- mlm_distances(data = df,
                                       pairs_data = pairs_dt,
                                       inv_covar_matrix = inv_covar_matrix)
    }
    
    return(final_distances)
  }
}

df <- generate_multilevel_data(100, 10, 8) %>% assign_treatment()
old_df <- generate_multilevel_data(100, 10, 8) %>% assign_treatment()

time1 <- Sys.time()
result <- mlm_e2e(df,
                  grouping = "Group",
                  group_level = c("X1", "X2", "X3", "X4"),
                  unit_level = c("X5", "X6", "X7", "X8"),
                  outcome = "Y",
                  treatment = "Treatment",
                  num_cores = 1)
time2 <- Sys.time()


time3 <- Sys.time()
result <- end_to_end(old_data = old_df, new_data = df,
                  grouping = "Group",
                  group_level = c("X1", "X2", "X3", "X4"),
                  unit_level = c("X5", "X6", "X7", "X8"),
                  outcome = "Y",
                  treatment = "Treatment",
                  num_cores = 1)
time4 <- Sys.time()

print(time2-time1)
print(time4-time3)