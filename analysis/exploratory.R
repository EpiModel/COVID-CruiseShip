
## exploratory plots

load("analysis/data/sim.n6000.rda")
sim$param$dx.rate.other

sim <- mutate_epi(sim, se.cuml = cumsum(se.flow),
                  dx.cuml = cumsum(nDx),
                  dx.pos.cuml = cumsum(nDx.pos),
                  totI = e.num + a.num + ip.num + ic.num)
df <- as.data.frame(sim, out = "mean")
# round(df, 2)
names(df)

df$dx.cuml
summary(as.numeric(tail(sim$epi$dx.cuml, 1)))
df$dx.pos.cuml
max(pos.tests.day)
par(mar = c(3,3,2,1), mgp = c(2,1,0))
plot(sim, y = c("se.cuml", "dx.pos.cuml"), qnts = 0.5, legend = FALSE, mean.smooth = TRUE,
     main = "Model Calibration", xlab = "Day", ylab = "Cumulative Count")
pal <- RColorBrewer::brewer.pal(3, "Set1")
legend("topleft", legend = c("Fitted Diagnoses", "Fitted Incidence", "Empirical Diagnoses"),
       lty = c(1,1,2), lwd = 2, col = c(pal[1:2], 1), bty = "n")
lines(pos.tests.day, lty = 2, lwd = 2)

summary(colSums(sim$epi$d.ic.flow))

plot(sim, y = "Rt")

select(df, starts_with("se."))
