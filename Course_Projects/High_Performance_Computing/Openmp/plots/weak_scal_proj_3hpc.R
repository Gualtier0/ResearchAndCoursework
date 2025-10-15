
library(ggplot2)
library(ggrepel)  # For adding text labels without overlap

# Load the CSV file
weak_scaling_data <- read.csv("/Users/gualtieromarencoturi/Desktop/h.p.c./proj3/Project_3_MarencoTuri_Gualtiero/plots/weak_scaling_results.csv")

# Create a simple label column with rounded grid sizes for easy labeling
weak_scaling_data$grid_size_label <- round(weak_scaling_data$grid_size, 0)

# Create the plot
plot <- ggplot(weak_scaling_data, aes(x = threads, y = time, color = factor(base_resolution), shape = factor(base_resolution))) +
  geom_line() +
  geom_point(size = 3) +
  scale_y_log10() +  # Logarithmic scale for y-axis
  scale_x_continuous(breaks = unique(weak_scaling_data$threads)) +
  labs(
    title = "Weak Scaling Performance\nConstant Work per Thread",
    x = "Number of Threads",
    y = "Time (seconds) - log scale",
    color = "Base Resolution",
    shape = "Base Resolution"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16),
    axis.title = element_text(size = 14),
    legend.position = "top"
  ) +
  geom_text(aes(label = grid_size_label), vjust = -0.5, size = 3)  # Simple labels above points

# Display the plot
print(plot)