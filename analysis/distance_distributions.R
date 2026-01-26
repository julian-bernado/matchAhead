# analysis/distance_distributions.R
# Plot distributions of matchAhead vs Pimentel distances from targets cache

library(targets)
library(ggplot2)
library(dplyr)
library(tidyr)

# Create plots directory
dir.create("plots", showWarnings = FALSE)

# Load all distance targets
grade_subjects <- list(

  c("3", "glmath"),
  c("3", "readng"),
  c("4", "glmath"),
  c("4", "readng"),
  c("5", "glmath"),
  c("5", "readng")
)

# Collect all distance data
all_distances <- lapply(grade_subjects, function(gs) {
  grade <- gs[1]
  subject <- gs[2]

  ma_name <- paste0("dist_matchahead_", grade, "_", subject)
  pim_name <- paste0("dist_pimentel_", grade, "_", subject)

  # Try to load from cache
 tryCatch({
    ma_dist <- tar_read_raw(ma_name)
    pim_dist <- tar_read_raw(pim_name)

    bind_rows(
      ma_dist |>
        mutate(method = "matchAhead", grade = grade, subject = subject),
      pim_dist |>
        mutate(method = "Pimentel", grade = grade, subject = subject)
    )
  }, error = function(e) {
    message("Could not load ", grade, "_", subject, ": ", e$message)
    NULL
  })
}) |> bind_rows()

# Filter to finite distances only
finite_distances <- all_distances |>
 filter(is.finite(distance))

# Plot 1: Overall distribution by method (faceted by grade/subject)
p1 <- ggplot(finite_distances, aes(x = distance, fill = method)) +
  geom_histogram(alpha = 0.6, position = "identity", bins = 50) +
  facet_wrap(~ paste("Grade", grade, subject), scales = "free") +
  scale_fill_manual(values = c("matchAhead" = "#2E86AB", "Pimentel" = "#E94F37")) +
  labs(
    title = "Distribution of School-Pair Distances",
    subtitle = "matchAhead vs Pimentel methods",
    x = "Distance",
    y = "Count",
    fill = "Method"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

ggsave("plots/distance_histogram.png", p1, width = 12, height = 8, dpi = 150)

# Plot 2: Density plot for better comparison
p2 <- ggplot(finite_distances, aes(x = distance, color = method, fill = method)) +
  geom_density(alpha = 0.3) +
  facet_wrap(~ paste("Grade", grade, subject), scales = "free") +
  scale_fill_manual(values = c("matchAhead" = "#2E86AB", "Pimentel" = "#E94F37")) +
  scale_color_manual(values = c("matchAhead" = "#2E86AB", "Pimentel" = "#E94F37")) +
  labs(
    title = "Density of School-Pair Distances",
    subtitle = "matchAhead vs Pimentel methods",
    x = "Distance",
    y = "Density",
    fill = "Method",
    color = "Method"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

ggsave("plots/distance_density.png", p2, width = 12, height = 8, dpi = 150)

# Plot 3: Log-scale comparison (useful if Pimentel has large outliers)
p3 <- ggplot(finite_distances, aes(x = log10(distance + 1), fill = method)) +
  geom_histogram(alpha = 0.6, position = "identity", bins = 50) +
  facet_wrap(~ paste("Grade", grade, subject), scales = "free_y") +
  scale_fill_manual(values = c("matchAhead" = "#2E86AB", "Pimentel" = "#E94F37")) +
  labs(
    title = "Distribution of School-Pair Distances (Log Scale)",
    subtitle = "matchAhead vs Pimentel methods",
    x = "log10(Distance + 1)",
    y = "Count",
    fill = "Method"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

ggsave("plots/distance_histogram_log.png", p3, width = 12, height = 8, dpi = 150)

# Plot 4: Box plot comparison
p4 <- ggplot(finite_distances, aes(x = method, y = distance, fill = method)) +
  geom_boxplot(alpha = 0.7) +
  facet_wrap(~ paste("Grade", grade, subject), scales = "free_y") +
  scale_fill_manual(values = c("matchAhead" = "#2E86AB", "Pimentel" = "#E94F37")) +
  labs(
    title = "Distance Distribution by Method",
    x = "Method",
    y = "Distance",
    fill = "Method"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

ggsave("plots/distance_boxplot.png", p4, width = 12, height = 8, dpi = 150)

# Summary statistics
summary_stats <- finite_distances |>
  group_by(grade, subject, method) |>
  summarise(
    n = n(),
    mean = mean(distance),
    median = median(distance),
    sd = sd(distance),
    min = min(distance),
    max = max(distance),
    q25 = quantile(distance, 0.25),
    q75 = quantile(distance, 0.75),
    .groups = "drop"
  )

print(summary_stats)
