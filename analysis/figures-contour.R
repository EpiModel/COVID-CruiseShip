
## COVID Cruise Ship Figures

library("EpiModelCOVID")
library("dplyr")
library("ggplot2")
library("viridis")
library("gridExtra")


# Figure 2 ----------------------------------------------------------------

# Run on Hyak

pia_contour_df <- function(sim.base, cf.sims, years = 10) {
  fn.base <- list.files("data/", pattern = sim.base, full.names = TRUE)
  load(fn.base)
  sim.base <- sim
  incid.base <- unname(colSums(sim.base$epi$incid[1:(years*52), ]))
  sims <- cf.sims
  doParallel::registerDoParallel(parallel::detectCores())
  df <- foreach(i = seq_along(sims)) %dopar% {
    fn <- list.files("data/", pattern = as.character(sims[i]), full.names = TRUE)
    load(fn)
    incid.comp <- unname(colSums(sim$epi$incid[1:(years*52), ]))
    vec.nia <- incid.base - incid.comp
    vec.pia <- vec.nia/incid.base
    pia <- median(vec.pia)
    new.df <- data.frame(scenario = sims[i],
                         p1 = sim$param$MULT1,
                         p2 = sim$param$MULT2,
                         pia = pia)
    return(new.df)
  }
  doParallel::stopImplicitCluster()
  df <- do.call("rbind", df)
  return(df)
}

f1a10 <- pia_contour_df(sim.base = "6000", cf.sims = 6001:6099, years = 10)
f1a5 <- pia_contour_df(sim.base = "6000", cf.sims = 6001:6099, years = 5)
f1b10 <- pia_contour_df(sim.base = "6100", cf.sims = 6101:6199, years = 10)
f1b5 <- pia_contour_df(sim.base = "6100", cf.sims = 6101:6199, years = 5)

save(f1a10, f1a5, f1b10, f1b5, file = "data/Fig2-data.rda")

system("scp mox:/gscratch/csde/sjenness/combprev/data/Fig2-data.rda analysis/")

# Graphics Locally
rm(list = ls())
load("analysis/Fig2-data.rda")

# Figure 1

loess1a <- loess(pia ~ p1 * p2, data = f1a10)
fit1a <- expand.grid(list(p1 = seq(1, 10, 0.1),
                          p2 = seq(1, 10, 0.1)))
fit1a$pia <- as.numeric(predict(loess1a, newdata = fit1a))

loess1b <- loess(pia ~ p1 * p2, data = f1b10)
fit1b <- expand.grid(list(p1 = seq(1, 10, 0.1),
                          p2 = seq(1, 10, 0.1)))
fit1b$pia <- as.numeric(predict(loess1b, newdata = fit1b))

fit1a$LNT = "PrEP Linked"
fit1b$LNT = "PrEP Unlinked"
fit1 <- rbind(fit1a, fit1b)

tail(arrange(filter(fit1, LNT == "PrEP Linked"), pia), 10)
tail(arrange(filter(fit1, LNT == "PrEP Unlinked"), pia), 10)

f2 <- ggplot(fit1, aes(p1, p2)) +
  geom_raster(aes(fill = pia), interpolate = TRUE) +
  geom_contour(aes(z = pia), col = "white", alpha = 0.5, lwd = 0.5) +
  theme_minimal() +
  facet_grid(cols = vars(LNT)) +
  scale_y_continuous(expand = c(0, 0)) +
  scale_x_continuous(expand = c(0, 0)) +
  labs(y = "Relative Retention", x = "Relative Screening") +
  scale_fill_viridis(discrete = FALSE, alpha = 1, option = "D", direction = 1)
f2

pdf(file = "analysis/fig/Figure2.pdf", height = 6, width = 10)
f2
dev.off()

pdf(file = "analysis/fig/Figure2-prez.pdf", height = 6*0.75, width = 10*0.75)
f2
dev.off()

# numerical analysis of range

head(fit1)
filter(fit1, p1 == 10 & p2 == 10)


# Supp Figure 2

loess1a <- loess(pia ~ p1 * p2, data = f1a5)
fit1a <- expand.grid(list(p1 = seq(1, 10, 0.1),
                          p2 = seq(1, 10, 0.1)))
fit1a$pia <- as.numeric(predict(loess1a, newdata = fit1a))

loess1b <- loess(pia ~ p1 * p2, data = f1b5)
fit1b <- expand.grid(list(p1 = seq(1, 10, 0.1),
                          p2 = seq(1, 10, 0.1)))
fit1b$pia <- as.numeric(predict(loess1b, newdata = fit1b))

fit1a$LNT = "PrEP Linked"
fit1b$LNT = "PrEP Unlinked"
fit1 <- rbind(fit1a, fit1b)

sf2 <- ggplot(fit1, aes(p1, p2)) +
  geom_raster(aes(fill = pia), interpolate = TRUE) +
  geom_contour(aes(z = pia), col = "white", alpha = 0.5, lwd = 0.5) +
  theme_minimal() +
  facet_grid(cols = vars(LNT)) +
  scale_y_continuous(expand = c(0, 0)) +
  scale_x_continuous(expand = c(0, 0)) +
  labs(y = "Relative Retention", x = "Relative Screening") +
  scale_fill_viridis(discrete = FALSE, alpha = 1, option = "D", direction = 1)

pdf(file = "analysis/fig/FigureSF2.pdf", height = 6, width = 10)
sf2
dev.off()
