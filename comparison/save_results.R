# save_results.R

# Load necessary libraries
library(ggplot2)
library(dplyr)
library(tidyr)

# Function to generate and save the performance comparison plot
save_plot <- function(results, output_path = "comparison_plot.png") {
  # Calculate summary statistics
  summary_stats <- results %>%
    group_by(proportion, algorithm) %>%
    summarise(
      mean_time = mean(time),
      min_time = min(time),
      max_time = max(time),
      .groups = 'drop'
    )
  
  # Generate the plot
  plot <- ggplot(results, aes(x = factor(proportion), y = time, fill = algorithm)) +
    geom_boxplot(alpha = 0.6, position = position_dodge(width = 0.8)) +
    stat_summary(aes(color = algorithm), fun = mean, geom = "point", shape = 18, size = 3, position = position_dodge(width = 0.8)) +
    stat_summary(aes(color = algorithm), fun = min, geom = "errorbar", width = 0.2, position = position_dodge(width = 0.8)) +
    stat_summary(aes(color = algorithm), fun = max, geom = "errorbar", width = 0.2, position = position_dodge(width = 0.8)) +
    labs(title = "Performance Comparison of Algorithms",
         x = "Proportion of Dataset",
         y = "Execution Time (seconds)",
         fill = "Algorithm",
         color = "Algorithm") +
    theme_minimal()
  
  # Save the plot
  ggsave(filename = output_path, plot = plot, width = 10, height = 6, dpi = 300)
  
  cat("Plot saved to", output_path, "\n")
}

# Function to generate and save the summary table
save_summary_table <- function(results, output_path = "summary_table.csv") {
  
  # Calculate summary statistics
  summary_table <- results %>%
    group_by(proportion, algorithm) %>%
    summarise(
      mean_time = mean(time),
      min_time = min(time),
      max_time = max(time),
      .groups = 'drop'
    ) %>%
    pivot_wider(names_from = algorithm, values_from = c(mean_time, min_time, max_time)) %>%
    mutate(
      alg1_over_alg2 = mean_time_alg1 / mean_time_alg2
    )
  
  # Save the summary table
  write.csv(summary_table, output_path, row.names = FALSE)
  
  cat("Summary table saved to", output_path, "\n")
}

# Example usage (to be placed in your executive script):
# source("save_results.R")
# save_plot(combined_results, "my_comparison_plot.png")
# save_summary_table(combined_results, "summary_table.csv")