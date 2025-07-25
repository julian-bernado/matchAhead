# closeness.R

# Load necessary libraries
library(optmatch)
library(MASS)
library(dplyr)
library(data.table)
library(readr)
library(proxy)   # For distance calculations

# Function to perform closeness analysis
closeness_analysis <- function(output_df, student_data, grouping_var, measures = c("bias", "ess"), unit_vars){
  # output_df: DataFrame containing the pairs of schools and their measures (e.g., bias, ess)
  # student_data: DataFrame containing student-level data with grouping variable and treatment status
  # grouping_var: String, name of the grouping variable (e.g., "Group", "schoolid_state_enroll_p0")
  # measures: Vector of measure names to use for school matching (e.g., c("bias", "ess"))
  # unit_vars: Vector of student-level variables to use for matching
  
  # Step 1: Pair match treated schools to control schools based on measures equally
  # Calculate the combined score for matching (average of specified measures)
  output_df$bias[is.na(output_df$bias)] <- Inf
  output_df$bias <- output_df$bias/max(output_df$bias[!is.infinite(output_df$bias)])
  #output_df$bias <- exp(output_df$bias)
  #output_df$bias <- (output_df$bias - mean(output_df$bias[!is.infinite(output_df$bias)]))/sd(output_df$bias[!is.infinite(output_df$bias)])
  #output_df$bias <- output_df$bias - min(output_df$bias)
  output_df$ess[is.na(output_df$ess)] <- Inf
  output_df$ess <- output_df$ess/max(output_df$ess[!is.infinite(output_df$ess)])
  #output_df$ess <- exp(output_df$ess)
  #output_df$ess <- (output_df$ess - mean(output_df$ess[!is.infinite(output_df$ess)]))/sd(output_df$ess[!is.infinite(output_df$ess)])
  #output_df$ess <- output_df$ess - min(output_df$ess)
  output_df$match_score <- sqrt(output_df$bias*output_df$ess)
  output_df$match_score <- output_df$match_score/max(output_df$match_score[is.finite(output_df$match_score)])
  print(head(output_df))
  print(summary(output_df$match_score[is.finite(output_df$match_score)]))
  
  # Get lists of unique treated and control schools
  treated_schools <- unique(output_df$treatment_group)
  control_schools <- unique(output_df$control_group)
  
  # Create a distance matrix for schools based on match_score
  # Rows are treated schools, columns are control schools
  school_distance_matrix <- matrix(Inf, nrow = length(treated_schools), ncol = length(control_schools),
                                   dimnames = list(treated_schools, control_schools))
  
  # Fill in the distance matrix with match scores
  for(i in 1:nrow(school_distance_matrix)){
	  treatment_school <- rownames(school_distance_matrix)[i]
	  school_distance_matrix[i,] <- output_df %>% filter(treatment_group == treatment_school) %>% pull(match_score)
  }

  
  # Perform pair matching on schools
  print(dimnames(school_distance_matrix))
  school_match <- pairmatch(school_distance_matrix, remove.unmatchables = TRUE) 
  
  # Extract matched pairs of schools
  matched_schools <- data.frame(
    school = names(school_match),
    match_group = as.character(school_match)
  ) %>%
    filter(!is.na(match_group))

  
  # Separate treated and control schools in matched pairs
  matched_schools <- matched_schools %>%
    mutate(treatment_status = ifelse(school %in% treated_schools, "treated", "control"))
  
  # Step 2: Within each matched pair of schools, pair match students on Mahalanobis distance
  # Initialize variables to store results
  total_student_pairs <- 0
  L2_distances <- c()
  
  # For each matched group of schools
  unique_match_groups <- unique(matched_schools$match_group)
  
  i <- 0
  for (group in unique_match_groups) {
    i <- i + 1
    print(i/length(unique_match_groups))
    # Get the treated and control schools in this matched group
    schools_in_group <- matched_schools %>%
      filter(match_group == group)
    
    treated_school <- schools_in_group$school[schools_in_group$treatment_status == "treated"]
    control_school <- schools_in_group$school[schools_in_group$treatment_status == "control"]
    
    # Extract students from each school
    students_treated <- student_data %>%
      filter(schoolid_state_enroll_p0 == treated_school) %>%
      dplyr::select(all_of(unit_vars))
    
    students_control <- student_data %>%
      filter(schoolid_state_enroll_p0 == control_school) %>%
      dplyr::select(all_of(unit_vars))
    
    # Combine data to calculate covariance matrix
    combined_students <- rbind(students_treated, students_control)

    distance_matrix <- proxy::dist(
      x = students_treated,
      y = students_control,
      method = "Euclidean"
    )
    
    # Convert distance matrix to appropriate format
    distance_matrix <- matrix(distance_matrix, nrow = nrow(students_treated), ncol = nrow(students_control))
    rownames(distance_matrix) <- paste0("T_", seq_len(nrow(students_treated)))
    colnames(distance_matrix) <- paste0("C_", seq_len(nrow(students_control)))
    
    # Perform pair matching on students
    student_match <- pairmatch(distance_matrix)
    
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
    matched_schools = matched_schools,
    effective_sample_size = total_student_pairs,
    average_L2_distance = average_L2_distance
  )
  
  return(results)
}

# Example usage:
output_df <- read_csv("outputs/keele_output.csv")
student_data <- read_csv("data/2022_3_glmath_df.csv")
unit_vars <- c("gender_2","specialed_ever","lep_ever",
               paste0("raceth_", 1:6))
results <- closeness_analysis(output_df, student_data, grouping_var = "schoolid_state_enroll_p0", measures = c("bias", "ess"), unit_vars = unit_vars)
save(results, file = "keele_output.RData")
print(results)

output_df <- read_csv("outputs/our_output.csv")
results <- closeness_analysis(output_df, student_data, grouping_var = "schoolid_state_enroll_p0", measures = c("bias", "ess"), unit_vars = unit_vars)
save(results, file = "our_output.RData")
print(results)
