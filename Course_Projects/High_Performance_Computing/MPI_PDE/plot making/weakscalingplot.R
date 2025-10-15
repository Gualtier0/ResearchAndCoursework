
library(ggplot2)

data <- data.frame(
  Threads = c(1, 2, 4, 8, 16, 1, 2, 4, 8, 16, 1, 2, 4, 8, 16),
  Time = c(
    1.64731, 2.15767, 3.18554, 8.79481, 17.7462,  # Baseline 256
    0.242696, 0.30497, 0.438155, 0.574939, 0.85906,  # Baseline 128
    0.0427807, 0.0506674, 0.0747649, 0.0913472, 0.15033  # Baseline 64
  ),
  Baseline = factor(rep(c(256, 128, 64), each = 5))
)

ggplot(data, aes(x = Threads, y = Time, color = Baseline, shape = Baseline)) +
  geom_line() +
  geom_point(size = 3) +
  scale_y_log10() + 
  labs(
    title = "Weak Scaling Performance",
    subtitle = "Constant Work per Thread",
    x = "Number of Threads",
    y = "Time  - log scale",
    color = "Base Resolution",
    shape = "Base Resolution"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    legend.position = "top"
  )
