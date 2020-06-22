
## COVID Cruise Ship Figures

library("EpiModelCOVID")
library("dplyr")
library("ggplot2")
library("viridis")
library("gridExtra")
library("foreach")
library("patchwork")

# Figure 3 ----------------------------------------------------------------

ci_contour_df <- function(sims) {
  doParallel::registerDoParallel(parallel::detectCores()-1)
  df <- foreach(i = seq_along(sims)) %dopar% {
    fn <- list.files("analysis/dat/", pattern = as.character(sims[i]), full.names = TRUE)
    load(fn)
    incid <- unname(colSums(sim$epi$se.flow))
    new.df <- data.frame(scenario = sims[i],
                         incid = incid,
                         dx.start = which.max(sim$param$dx.rate.other),
                         pcr.sens = sim$param$pcr.sens,
                         dii = sim$param$act.rate.dx.inter.rr)
    return(new.df)
  }
  doParallel::stopImplicitCluster()
  df <- do.call("rbind", df)
  return(df)
}

# 5100:5440, 5500:5765
df1 <- ci_contour_df(5100:5440)
df2 <- ci_contour_df(5500:6150)
df3 <- ci_contour_df(6500:7045)

df1 <- df1[sample(1:nrow(df1), nrow(df1)*0.2), ]
df2 <- df2[sample(1:nrow(df2), nrow(df2)*0.1), ]

l1 <- loess(incid ~ dx.start * dii, data = df1)
f1 <- expand.grid(list(dx.start = seq(2, 31, 0.5),
                       dii = seq(0, 1, 0.01)))
f1$incid <- as.numeric(predict(l1, newdata = f1))

l2 <- loess(incid ~ dx.start * pcr.sens, data = df2)
f2 <- expand.grid(list(dx.start = seq(2, 31, 0.5),
                       pcr.sens = seq(0, 1, 0.01)))
f2$incid <- as.numeric(predict(l2, newdata = f2))

l3 <- loess(incid ~ dii * pcr.sens, data = df3)
f3 <- expand.grid(list(dii = seq(0, 0.2, 0.005),
                       pcr.sens = seq(0.75, 1, 0.005)))
f3$incid <- as.numeric(predict(l3, newdata = f3))

save(f1, f2, f3, file = "analysis/Fig3-LoessFits.rda")
load("analysis/Fig3-LoessFits.rda")

p1 <- ggplot(f1, aes(dx.start, dii)) +
  geom_raster(aes(fill = incid), interpolate = TRUE) +
  geom_contour(aes(z = incid), col = "white", alpha = 0.5, lwd = 0.5) +
  theme_minimal() +
  scale_y_continuous(expand = c(0, 0)) +
  scale_x_continuous(expand = c(0, 0)) +
  labs(y = "Diagnosed Isolation Intensity", x = "Mass Screening Start") +
  scale_fill_viridis(discrete = FALSE, alpha = 1, option = "D", direction = 1) +
  theme(legend.title = element_blank())

p2 <- ggplot(f2, aes(dx.start, pcr.sens)) +
  geom_raster(aes(fill = incid), interpolate = TRUE) +
  geom_contour(aes(z = incid), col = "white", alpha = 0.5, lwd = 0.5) +
  theme_minimal() +
  scale_y_continuous(expand = c(0, 0)) +
  scale_x_continuous(expand = c(0, 0)) +
  labs(y = "PCR Sensitivity", x = "Mass Screening Start") +
  scale_fill_viridis(discrete = FALSE, alpha = 1, option = "D", direction = 1) +
  theme(legend.title = element_blank())

filter(f2, pcr.sens == 0.99 & dx.start == 2)

p3 <- ggplot(f3, aes(dii, pcr.sens)) +
  geom_raster(aes(fill = incid), interpolate = TRUE) +
  geom_contour(aes(z = incid), col = "white", alpha = 0.5, lwd = 0.5) +
  theme_minimal() +
  scale_y_continuous(expand = c(0, 0)) +
  scale_x_continuous(expand = c(0, 0)) +
  labs(y = "PCR Sensitivity", x = "Diagnosed Isolation Intensity") +
  scale_fill_viridis(discrete = FALSE, alpha = 1, option = "D", direction = 1) +
  theme(legend.title = element_blank())

filter(f3, pcr.sens == 0.8 & dii == 0.2)

p1 + p2 + p3
ggsave("analysis/Fig3-Contour-3panel.pdf", height = 5, width = 15)


filter(df1, dx.start == 1 & dii == 0) %>%
  summarise(mi = median(incid))

filter(df2, dx.start == 1 & pcr.sens == 0.) %>%
  summarise(mi = median(incid))

filter(df3, dii == 0 & pcr.sens == 1) %>%
  summarise(mi = median(incid))
