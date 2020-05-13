
##
## COVID-19 Cruise Ship Network Model
## Epidemic Model
##
## Authors: Samuel M. Jenness
## Date: February 2020
##

## Code works with these versions of EpiModel/tergmLite
# remotes::install_github("statnet/EpiModel@v1.8.0")
# remotes::install_github("statnet/tergmLite@v2.1.7")

library("EpiModel")
library("tergmLite")

# sessionInfo()
packageVersion("EpiModel") == "1.8.0"
packageVersion("tergmLite") == "2.1.7"


# Read in fitted network models
est.pre <- readRDS("est/est.covid-pre.rds")
est.post <- readRDS("est/est.covid-post.rds")
est <- c(est.pre, est.post)

# Model parameters
source("params.R")
param <- param.net(inf.prob.pp = 0.05,
                   inf.prob.pp.inter.rr = 1,
                   inf.prob.pp.inter.time = Inf,
                   act.rate.pp = 5,
                   act.rate.pp.inter.rr = 1,
                   act.rate.pp.inter.time = Inf,
                   inf.prob.pc = 0.05,
                   inf.prob.pc.inter.rr = 1,
                   inf.prob.pc.inter.time = Inf,
                   act.rate.pc = 2,
                   act.rate.pc.inter.rr = 1,
                   act.rate.pc.inter.time = Inf,
                   inf.prob.cc = 0.05,
                   inf.prob.cc.inter.rr = 1,
                   inf.prob.cc.inter.time = Inf,
                   act.rate.cc = 5,
                   act.rate.cc.inter.rr = 1,
                   act.rate.cc.inter.time = Inf,
                   inf.prob.a.rr = 0.5,
                   prop.clinical = c(0.40, 0.25, 0.37, 0.42, 0.51, 0.59, 0.72, 0.76),
                   act.rate.dx.inter.rr = 1,
                   act.rate.dx.inter.time = Inf,
                   act.rate.sympt.inter.rr = 1,
                   act.rate.sympt.inter.time = Inf,
                   network.lockdown.time = 16,
                   ea.rate = 1/4.0,
                   ar.rate = 1/5.0,
                   eip.rate = 1/4.0,
                   ipic.rate = 1/1.5,
                   icr.rate = 1/3.5,
                   dx.start = 15,
                   dx.rate.pass = 0.052,
                   dx.rate.crew = 0.052,
                   dx.elig.status = c("s", "e", "a", "ip", "ic"),
                   mort.rates = mr_vec,
                   mort.dis.mult = 100,
                   exit.rate.pass = 0,
                   exit.rate.crew = 0,
                   exit.elig.status = c("ip", "ic"),
                   exit.require.dx = FALSE)

# Initial conditions
init <- init.net(e.num.pass = 2,
                 e.num.crew = 0)

# Control settings
source("module-fx.R", echo = FALSE)
control <- control.net(nsteps = 31,
                       nsims = 1,
                       ncores = 1,
                       initialize.FUN = init_covid,
                       aging.FUN = aging_covid,
                       departures.FUN = deaths_covid,
                       offload.FUN = offload_covid,
                       arrivals.FUN = NULL,
                       edges_correct.FUN = NULL,
                       resim_nets.FUN = resim_nets_covid,
                       infection.FUN = infect_covid,
                       recovery.FUN = progress_covid,
                       dx.FUN = dx_covid,
                       get_prev.FUN = prevalence_covid,
                       module.order = c("aging.FUN", "departures.FUN",
                                        "offload.FUN",
                                        "resim_nets.FUN", "infection.FUN",
                                        "recovery.FUN", "dx.FUN", "get_prev.FUN"),
                       depend = TRUE,
                       skip.check = TRUE)

sim <- netsim(est, param, init, control)
# print(sim)

sim <- mutate_epi(sim, se.cuml = cumsum(se.flow))
df <- as.data.frame(sim, out = "mean")
round(df, 2)

sum(df$se.flow)

# Evaluate IFR
sum(df$d.flow)
sum(df$se.flow)
sum(df$se.flow)
summary(colSums(sim$epi$se.flow))

# Plot outcomes
par(mar = c(3,3,1,1), mgp = c(2,1,0))
pal <- RColorBrewer::brewer.pal(9, "Set1")
pal <- rainbow(9)
pal <- 1:9

plot(sim,
     mean.col = pal, mean.lwd = 1, mean.smooth = TRUE,
     qnts = 1, qnts.col = pal, qnts.alpha = 0.25, qnts.smooth = TRUE,
     legend = TRUE)

plot(sim, y = c("i.pass.num", "i.crew.num"),
     mean.col = pal, mean.lwd = 1, mean.smooth = TRUE,
     qnts = 1, qnts.col = pal, qnts.alpha = 0.25, qnts.smooth = TRUE,
     legend = TRUE)

plot(sim, y = c("se.flow", "ea.flow", "ar.flow"),
     mean.col = pal, mean.lwd = 1, mean.smooth = TRUE,
     qnts.col = pal, qnts.alpha = 0.25, qnts.smooth = TRUE,
     legend = TRUE)

plot(sim, y = c("se.flow", "eip.flow", "ipic.flow", "icr.flow"),
     mean.col = pal, mean.lwd = 1, mean.smooth = TRUE,
     qnts.col = pal, qnts.alpha = 0.25, qnts.smooth = TRUE,
     legend = TRUE)

plot(sim, y = c("se.pp.flow", "se.pc.flow", "se.cp.flow", "se.cc.flow"),
     mean.col = pal, mean.lwd = 2, mean.smooth = FALSE, qnts = FALSE,
     legend = TRUE)

plot(sim, y = "d.flow",
     mean.col = pal, mean.lwd = 1, mean.smooth = TRUE, qnts = FALSE,
     qnts.col = pal, qnts.alpha = 0.25, qnts.smooth = TRUE,
     legend = TRUE)

plot(sim, y = "Rt", mean.smooth = FALSE)
plot(sim, y = "se.cuml")
abline(h = n.pass + n.crew)

df$se.flow
cumsum(df$se.flow)
