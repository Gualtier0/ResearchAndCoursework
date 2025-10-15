
  library(ggplot2)

scaling_data <- read.csv("/Users/gualtieromarencoturi/Desktop/h.p.c./proj3/Project_3_MarencoTuri_Gualtiero/strong_scaling_results.csv")
plot <- ggplot(scaling_data, aes(x = threads, y = time)) +
  geom_line() +
  geom_point() +
  scale_x_continuous(breaks = unique(scaling_data$threads)) +
  labs(
    title = "Execution Time vs Number of Threads for Each Size",
    x = "Number of Threads",
    y = "Execution Time (seconds)"
  ) +
  theme_minimal() +
  facet_wrap(~ size, scales = "free_y")
print(plot)


