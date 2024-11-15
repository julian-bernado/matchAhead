# closeness.R

# Load necessary libraries
library(optmatch)
library(dplyr)
library(data.table)
library(MASS)    # For Mahalanobis distance and generalized inverse
library(proxy)   # For distance calculations

# Function to perform closeness analysis
closeness_analysis <- function(output_df, student_data, grouping_var, measures = c("bias", "ess"), unit_vars){
  # output_df: DataFrame containing the pairs of schools and their measures (e.g., bias, ess)
  # student_data: DataFrame containing student-level data with grouping variable and treatment status
  # grouping_var: String, name of the grouping variable (e.g., "Group", "schoolid_nces_enroll")
  # measures: Vector of measure names to use for school matching (e.g., c("bias", "ess"))
  # unit_vars: Vector of student-level variables to use for matching
  
  # Step 1: Pair match treated schools to control schools based on measures equally
  # Calculate the combined score for matching (average of specified measures)
  output_df <- output_df %>%
    mutate(bias = bias/max(bias)) %>%
    mutate(ess = ess/max(ess)) %>%
    mutate(match_score = rowMeans(across(all_of(measures))))
  
  # Get lists of unique treated and control schools
  treated_schools <- unique(output_df$treatment_group)
  control_schools <- unique(output_df$control_group)
  
  # Create a distance matrix for schools based on match_score
  # Rows are treated schools, columns are control schools
  school_distance_matrix <- matrix(Inf, nrow = length(treated_schools), ncol = length(control_schools),
                                   dimnames = list(treated_schools, control_schools))
  
  # Fill in the distance matrix with match scores
  for(i in seq_len(nrow(output_df))){
    t_school <- output_df$treatment_group[i]
    c_school <- output_df$control_group[i]
    score <- output_df$match_score[i]
    # Assign the score to the corresponding cell in the matrix
    if(t_school %in% treated_schools && c_school %in% control_schools){
      school_distance_matrix[as.character(t_school), as.character(c_school)] <- score
    }
  }
  
  # Convert the distance matrix to a vector suitable for pairmatch
  school_distance_vector <- as.vector(school_distance_matrix)
  names(school_distance_vector) <- paste0(rep(rownames(school_distance_matrix), times = ncol(school_distance_matrix)), "|",
                                          rep(colnames(school_distance_matrix), each = nrow(school_distance_matrix)))
  
  # Create a factor indicating the schools (treated and control)
  school_factor <- factor(c(rownames(school_distance_matrix), colnames(school_distance_matrix)))
  names(school_factor) <- c(rownames(school_distance_matrix), colnames(school_distance_matrix))
  
  # Perform pair matching on schools
  school_match <- pairmatch(school_distance_vector, data = school_factor)
  
  # Extract matched pairs of schools
  matched_schools <- data.frame(
    school = names(school_match),
    match_group = as.character(school_match)
  ) %>%
    filter(!is.na(match_group))
  
  # Separate treated and control schools in matched pairs
  matched_schools <- matched_schools %>%
    mutate(treatment_status = ifelse(school %in% treated_schools, "treated", "control"))
  
  # For each matched group, there should be one treated and one control school
  # Remove any unmatched or improperly matched groups
  matched_groups <- matched_schools %>%
    group_by(match_group) %>%
    filter(n() == 2,
           all(c("treated", "control") %in% treatment_status)) %>%
    ungroup()
  
  # Step 2: Within each matched pair of schools, pair match students on Mahalanobis distance
  # Initialize variables to store results
  total_student_pairs <- 0
  L2_distances <- c()
  
  # For each matched group of schools
  unique_match_groups <- unique(matched_groups$match_group)
  
  for (group in unique_match_groups) {
    # Get the treated and control schools in this matched group
    schools_in_group <- matched_groups %>%
      filter(match_group == group)
    
    treated_school <- schools_in_group$school[schools_in_group$treatment_status == "treated"]
    control_school <- schools_in_group$school[schools_in_group$treatment_status == "control"]
    
    # Extract students from each school
    students_treated <- student_data %>%
      filter(.data[[grouping_var]] == treated_school & Treatment == 1) %>%
      select(all_of(unit_vars))
    
    students_control <- student_data %>%
      filter(.data[[grouping_var]] == control_school & Treatment == 0) %>%
      select(all_of(unit_vars))
    
    # Check if both schools have students
    if (nrow(students_treated) == 0 || nrow(students_control) == 0) {
      next  # Skip if no students in either school
    }
    
    # Combine data to calculate covariance matrix
    combined_students <- rbind(students_treated, students_control)
    cov_matrix <- cov(combined_students)
    
    # Handle singular covariance matrix
    if (det(cov_matrix) == 0) {
      cov_matrix_inv <- ginv(cov_matrix)
    } else {
      cov_matrix_inv <- solve(cov_matrix)
    }
    
    # Compute Mahalanobis distance matrix between students
    distance_matrix <- proxy::dist(
      x = students_treated,
      y = students_control,
      method = "Mahalanobis",
      cov = cov_matrix
    )
    
    # Convert distance matrix to appropriate format
    distance_matrix <- as.matrix(distance_matrix)
    rownames(distance_matrix) <- paste0("T_", seq_len(nrow(students_treated)))
    colnames(distance_matrix) <- paste0("C_", seq_len(nrow(students_control)))
    
    # Flatten the distance matrix into a vector for matching
    distance_vector <- as.vector(distance_matrix)
    names(distance_vector) <- paste0(rep(rownames(distance_matrix), times = ncol(distance_matrix)), "|",
                                     rep(colnames(distance_matrix), each = nrow(distance_matrix)))
    
    # Create a factor indicating the students (treated and control)
    student_factor <- factor(c(rownames(distance_matrix), colnames(distance_matrix)))
    names(student_factor) <- c(rownames(distance_matrix), colnames(distance_matrix))
    
    # Perform pair matching on students
    student_match <- pairmatch(distance_vector, data = student_factor)
    
    # Extract matched pairs
    matched_students <- data.frame(
      student = names(student_match),
      match_group = as.character(student_match)
    ) %>%
      filter(!is.na(match_group))
    
    # Separate treated and control students
    matched_students <- matched_students %>%
      mutate(treatment_status = ifelse(grepl("^T_", student), "treated", "control"))
    
    # For each matched group, ensure one treated and one control student
    valid_student_pairs <- matched_students %>%
      group_by(match_group) %>%
      filter(n() == 2,
             all(c("treated", "control") %in% treatment_status)) %>%
      ungroup()
    
    # Update total student pairs
    num_student_pairs <- length(unique(valid_student_pairs$match_group))
    total_student_pairs <- total_student_pairs + num_student_pairs
    
    # Calculate L2 distances within matched pairs
    for (pair_group in unique(valid_student_pairs$match_group)) {
      students_in_pair <- valid_student_pairs %>%
        filter(match_group == pair_group)
      
      treated_student <- students_in_pair$student[students_in_pair$treatment_status == "treated"]
      control_student <- students_in_pair$student[students_in_pair$treatment_status == "control"]
      
      # Extract student indices
      treated_idx <- as.numeric(sub("T_", "", treated_student))
      control_idx <- as.numeric(sub("C_", "", control_student))
      
      treated_vars <- as.numeric(students_treated[treated_idx, ])
      control_vars <- as.numeric(students_control[control_idx, ])
      
      # Calculate L2 distance
      L2_distance <- sqrt(sum((treated_vars - control_vars)^2))
      L2_distances <- c(L2_distances, L2_distance)
    }
  }
  
  # Calculate average L2 distance
  average_L2_distance <- mean(L2_distances)
  
  # Output results
  results <- list(
    effective_sample_size = total_student_pairs,
    average_L2_distance = average_L2_distance
  )
  
  return(results)
}

# Example usage:
 output_df <- read_csv("outputs/keele_output.csv")
 student_data <- read_csv("../data/2022_3_glmath_regression_ready.csv")
 unit_vars <- c("gender", "specialed", "lep", "raceth_asian",
                "raceth_black", "raceth_hispanic", "raceth_native",
                "raceth_hpi", "raceth_unknown")
 results <- closeness_analysis(output_df, student_data, grouping_var = "schoolid_nces_enroll", measures = c("bias", "ess"), unit_vars = unit_vars)
 print(results)