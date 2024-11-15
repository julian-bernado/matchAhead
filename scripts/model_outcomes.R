library(lme4)

write_formula <- function(data, outcome = "Y", grouping = "Group", group_level, unit_level){
  # Select covariates, excluding outcome and grouping columns
  covars <- c(group_level, unit_level, paste0("avg_", unit_level))
  
  # Construct the left-hand side of the formula
  lhs_formula <- paste0(outcome, " ~ ", "(1 | ", grouping, ") + ")
  
  # Collapse covariates into a single string for the right-hand side
  rhs_formula <- paste(covars, collapse = " + ")
  
  # Return the formula, concatenating lhs and rhs
  return(formula(paste0(lhs_formula, rhs_formula)))
}

model_outcomes <- function(data, outcome = "Y", grouping = "Group", group_level, unit_level){
  mm_formula <- write_formula(data, group_level = group_level, unit_level = unit_level)
  return(lmer(formula = mm_formula,
              data = data))
}
