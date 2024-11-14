library(lme4)

conditional_var <- function(model){
  # Extract model terms
  fixed_var <- vcov(model)
  n <- getME(model, "n")
  p <- getME(model, "p")
  q <- getME(model, "q")
  X <- getME(model, "X")
  Z <- getME(model, "Z")
  C <- cbind(X,Z)
  var_g <- as.data.frame(VarCorr(model))[1,4]
  var_e <- as.data.frame(VarCorr(model))[2,4]
  
  # Calculate relevant quantities
  G_inv <- (var_g)^(-1) * diag(nrow = q)
  B <- bdiag(matrix(0, nrow = p, ncol = p), G_inv)
  
  meat <- (var_e)^(-1) * t(C) %*% C
  bread <- solve(meat + B)
  
  conditional_covar <- bread %*% meat %*% bread
  return(conditional_covar)
}

get_se <- function(model){
  # Extract model information
  conditional_var <- conditional_var(model)
  n <- getME(model, "n")
  X <- getME(model, "X")
  Z <- getME(model, "Z")
  Y <- cbind(X,Z)
  
  # Calculate relevant quantities
  trace_term <- sum(diag(conditional_var %*% t(Y) %*% Y))
  Y_sum <- colSums(Y)
  cross_term <- t(Y_sum) %*% conditional_var %*% Y_sum 
  unnormalized_expression <- n * trace_term - cross_term
  
  # Return result
  return(sqrt(unnormalized_expression / choose(n,2)))
}

calc_caliper <- function(model){
  n <- getME(model, "n")
  se <- get_se(model)
  zstar <- sqrt(2*log(2*n))
  return(zstar * se)
}