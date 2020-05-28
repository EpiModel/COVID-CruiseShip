
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



# Figure XXa. Network Lockdown Time x PPE ---------------------------------

# show with PPE and no PPE next to each other

sims <- 2000:2013
length(sims)

for (i in seq_along(sims)) {
  fn <- list.files("analysis/data", pattern = paste0("sim.n", as.character(sims[i])),
                   full.names = TRUE)
  load(fn)

  incid <- as.numeric(colSums(sim$epi$se.flow))

  new.df <- data.frame(scenario = sims[i],
                       simno = 1:sim$control$nsims,
                       nlt = sim$param$network.lockdown.time,
                       ppe = sim$param$inf.prob.pc.inter.time,
                       incid = incid)

  if (i == 1) {
    df <- new.df
  } else {
    df <- rbind(df, new.df)
  }

  cat("*")
}

head(df)
table(df$ppe)
df$ppe <- ifelse(df$ppe == Inf, 0, 1)

scaleFUN <- function(x) sprintf("%.1f", x)
breaks = seq(0.5, 2.0, 0.1)
pal <- viridis::viridis(5)
pal <- RColorBrewer::brewer.pal(11, "PRGn")

boxplot(df$incid ~ df$ppe + df$nlt)

ggplot(df, aes(y = as.factor(nlt))) +
  geom_density_ridges(aes(x = incid, fill = paste(as.factor(nlt), ppe)),
                      alpha = 0.75, scale = 3, rel_min_height = 0.01, col = "white", lwd = 0.5) +
  theme_ridges(grid = TRUE) +
  labs(x = "Cumulative Incidence",
       y = "Network Lockdown Time",
       main = "Cumulative Incidence by Network Lockdown Time") +
  scale_x_continuous(breaks = seq(0, 3500, 500)) +
  scale_y_discrete(expand = c(0.01, 0), breaks = c(1, 5, 10, 15, 20, 25, Inf),
                   labels = c("1", "5", "10", "15", "20", "25", "Never")) +
  scale_fill_cyclical(breaks = c("15 0", "15 1"), # This needs to be one value of nlt and each value of ppe
                      labels = c(`15 0` = "No", `15 1` = "Yes"),
                      values = c(pal[2], pal[9], pal[3], pal[10]),
                      name = "PPE", guide = "legend")
ggsave("analysis/Fig-Lockdown-Ridgeline-Dual-Lockdown.pdf", height = 6, width = 12)



# Figure XXb. Asymptomatic Diagnosis Time x PPE ---------------------------

sims <- 6000:6015
length(sims)

for (i in seq_along(sims)) {
  fn <- list.files("analysis/data", pattern = paste0("sim.n", as.character(sims[i])),
                   full.names = TRUE)
  load(fn)

  incid <- as.numeric(colSums(sim$epi$se.flow))

  new.df <- data.frame(scenario = sims[i],
                       simno = 1:sim$control$nsims,
                       dx.start = which.max(sim$param$dx.rate.other),
                       ppe = sim$param$inf.prob.pc.inter.time,
                       incid = incid)

  if (i == 1) {
    df <- new.df
  } else {
    df <- rbind(df, new.df)
  }

  cat("*")
}

head(df)
table(df$ppe)
df$ppe <- ifelse(df$ppe == Inf, 0, 1)

pal <- viridis::viridis(5)
pal <- RColorBrewer::brewer.pal(11, "PRGn")

boxplot(df$incid ~ df$ppe + df$dx.start)

ggplot(df, aes(y = as.factor(dx.start))) +
  geom_density_ridges(aes(x = incid, fill = paste(as.factor(dx.start), ppe)),
                      alpha = 0.75, scale = 3, rel_min_height = 0.01, col = "white", lwd = 0.5) +
  theme_ridges(grid = TRUE) +
  labs(x = "Cumulative Incidence",
       y = "Screening Start Time",
       main = "Cumulative Incidence by Screening Start Time") +
  scale_x_continuous(breaks = seq(0, 3500, 500)) +
  scale_y_discrete(expand = c(0.01, 0), breaks = c(1, 2, 5, 10, 15, 20, 25, 50),
                   labels = c("1", "2", "5", "10", "15", "20", "25", "Never")) +
  scale_fill_cyclical(breaks = c("15 0", "15 1"), # This needs to be one value of nlt and each value of ppe
                      labels = c(`15 0` = "No", `15 1` = "Yes"),
                      values = c(pal[2], pal[9], pal[3], pal[10]),
                      name = "PPE", guide = "legend")
ggsave("analysis/Fig-Lockdown-Ridgeline-Dual-Screening.pdf", height = 6, width = 12)

