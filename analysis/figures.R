
## COVID Cruise Ship Figures

library("EpiModelCOVID")
library("dplyr")
library("ggplot2")
library("viridis")
library("gridExtra")

# Figure 1 ----------------------------------------------------------------

get_fig1_data <- function(simno, var) {
  fn <- list.files("data/", pattern = as.character(simno), full.names = TRUE)
  load(fn)
  ir <- as.numeric(colMeans(tail(sim$epi[[var]], 52)))
  df <- data.frame(scenario = simno,
                   ir = median(ir))
  return(df)
}

sims1 <- 5000:5090
sims2 <- 5091:5181
sims3 <- 5182:5272

library("parallel")
cl <- makeCluster(parallel::detectCores())

# BMSM
b1 <- do.call("rbind", clusterApply(cl, sims1, get_fig1_data, "ir100.B"))
b2 <- do.call("rbind", clusterApply(cl, sims2, get_fig1_data, "ir100.B"))
b3 <- do.call("rbind", clusterApply(cl, sims3, get_fig1_data, "ir100.B"))
b <- cbind(b1, b2[, 2], b3[, 2])
names(b)[2:4] <- c("noTarg", "TargB", "TargH")
b

# HMSM
h1 <- do.call("rbind", clusterApply(cl, sims1, get_fig1_data, "ir100.H"))
h2 <- do.call("rbind", clusterApply(cl, sims2, get_fig1_data, "ir100.H"))
h3 <- do.call("rbind", clusterApply(cl, sims3, get_fig1_data, "ir100.H"))
h <- cbind(h1, h2[, 2], h3[, 2])
names(h)[2:4] <- c("noTarg", "TargB", "TargH")
h

# WMSM
w1 <- do.call("rbind", clusterApply(cl, sims1, get_fig1_data, "ir100.W"))
w2 <- do.call("rbind", clusterApply(cl, sims2, get_fig1_data, "ir100.W"))
w3 <- do.call("rbind", clusterApply(cl, sims3, get_fig1_data, "ir100.W"))
w <- cbind(w1, w2[, 2], w3[, 2])
names(w)[2:4] <- c("noTarg", "TargB", "TargH")
w

save(b, h, w, file = "data/Fig1-data.rda")
system("scp mox:/gscratch/csde/sjenness/combprev/data/Fig1-data.rda analysis/")
load("analysis/Fig1-data.rda")

relscr <- seq(1, 10, 0.1)
pal <- RColorBrewer::brewer.pal(3, "Set1")
pal

pdf(file = "analysis/fig/Figure1.pdf", height = 6, width = 10)
par(mar = c(3,3,2,1), mgp = c(2,1,0), mfcol = c(1,2))
plot(relscr, supsmu(relscr, b$noTarg)$y,
     col = pal[1], lwd = 1.5, type = "l", ylim = c(0, 3),
     ylab = "HIV Incidence", xlab = "Relative Screening Frequency",
     main = "BMSM Incidence")
lines(relscr, supsmu(relscr, b$TargB)$y, col = pal[2], lwd = 1.5, lty = 2)
lines(relscr, supsmu(relscr, b$TargH)$y, col = pal[3], lwd = 1.5, lty = 4)
legend(1, 0.5, legend = c("No Target", "BMSM Target", "HMSM Target"),
       lty = c(1,2,4), col = pal, cex = 0.85, lwd = 2.5, bty = "n")

plot(relscr, supsmu(relscr, w$noTarg)$y,
     col = pal[1], lwd = 1.5, type = "l", ylim = c(0, 0.5),
     ylab = "HIV Incidence", xlab = "Relative Screening Frequency",
     main = "WMSM Incidence")
lines(relscr, supsmu(relscr, w$TargB)$y, col = pal[2], lwd = 1.5, lty = 2)
lines(relscr, supsmu(relscr, w$TargH)$y, col = pal[3], lwd = 1.5, lty = 4)
legend(1, 0.08, legend = c("No Target", "BMSM Target", "HMSM Target"),
       lty = c(1,2,4), col = pal, cex = 0.85, lwd = 2.5, bty = "n")
dev.off()

# plot(relscr, supsmu(relscr, h$noTarg)$y,
#      col = pal[1], lwd = 1.5, type = "l", ylim = c(0, 1),
#      ylab = "HIV Incidence", xlab = "Relative Screening Frequency",
#      main = "HMSM Incidence")
# lines(relscr, supsmu(relscr, h$TargB)$y, col = pal[2], lwd = 2, lty = 2)
# lines(relscr, supsmu(relscr, h$TargH)$y, col = pal[3], lwd = 2, lty = 3)
# legend("bottomleft", legend = c("No Target", "BMSM Target", "HMSM Target"),
#        lty = 1:3, col = pal, cex = 0.85, lwd = 2.5)



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



# Figure 3 ----------------------------------------------------------------

load("intervention/data/sim.n8000.rda")
sim.base <- truncate_sim(sim, 2)

load("intervention/data/sim.n8003.rda")
sim.comp <- truncate_sim(sim, 2)

df.base <- as.data.frame(sim.base, out = "mean")
df.comp <- as.data.frame(sim.comp, out = "mean")

ir.base <- df.base$ir100
ir.comp <- df.comp$ir100

y <- supsmu(1:nrow(df.comp), df.comp$ir100)$y
plot(y, type = "l")
abline(h = c(1.23*0.1, 1.23*0.25), v = 1580, lty = 2)

which.max(y <= 1.23*0.1)
1580/52
2020 + 1580/52

which.max(y <= 1.23*0.25)
377/52
2020 + 377/52

pal <- adjustcolor(RColorBrewer::brewer.pal(3, "Set1"), alpha.f = 0.8)
xs <- 2020 + 1:length(ir.base)/52

pdf(file = "analysis/fig/Figure3.pdf", height = 6, width = 10)
par(mar = c(3,3,1,1), mgp = c(2,1,0))
plot(xs, ir.base, type = "l", ylim = c(0, 1.5), col = pal[2], lwd = 1.2,
     ylab = "Incidence Rate per 100 PYAR", xlab = "Year", font.lab = 2)
lines(xs, ir.comp, col = pal[1], lwd = 1.2)
abline(h = c(1.23*0.1, 1.23*0.25), lty = 2, lwd = 1, col = adjustcolor("black", alpha.f = 0.6))
text(2062, 0.16, "EHE 2030 90% Reduction Target", cex = 0.9)
text(2062, 0.35, "EHE 2025 75% Reduction Target", cex = 0.9)
legend("topright", legend = c("Reference Model", "10x10 Model"), lty = 1, lwd = 2, col = pal[2:1],
       bty = "n", cex = 0.9)
dev.off()

