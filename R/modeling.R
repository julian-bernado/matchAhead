# R/modeling.R
# Model fitting and caliper calculation functions

#' Fit prognostic model using lmer
#'
#' Fits a linear mixed-effects model with school random intercepts
#' for predicting student outcomes.
#'
#' @param data Cleaned data frame from create_dataset()
#' @param grade Grade level
#' @param subject Subject name
#' @return Fitted lmer model object
fit_prognostic_model <- function(data, grade, subject) {
  model_formula <- write_formula(data, grade, subject)

  model <- lme4::lmer(
    formula = model_formula,
    data = data,
    REML = TRUE
  )

  return(model)
}

#' Save fitted model to file
#'
#' @param model Fitted lmer model
#' @param grade Grade level
#' @param subject Subject name
#' @param year Model year
#' @param output_dir Output directory (default "models")
#' @return File path where model was saved
save_model <- function(model, grade, subject, year, output_dir = "models") {
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  grade_name <- write_grade(grade)
  filename <- paste0("tx", year, "_", subject, "_gr", grade_name, "_model.rds")
  filepath <- file.path(output_dir, filename)

  saveRDS(model, file = filepath)
  return(filepath)
}

#' Calculate conditional variance-covariance matrix
#'
#' @param model Fitted lmer model
#' @return Conditional covariance matrix
conditional_var <- function(model) {
  fixed_var <- vcov(model)
  n <- lme4::getME(model, "n")
  p <- lme4::getME(model, "p")
  q <- lme4::getME(model, "q")
  X <- lme4::getME(model, "X")
  Z <- lme4::getME(model, "Z")
  C <- cbind(X, Z)
  var_g <- as.data.frame(lme4::VarCorr(model))[1, 4]
  var_e <- as.data.frame(lme4::VarCorr(model))[2, 4]

  # Handle singular models (var_g near zero)
  if (is.na(var_g) || var_g < 1e-10) {
    warning("Model is singular (near-zero random effect variance). Using fixed effects only.")
    var_g <- 1e-10  # Small regularization
  }

  G_inv <- (var_g)^(-1) * Matrix::Diagonal(n = q)
  B <- Matrix::bdiag(matrix(0, nrow = p, ncol = p), G_inv)

  # Use Matrix::t() for sparse matrix transpose
  meat <- (var_e)^(-1) * Matrix::t(C) %*% C

  # Use tryCatch for solve in case of singularity
  bread <- tryCatch({
    solve(meat + B)
  }, error = function(e) {
    warning("Matrix inversion failed, using pseudoinverse")
    MASS::ginv(as.matrix(meat + B))
  })

  conditional_covar <- bread %*% meat %*% bread
  return(conditional_covar)
}

#' Get standard error for caliper calculation
#'
#' @param model Fitted lmer model
#' @return Standard error value
get_se <- function(model) {
  cond_var <- conditional_var(model)
  n <- lme4::getME(model, "n")
  X <- lme4::getME(model, "X")
  Z <- lme4::getME(model, "Z")
  Y <- cbind(X, Z)

  # Old procedure that gave memory error on full run:
  # ---
  # Efficient trace calculation using identity
  # trace(A %*% t(Y) %*% Y) = sum((Y %*% A) * Y)
  # This avoids creating the n×n matrix
  # temp <- Y %*% cond_var
  # trace_term <- sum(temp * Y)
  # ---
  # New correct procedure:
  # trace(A %*% Y'Y) = sum(A * Y'Y) since both A and Y'Y are symmetric.
  # crossprod(Y) is (p+q) x (p+q) instead of the n x (p+q) intermediate from Y %*% A
  trace_term <- sum(cond_var * Matrix::crossprod(Y))

  Y_sum <- Matrix::colSums(Y)
  cross_term <- as.numeric(t(Y_sum) %*% cond_var %*% Y_sum)
  unnormalized_expression <- n * trace_term - cross_term

  return(sqrt(unnormalized_expression / choose(n, 2)))
}

#' Calculate caliper value from fitted model
#'
#' The caliper is based on the standard error of predicted scores
#' scaled by the Bonferroni correction factor.
#'
#' @param model Fitted lmer model
#' @return Scalar caliper value
calculate_caliper <- function(model) {
  n <- lme4::getME(model, "n")
  se <- get_se(model)
  zstar <- sqrt(2 * log(2 * n))
  caliper <- zstar * se

  # Return as scalar (may be returned as 1x1 matrix)
  if (is.matrix(caliper)) {
    caliper <- caliper[1, 1]
  }

  return(caliper)
}

#' Save caliper to file
#'
#' @param caliper Caliper value
#' @param grade Grade level
#' @param subject Subject name
#' @param year Model year
#' @param output_dir Output directory (default "calipers")
#' @return File path where caliper was saved
save_caliper <- function(caliper, grade, subject, year, output_dir = "calipers") {
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  grade_name <- write_grade(grade)
  filename <- paste0("tx", year, "_", subject, "_gr", grade_name, "_caliper.rds")
  filepath <- file.path(output_dir, filename)

  saveRDS(caliper, file = filepath)
  return(filepath)
}
