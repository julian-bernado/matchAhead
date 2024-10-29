library(lme4)

write_formula <- function(data, outcome, grouping){
  # Select covariates, excluding outcome and grouping columns
  covars <- data %>%
    select(-all_of(c(outcome, grouping))) %>%
    names()
  
  # Construct the left-hand side of the formula
  lhs_formula <- paste0(outcome, " ~ ", "(1 | ", grouping, ") + ")
  
  # Collapse covariates into a single string for the right-hand side
  rhs_formula <- paste(covars, collapse = " + ")
  
  # Return the formula, concatenating lhs and rhs
  return(formula(paste0(lhs_formula, rhs_formula)))
}

model_outcomes <- function(data, outcome, grouping){
  mm_formula <- write_formula(data, outcome, grouping)
  return(lmer(formula = mm_formula,
              data = data))
}