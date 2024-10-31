library(dplyr)
source("maxflow.R")

bias_distance <- function(group1, group2, group_preds){
  return(abs(group_preds["group1"] - group_preds["group2"]))
}

calipered_dist <- function(x, y, caliper){
  if(abs(x-y) < unit_caliper){
    return(abs(x-y))
  } else{
    return(NA)
  }
}

variance_measure <- function(group1, group2, df, unit_preds, unit_caliper){
  df_wscores <- df %>% mutate(unit_preds = unit_preds)
  
  group1_vals <- df_wscores %>%
    filter(Group == group1) %>%
    pull(unit_preds)
  
  group2_vals <- df_wscores %>%
    filter(Group == group2) %>%
    pull(unit_preds)
  
  distance_matrix <- outer(group1_vals,
                           group2_vals,
                           FUN = calipered_dist(caliper = unit_caliper))
  
  return(maxFlow(distance_matrix, max.controls = 1))
}

get_distances <- function(df, pairs_df, group_model, unit_model, unit_caliper){
  group_df <- df %>%
    group_by(Group) %>%
    slice_head(n = 1) %>%
    ungroup()
  
  groups <- group_df %>%
    pull(Group)
  
  group_preds <- predict(group_model, newdata = group_df)
  names(group_preds) <- groups
  
  unit_preds <- predict(unit_model, newdata = df)
  
  pairs_df <- pairs_df %>%
    mutate(bias = bias_distance(group1,
                                group2,
                                group_preds = group_preds)) %>%
    mutate(ess = variance_measure(group1,
                                  group2,
                                  df = df,
                                  unit_preds = unit_preds,
                                  unit_caliper = unit_caliper))
  return(pairs_df)
}