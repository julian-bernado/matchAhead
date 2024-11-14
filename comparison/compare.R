# compare.R

# Load necessary libraries
library(dplyr)
source("scripts/end_to_end.R")
source("scripts/optimal_multilevel.R")

alg1 <- function(data){
  t <- runif(1, min = 0.007, 0.07)
  Sys.sleep(t)
}

alg2 <- function(data){
  t <- runif(1, min = 0.001, 0.01)
  Sys.sleep(t)
}

# Define the compare function
compare <- function(data, proportion, replications) {
  
  # Ensure proportion is between 0 and 1
  if(proportion <= 0 || proportion > 1){
    stop("Proportion must be between 0 and 1.")
  }
  
  # Sample a subset of the data once for this proportion
  set.seed(123)  # For reproducibility
  subset_size <- floor(proportion * length(unique((data$Group))))
  subset_data <- data[sample(nrow(data), size = subset_size), ]
  
  # Prepare results storage
  results <- data.frame(
    replication = integer(replications * 2),
    algorithm = character(replications * 2),
    proportion = numeric(replications * 2),
    time = numeric(replications * 2),
    stringsAsFactors = FALSE
  )
  
  row_index <- 1  # Initialize row index for results
  
  for (i in 1:replications) {
    # Timing alg1
    start_time <- Sys.time()
    alg1_result <- alg1(subset_data)
    end_time <- Sys.time()
    alg1_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
    
    # Store alg1 results
    results[row_index, ] <- list(
      replication = i,
      algorithm = "alg1",
      proportion = proportion,
      time = alg1_time
    )
    row_index <- row_index + 1
    
    # Timing alg2
    start_time <- Sys.time()
    alg2_result <- alg2(subset_data)
    end_time <- Sys.time()
    alg2_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
    
    # Store alg2 results
    results[row_index, ] <- list(
      replication = i,
      algorithm = "alg2",
      proportion = proportion,
      time = alg2_time
    )
    row_index <- row_index + 1
  }
  
  return(results)
}