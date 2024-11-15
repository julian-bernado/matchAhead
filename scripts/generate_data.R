# generate_data.R

# Load necessary libraries
library(dplyr)

# Function to generate synthetic multilevel data
generate_multilevel_data <- function(S, Ns, p, gsd = 10, ssd = 1){
  # S: Number of groups
  # Ns: Number of units per group (can be a vector for varying sizes)
  # p: Number of covariates
  # gsd: Group-level standard deviation
  # ssd: Unit-level standard deviation
  
  # Initialize the group structure
  unique_groups <- 1:S
  groupmeans <- rnorm(S, mean = 0, sd = gsd)
  
  if(length(Ns) == 1){
    Ns <- rep(Ns, S)
  }
  
  N <- sum(Ns)
  assigned_groups <- rep(unique_groups, times = Ns)
  
  # Initialize the member-level structure within groups
  X <- matrix(rnorm(N * p, mean = 0, sd = 1), nrow = N, ncol = p)
  beta <- rnorm(p, mean = 0, sd = 1)
  
  member_outcomes <- numeric(N)
  for(i in 1:S){
    group_indices <- which(assigned_groups == i)
    group_X <- X[group_indices, ]
    group_member_outcomes <- rnorm(Ns[i], mean = group_X %*% beta + groupmeans[i], sd = ssd)
    member_outcomes[group_indices] <- group_member_outcomes
  }
  
  # Combine covariates and outcomes into a dataframe
  colnames(X) <- paste0("X", 1:p)
  design <- as_tibble(X) %>%
    mutate(Y = member_outcomes) %>%
    mutate(Group = assigned_groups) %>%
    relocate(Y, Group)
  
  return(design)
}

# Updated assign_treatment function
assign_treatment <- function(df, grouping_var, Nt = NULL){
  # df: Data frame containing the data
  # grouping_var: String. Name of the grouping variable in df
  # Nt: Number of groups to assign to treatment. If NULL, defaults to half of the groups.
  
  # Check if the grouping variable exists in the dataframe
  if(!grouping_var %in% colnames(df)){
    stop(paste("Grouping variable", grouping_var, "not found in the data frame."))
  }
  
  # Extract unique groups
  groups <- unique(df[[grouping_var]])
  S <- length(groups)
  
  # Set Nt (number of treated groups)
  if(is.null(Nt)){
    Nt <- floor(S / 2)
    cat(paste("Nt not provided. Defaulting to half of the groups:", Nt, "\n"))
  } else {
    Nt <- as.integer(Nt)
    if(Nt > S){
      stop("Nt cannot be greater than the number of unique groups.")
    }
  }
  
  # Randomly sample Nt groups to assign treatment
  treated_groups <- sample(groups, size = Nt)
  
  # Assign Treatment: 1 for treated groups, 0 for control groups
  df <- df %>%
    mutate(Treatment = if_else(.data[[grouping_var]] %in% treated_groups, 1, 0))
  
  cat(paste("Assigned Treatment to", Nt, "groups out of", S, "total groups.\n"))
  
  return(df)
}
