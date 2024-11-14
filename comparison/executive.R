# executive.R
#source("scripts/prep_data.R")
source("comparison/compare.R")
source("comparison/save_results.R")

#data <- prep_data("path/to/raw_data.csv")
all_results <- data.frame()
proportions <- seq(0.1, 1.0, by = 0.1)
replications <- 100

for (prop in proportions) {
  cat("Running comparison for proportion:", prop, "\n")
  temp_results <- compare(data, proportion = prop, replications = replications)
  all_results <- rbind(all_results, temp_results)
}


write.csv(all_results, "all_comparison_results.csv", row.names = FALSE)
save_plot(all_results, output_path = "comparison/plots/performance_comparison_plot.png")
save_summary_table(all_results, output_path = "comparison/tables/performance_summary_table.csv")