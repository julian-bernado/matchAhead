# R/student_matching.R
# Student-level full matching within school pairs

#' Match students within a single school pair
#'
#' Uses fullmatch to create matched blocks within a treatment-control school pair.
#'
#' @param treatment_school Treatment school ID
#' @param control_school Control school ID
#' @param student_predictions Data frame with school_id, study_id, student_score
#' @param max_controls Maximum controls per treatment unit (default 5)
#' @return Data frame with study_id, school_id, treatment, match_block
match_students_in_pair <- function(treatment_school, control_school,
                                    student_predictions, max_controls = 5) {

  # Extract students from both schools
  t_students <- student_predictions[student_predictions$school_id == treatment_school, ]
  c_students <- student_predictions[student_predictions$school_id == control_school, ]

  nt <- nrow(t_students)
  nc <- nrow(c_students)

  if (nt == 0 || nc == 0) {
    return(data.frame(
      study_id = character(0),
      school_id = character(0),
      treatment = integer(0),
      match_block = character(0),
      stringsAsFactors = FALSE
    ))
  }

  # Build distance matrix
  dist_mat <- outer(t_students$student_score, c_students$student_score,
                    function(x, y) abs(x - y))
  rownames(dist_mat) <- paste0("T_", t_students$study_id)
  colnames(dist_mat) <- paste0("C_", c_students$study_id)

  # Mean controls
  mean_controls <- floor(nc / nt)
  mean_controls <- max(1, min(mean_controls, max_controls))

  tryCatch({
    # Convert to optmatch distance
    dist_obj <- optmatch::match_on(dist_mat)

    # Run fullmatch
    fm <- optmatch::fullmatch(
      dist_obj,
      min.controls = 1,
      max.controls = max_controls,
      mean.controls = mean_controls,
      data = NULL
    )

    # Parse results
    matched <- !is.na(fm)
    if (sum(matched) == 0) {
      return(data.frame(
        study_id = character(0),
        school_id = character(0),
        treatment = integer(0),
        match_block = character(0),
        stringsAsFactors = FALSE
      ))
    }

    # Build result data frame
    all_names <- names(fm)
    all_blocks <- as.character(fm)

    # Identify treatment vs control students
    is_treatment <- grepl("^T_", all_names)
    study_ids <- sub("^[TC]_", "", all_names)

    result <- data.frame(
      study_id = study_ids[matched],
      school_id = ifelse(is_treatment[matched], treatment_school, control_school),
      treatment = as.integer(is_treatment[matched]),
      match_block = all_blocks[matched],
      stringsAsFactors = FALSE
    )

    return(result)

  }, error = function(e) {
    warning("fullmatch failed for pair ", treatment_school, "-", control_school,
            ": ", e$message)
    return(data.frame(
      study_id = character(0),
      school_id = character(0),
      treatment = integer(0),
      match_block = character(0),
      stringsAsFactors = FALSE
    ))
  })
}

#' Match all students across all matched school pairs
#'
#' Iterates over school pairs and combines results with unique block IDs.
#'
#' @param school_matches Data frame from match_schools()
#' @param student_predictions Data frame with school_id, study_id, student_score
#' @param max_controls Maximum controls per treatment (default 5)
#' @return Data frame with study_id, school_id, treatment, match_block, school_pair_id
match_all_students <- function(school_matches, student_predictions, max_controls = 5) {

  if (nrow(school_matches) == 0) {
    return(data.frame(
      study_id = character(0),
      school_id = character(0),
      treatment = integer(0),
      match_block = character(0),
      school_pair_id = integer(0),
      stringsAsFactors = FALSE
    ))
  }

  all_results <- vector("list", nrow(school_matches))

  for (i in seq_len(nrow(school_matches))) {
    t_school <- school_matches$treatment_school[i]
    c_school <- school_matches$control_school[i]

    pair_result <- match_students_in_pair(
      t_school, c_school, student_predictions, max_controls
    )

    if (nrow(pair_result) > 0) {
      # Create unique block IDs across school pairs
      pair_result$match_block <- paste0("P", i, "_", pair_result$match_block)
      pair_result$school_pair_id <- i
    }

    all_results[[i]] <- pair_result
  }

  # Combine all results
  result <- do.call(rbind, all_results)

  if (is.null(result) || nrow(result) == 0) {
    return(data.frame(
      study_id = character(0),
      school_id = character(0),
      treatment = integer(0),
      match_block = character(0),
      school_pair_id = integer(0),
      stringsAsFactors = FALSE
    ))
  }

  return(result)
}

#' Get summary of student matching results
#'
#' @param student_matches Data frame from match_all_students()
#' @return List with summary statistics
summarize_student_matches <- function(student_matches) {
  if (nrow(student_matches) == 0) {
    return(list(
      n_students = 0,
      n_treatment = 0,
      n_control = 0,
      n_blocks = 0,
      n_school_pairs = 0
    ))
  }

  # Block-level statistics
  block_stats <- aggregate(
    treatment ~ match_block,
    data = student_matches,
    FUN = function(x) c(n_t = sum(x), n_c = sum(1 - x))
  )

  list(
    n_students = nrow(student_matches),
    n_treatment = sum(student_matches$treatment),
    n_control = sum(1 - student_matches$treatment),
    n_blocks = length(unique(student_matches$match_block)),
    n_school_pairs = length(unique(student_matches$school_pair_id)),
    mean_block_size = nrow(student_matches) / length(unique(student_matches$match_block))
  )
}
