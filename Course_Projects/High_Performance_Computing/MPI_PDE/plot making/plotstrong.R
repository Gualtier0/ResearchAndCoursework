
library(ggplot2)


data <- data.frame(
  Processes = c(1, 2, 4, 8, 16, 1, 2, 4, 8, 16, 1, 2, 4, 8, 16, 1, 2, 4, 8, 16, 1, 2, 4, 8, 16),
  Workload = c(64, 64, 64, 64, 64, 128, 128, 128, 128, 128, 256, 256, 256, 256, 256, 512, 512, 512, 512, 512, 1024, 1024, 1024, 1024, 1024),
  Time = c(0.0429696, 0.0262603, 0.0176643, 0.0151921, 0.0159796, 
           0.246276, 0.127763, 0.0726001, 0.043761, 0.0329458, 
           1.68201, 0.834925, 0.443614, 0.231714, 0.140266, 
           12.1831, 6.36429, 3.18082, 1.64105, 0.873808, 
           130.813, 69.3894, 44.4021, 34.6044, 17.8132)
)

workloads <- unique(data$Workload)
plots <- list()

for (workload in workloads) {
  workload_data <- subset(data, Workload == workload)
  
  plot <- ggplot(workload_data, aes(x = Processes, y = Time)) +
    geom_line(color = "blue") +
    geom_point(color = "red") +
    scale_x_continuous(breaks = unique(workload_data$Processes)) +
    labs(
      title = paste(" (Workload:", workload, ")"),
      x = "Number of processes",
      y = "Exec. time"
    ) +
    theme_minimal()
  
  plots[[as.character(workload)]] <- plot
}

library(gridExtra)
do.call(grid.arrange, c(plots, ncol = 2))
