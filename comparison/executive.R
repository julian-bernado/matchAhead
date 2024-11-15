# executive.R

# Load necessary libraries
library(dplyr)
library(data.table)
library(readr)

# Source required scripts
source("scripts/generate_data.R")
source("comparison/prep_data.R")
source("comparison/compare.R")

# Define the synthetic data flag
synthetic <- FALSE  # Set to FALSE to use real/prepared data

if(synthetic){
  cat("Generating synthetic data...\n")
  
  # Define parameters for synthetic data generation
  S <- 50            # Number of groups
  Ns <- 50            # Number of units per group (can be a vector for varying sizes)
  p <- 5              # Number of covariates
  gsd <- 10           # Group standard deviation
  ssd <- 1            # Unit standard deviation
  
  # Generate old_data
  cat("Generating old_data...\n")
  old_data <- generate_multilevel_data(S = S, Ns = Ns, p = p, gsd = gsd, ssd = ssd)
  old_data <- assign_treatment(old_data, Nt = floor(S * 0.5))  # Example: 50% treated
  
  # Generate new_data
  cat("Generating new_data...\n")
  new_data <- generate_multilevel_data(S = S, Ns = Ns, p = p, gsd = gsd, ssd = ssd)
  new_data <- assign_treatment(new_data, Nt = floor(S * 0.5))  # Example: 50% treated
  
} else {
  cat("Preparing real data...\n")
  
  # Define parameters for data preparation
  old_path <- "../data/2021_3_glmath_regression_ready.csv"
  new_path <- "../data/2022_3_glmath_regression_ready.csv"
  S <- 100                          # Number of groups to sample
  proportion_treated <- 268/3605     # Example proportion
  
  # Prepare old_data
  cat("Preparing old_data...\n")
  old_data <- prep_data(path = old_path, S = S, proportion_treated = proportion_treated)
  
  # Prepare new_data
  cat("Preparing new_data...\n")
  new_data <- prep_data(path = new_path, S = S, proportion_treated = proportion_treated)
}

# Define parameters for the compare function
grouping <- "Group"                     # The grouping variable name
group_level <- c()                  # The group level (same as grouping in this context)
unit_level <- paste0("gender","specialed","lep","raceth_asian","raceth_black","raceth_hispanic","raceth_native","raceth_hpi","raceth_unknown","avg_gender","avg_lep","avg_specialed","avg_raceth_asian","avg_raceth_black","avg_raceth_hispanic","avg_raceth_native","avg_raceth_hpi", "avg_raceth_unknown")         # Assuming unit_level corresponds to covariates
outcome <- "glmath_scr"                           # Outcome variable name
treatment <- "Treatment"                 # Treatment variable name

# Define additional parameters
num_cores <- 1                           # Number of cores for parallel processing
max_rows_in_memory <- 1500000            # Maximum rows to hold in memory
data_grouped <- TRUE                    # Set to TRUE if data is already grouped

# Run the compare function
cat("Running compare function...\n")
comparison_result <- compare(
  old_data = old_data,
  new_data = new_data,
  grouping = grouping,
  group_level = group_level,
  unit_level = unit_level,
  outcome = outcome,
  treatment = treatment,
  num_cores = num_cores,
  max_rows_in_memory = max_rows_in_memory,
  data_grouped = data_grouped
)

# Function to display first 100 rows
display_first_100 <- function(output, name){
  if(is.data.frame(output)){
    cat(paste("\nFirst 100 rows of", name, ":\n"))
    print(head(output, 100))
  } else if(is.list(output)){
    cat(paste("\nFirst 100 rows of", name, "from each file:\n"))
    for(i in seq_along(output)){
      cat(paste("File:", output[[i]], "\n"))
      df <- fread(output[[i]], nrows = 100)
      print(df)
      cat("\n")
    }
  } else {
    cat(paste("\n", name, "is neither a dataframe nor a list of file paths.\n"))
  }
}

# Display the first 100 rows of output_end_to_end
display_first_100(comparison_result$output_end_to_end, "output_end_to_end")

# Display the first 100 rows of output_end_to_end_keele
display_first_100(comparison_result$output_end_to_end_keele, "output_end_to_end_keele")

# Print the time per pair metrics
cat("\nTime per pair for end_to_end (standard):", comparison_result$time_end_to_end_per_pair, "seconds.\n")
cat("Time per pair for end_to_end_keele:", comparison_result$time_end_to_end_keele_per_pair, "seconds.\n")
cat("Fraction of Time:", 100*(comparison_result$time_end_to_end_per_pair/comparison_result$time_end_to_end_keele_per_pair), "%")
