
##
## COVID-19 Cruise Ship Network Model
## Epidemic Model
##
## Authors: Samuel M. Jenness
## Date: February 2020
##

library("EpiModelCOVID")

# Read in fitted network models
est.pre <- readRDS("est/est.pre.v2.rds")
est.post <- readRDS("est/est.post.base.v2.rds")
est <- c(est.pre, est.post)

# Model parameters
source("01.epi-params.R")
param <- param.net(inf.prob.pp = 0.11,
                   inf.prob.pp.inter.rr = 0.6,
                   inf.prob.pp.inter.time = Inf,
                   act.rate.pp = 5,
                   act.rate.pp.inter.rr = 1,
                   act.rate.pp.inter.time = Inf,
                   inf.prob.pc = 0.11,
                   inf.prob.pc.inter.rr = 0.6,
                   inf.prob.pc.inter.time = 15,
                   act.rate.pc = 1,
                   act.rate.pc.inter.rr = 1,
                   act.rate.pc.inter.time = Inf,
                   inf.prob.cc = 0.11,
                   inf.prob.cc.inter.rr = 0.6,
                   inf.prob.cc.inter.time = 15,
                   act.rate.cc = 1,
                   act.rate.cc.inter.rr = 1,
                   act.rate.cc.inter.time = Inf,
                   inf.prob.a.rr = 0.5,
                   prop.clinical = c(0.40, 0.25, 0.37, 0.42, 0.51, 0.59, 0.72, 0.76),
                   act.rate.dx.inter.rr = 0.1,
                   act.rate.dx.inter.time = 15,
                   act.rate.sympt.inter.rr = 0.1,
                   act.rate.sympt.inter.time = 15,
                   network.lockdown.time = 15,
                   ea.rate = 1/4.0,
                   ar.rate = 1/5.0,
                   eip.rate = 1/4.0,
                   ipic.rate = 1/1.5,
                   icr.rate = 1/3.5,
                   pcr.sens = 0.8,
                   dx.rate.sympt = c(rep(0, 15), rep(0.2, 5), rep(0.3, 5), rep(0.8, 100)),
                   dx.rate.other = c(rep(0, 15), rep(0, 5), rep(0.07, 5), rep(0.19, 100)),
                   allow.rescreen = FALSE,
                   mort.rates = mr_vec,
                   mort.dis.mult = 180,
                   exit.rate.pass = 0,
                   exit.rate.crew = 0,
                   exit.elig.status = c("ip", "ic"),
                   exit.require.dx = FALSE)

param <- param.net(inf.prob.pp = 0.10455227,
                   inf.prob.pp.inter.rr = 0.6,
                   inf.prob.pp.inter.time = Inf,
                   act.rate.pp = 5,
                   act.rate.pp.inter.rr = 1,
                   act.rate.pp.inter.time = Inf,
                   inf.prob.pc = 0.10455227,
                   inf.prob.pc.inter.rr = 0.6,
                   inf.prob.pc.inter.time = 15,
                   act.rate.pc = 1,
                   act.rate.pc.inter.rr = 1,
                   act.rate.pc.inter.time = Inf,
                   inf.prob.cc = 0.10455227,
                   inf.prob.cc.inter.rr = 0.6,
                   inf.prob.cc.inter.time = 15,
                   act.rate.cc = 1,
                   act.rate.cc.inter.rr = 1,
                   act.rate.cc.inter.time = Inf,
                   inf.prob.a.rr = 0.5,
                   prop.clinical = c(0.40, 0.25, 0.37, 0.42, 0.51, 0.59, 0.72, 0.76),
                   act.rate.dx.inter.rr = 0.1,
                   act.rate.dx.inter.time = 15,
                   act.rate.sympt.inter.rr = 0.1,
                   act.rate.sympt.inter.time = 15,
                   network.lockdown.time = 15,
                   ea.rate = 1/4.0,
                   ar.rate = 1/5.0,
                   eip.rate = 1/4.0,
                   ipic.rate = 1/1.5,
                   icr.rate = 1/3.5,
                   pcr.sens = 0.8,
                   dx.rate.sympt = c(rep(0, 15), rep(0.21430869, 5), rep(0.30194363, 5), rep(0.80075530, 100)),
                   dx.rate.other = c(rep(0, 15), rep(0, 5), rep(0.09680617, 5), rep(0.21919574, 100)),
                   allow.rescreen = FALSE,
                   mort.rates = mr_vec,
                   mort.dis.mult = 180,
                   exit.rate.pass = 0,
                   exit.rate.crew = 0,
                   exit.elig.status = c("ip", "ic"),
                   exit.require.dx = FALSE)

# Initial conditions
init <- init.net(e.num.pass = 8,
                 e.num.crew = 0)

# Control settings
# pkgload::load_all("~/git/EpiModelCOVID")
control <- control.net(nsteps = 31,
                       nsims = 100, #100,
                       ncores = 4, #4,
                       initialize.FUN = init_covid_ship,
                       aging.FUN = aging_covid_ship,
                       departures.FUN = deaths_covid_ship,
                       arrivals.FUN = NULL,
                       edges_correct.FUN = NULL,
                       resim_nets.FUN = resim_nets_covid_ship,
                       infection.FUN = infect_covid_ship,
                       recovery.FUN = progress_covid_ship,
                       dx.FUN = dx_covid_ship,
                       prevalence.FUN = prevalence_covid_ship,
                       nwupdate.FUN = NULL,
                       module.order = c("aging.FUN",
                                        "departures.FUN",
                                        "resim_nets.FUN",
                                        "infection.FUN",
                                        "recovery.FUN",
                                        "dx.FUN",
                                        "prevalence.FUN"),
                       resimulate.network = TRUE,
                       skip.check = TRUE,
                       tergmLite = TRUE)

sim <- netsim(est, param, init, control)
# print(sim)

sim <- mutate_epi(sim, se.cuml = cumsum(se.flow),
                       dx.cuml = cumsum(nDx),
                       dx.pos.cuml = cumsum(nDx.pos),
                       totI = e.num + a.num + ip.num + ic.num)
df <- as.data.frame(sim, out = "mean")
names(df)

df$dx.cuml
summary(as.numeric(tail(sim$epi$dx.cuml, 1)))
df$dx.pos.cuml[c(16, 21, 26, 31)]
max(pos.tests.day)
pdf("analysis/Fig-Calibration1-Supp.pdf", height = 6, width = 10)
par(mar = c(3,3,2,1), mgp = c(2,1,0), mfrow = c(1,2))
plot(sim, y = c("se.cuml", "dx.pos.cuml"), qnts = 0.5, legend = FALSE, mean.smooth = TRUE,
     main = "Calibration To Cumulative Diagnoses", xlab = "Day", ylab = "Cumulative Count")
pal <- RColorBrewer::brewer.pal(3, "Set1")
legend("topleft", legend = c("Fitted Diagnoses", "Fitted Incidence", "Empirical Diagnoses"),
       lty = c(1,1,2), lwd = 2, col = c(pal[1:2], 1), bty = "n")
lines(pos.tests.day, lty = 2, lwd = 2)


summary(colSums(sim$epi$d.ic.flow))

sum(df$d.ic.flow)
sum(df$se.flow)
summary(colSums(sim$epi$se.flow))


plot(sim, y = c("se.flow", "nDx.pos"), qnts = 0.5, legend = FALSE, mean.smooth = TRUE,
     main = "Comparison to Raw Diagnoses", xlab = "Day", ylab = "Daily Count", ylim = c(0, 200))
legend("topleft", legend = c("Fitted Diagnoses", "Fitted Incidence", "Empirical Diagnoses"),
       lty = c(1,1,2), lwd = 2, col = c(2, 4, 1), bty = "n")
lines(c(0, diff(pos.tests.day)), lty = 2, lwd = 2)
dev.off()
