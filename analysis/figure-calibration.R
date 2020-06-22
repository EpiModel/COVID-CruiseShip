
## calibration plots

library("EpiModelCOVID")

source("01.epi-params.R")
load("analysis/dat/sim.n1000.rda")
sim <- mutate_epi(sim, se.cuml = cumsum(se.flow),
                  dx.cuml = cumsum(nDx),
                  dx.pos.cuml = cumsum(nDx.pos),
                  totI = e.num + a.num + ip.num + ic.num)
df <- as.data.frame(sim, out = "mean")
df$se.cuml
df$dx.pos.cuml
pos.tests.day

summary(as.numeric(tail(sim$epi$dx.pos.cuml, 1)))
summary(as.numeric(tail(sim$epi$se.cuml, 1)))

which.max(df$se.flow)
summary(as.numeric(sim$epi$se.flow[14, ]))

pdf("analysis/Fig1-Calibration.pdf", height = 6, width = 12)
par(mar = c(3,3,2,1), mgp = c(2,1,0), mfrow = c(1,2))
plot(sim, y = c("se.cuml", "dx.pos.cuml"), qnts = 0.5, legend = FALSE, mean.smooth = TRUE,
     main = "A. Model Calibration", xlab = "Day", ylab = "Cumulative Count")
pal <- RColorBrewer::brewer.pal(3, "Set1")
legend("topleft", legend = c("Fitted Diagnoses", "Fitted Incidence", "Empirical Diagnoses"),
       lty = c(1,1,2), lwd = 2, col = c(pal[1:2], 1), bty = "n", cex = 0.9)
lines(pos.tests.day, lty = 2, lwd = 2)


plot(sim, y = c("se.flow"), qnts = 0.5, legend = FALSE, mean.smooth = FALSE, qnts.smooth = FALSE,

     main = "B. Estimated Daily Incidence", xlab = "Day", ylab = "Daily Count", ylim = c(0, 350))
# abline(v = 15, lty = 2)

pal <- RColorBrewer::brewer.pal(4, "Set1")
load("analysis/dat/sim.n1013.rda")
sim <- mutate_epi(sim, se.cuml = cumsum(se.flow),
                  dx.cuml = cumsum(nDx),
                  dx.pos.cuml = cumsum(nDx.pos),
                  totI = e.num + a.num + ip.num + ic.num)
df <- as.data.frame(sim, out = "mean")

which.max(df$se.flow)
summary(as.numeric(sim$epi$se.flow[20, ]))

df$se.cuml[15]/df$se.cuml[31]

plot(sim, y = c("se.flow"), qnts = 0.5, legend = FALSE, mean.smooth = FALSE, qnts.smooth = FALSE,
     mean.col = pal[4], qnts.col = pal[4],
     main = "B. Expected Daily Incidence", xlab = "Day", ylab = "Daily Count", add = TRUE)
abline(v = 15, lty = 3)

legend("topleft", legend = c("Calibrated Model", "No Network Intervention", "Lockdown Day"),
       lty = c(1,1,3), lwd = 2, col = c(pal[c(2,4)], 1), bty = "n", cex = 0.9)

dev.off()
