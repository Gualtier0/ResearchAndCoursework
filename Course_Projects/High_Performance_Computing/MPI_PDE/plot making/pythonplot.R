library(ggplot2)

data <- data.frame(
  TotNodes = c(3, 5, 9, 17, 3, 5, 9, 17),
  ExecTime = c(13.492113, 7.996458, 4.910835, 3.868155, 
               12.454589, 7.485736, 4.545795, 3.535298),
  NTasks = factor(rep(c(50, 100), each = 4))
)

ggplot(data, aes(x = TotNodes, y = ExecTime, color = NTasks, shape = NTasks)) +
  geom_line() +
  geom_point(size = 3) +
  scale_y_log10() +  
  labs(
    title = "Execution Time vs Total Nodes",
    subtitle = "Constant Number of Tasks",
    x = "Total Nodes",
    y = "Execution Time (seconds) - log scale",
    color = "Number of Tasks",
    shape = "Number of Tasks"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    legend.position = "top"
  )
