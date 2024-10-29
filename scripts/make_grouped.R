library(dplyr)

make_grouped <- function(data, grouping, group_level, unit_level, outcome) {
  # Combine all relevant covariates including the outcome
  all_covars <- c(grouping, group_level, unit_level, outcome)
  
  # Check if all specified columns exist in the data
  missing_cols <- setdiff(all_covars, names(data))
  if(length(missing_cols) > 0){
    stop(paste("The following columns are missing in the data:", paste(missing_cols, collapse = ", ")))
  }
  
  # Select only the necessary columns
  df <- data %>%
    select(all_of(all_covars))
  
  # Identify numeric unit-level variables for processing
  numeric_unit_level <- df %>%
    select(all_of(unit_level)) %>%
    select(where(is.numeric)) %>%
    names()
  
  # Warn if some unit_level variables are non-numeric and will be excluded
  non_numeric <- setdiff(unit_level, numeric_unit_level)
  if(length(non_numeric) > 0){
    warning(paste("The following unit_level variables are non-numeric and will be excluded from deviation calculations:", 
                  paste(non_numeric, collapse = ", ")))
  }
  
  # Convert grouping variable to symbol for tidy evaluation
  grouping_sym <- sym(grouping)
  
  # Step 1: Calculate group-wise averages and create new avg_* columns
  avg_df <- df %>%
    group_by(!!grouping_sym) %>%
    summarise(across(
      all_of(numeric_unit_level),
      ~ mean(.x, na.rm = TRUE),
      .names = "avg_{col}"
    )) %>%
    ungroup()
  
  # Step 2: Join the averages back to the original dataframe
  df_with_avg <- df %>%
    left_join(avg_df, by = grouping)
  
  # Step 3: Overwrite original unit-level columns with deviations
  for(col in numeric_unit_level){
    avg_col <- paste0("avg_", col)
    df_with_avg <- df_with_avg %>%
      mutate(!!sym(col) := .data[[col]] - .data[[avg_col]])
  }
  
  return(df_with_avg)
}