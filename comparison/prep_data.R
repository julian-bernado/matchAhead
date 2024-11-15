# Source necessary libraries and scripts
library(readr)
library(dplyr)
source("scripts/generate_data.R")
source("scripts/end_to_end.R")

prep_data <- function(path, S, proportion_treated = 268/3605){
  df <- read_csv(path) %>% select(-any_of(c("studentid_state_enroll")))
  schools <- df %>% pull(schoolid_nces_enroll) %>% unique()
  selected_schools <- sample(schools, size = S)
  df <- df %>%
    filter(schoolid_nces_enroll %in% selected_schools) %>%
    assign_treatment(Nt = max(1, floor(S * proportion_treated)), grouping = "schoolid_nces_enroll")
  return(df)
}
