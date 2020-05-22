
rm(list = ls())
library("EpiModelCOVID")
library("dplyr")
source("analysis/fx.R")
library("ggplot2")
library("ggridges")
library("gridExtra")

base <- list.files("analysis/data", pattern = "2000", full.names = TRUE)
load(base)
sim.base <- sim

sims <- 2000:2006
length(sims)

for (i in seq_along(sims)) {
  fn <- list.files("analysis/data", pattern = paste0("sim.n", as.character(sims[i])),
                   full.names = TRUE)
  load(fn)

  incid <- as.numeric(colSums(sim$epi$se.flow))

  new.df <- data.frame(scenario = sims[i],
                       simno = 1:sim$control$nsims,
                       param = sim$param$network.lockdown.time,
                       incid = incid)

  if (i == 1) {
    df <- new.df
  } else {
    df <- rbind(df, new.df)
  }

  cat("*")
}

table(df$scenario)
table(df$param)
hist(df$incid)

pdf("analysis/Fig-Lockdown-Boxplot.pdf", height = 5, width = 10)
par(mar = c(3,3,2,1), mgp = c(2,1,0))
boxplot(df$incid ~ df$param, outline = FALSE, col = adjustcolor("steelblue", alpha.f = 0.75),
        ylab = "Cumulative Incidence", xlab = "Network Lockdown Time",
        main = "Cumulative Incidence by Network Lockdown Time")
dev.off()

df <- mutate(df, param = factor(param, unique(param)))

ggplot(df, aes(x = incid, y = as.factor(param))) +
  geom_density_ridges(rel_min_height = 0.005, fill = "steelblue", alpha = 0.75, scale = 2) +
  scale_y_discrete(expand = c(0.05, 0)) +
  scale_x_continuous(expand = c(0.05, 0)) +
  theme_ridges() +
  labs(x = "Cumulative Incidence",
       y = "Network Lockdown Time",
       main = "Cumulative Incidence by Network Lockdown Time")
ggsave("analysis/Fig-Lockdown-Ridgeline.pdf", height = 5, width = 10)

