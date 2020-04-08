
##
## COVID-19 Cruise Ship Network Model
##
## Authors: Samuel M. Jenness
## Date: February 2020
##

## Load EpiModel
library("EpiModel")
library("tergmLite")

# Code works with this version of EpiModel
packageVersion("EpiModel") == "1.8.0"


# Network model estimation ------------------------------------------------

n.crew <- 1045
n.pass <- 2666
n <- n.crew + n.pass

n.rooms <- 1337
n.pass.per.room <- n.pass/n.rooms
n.pass.per.room

type.attr <- rep(c("p", "c"), times = c(n.pass, n.crew))

# median age for crew was 36 (IQR:29-43) and
# the median age of the passengers was 69 (IQR: 62-73)
ages.pass <- round(rnorm(n.pass, 69, 6), 1)
summary(ages.pass)
table(ages.pass)
ages.crew <- pmax(round(rnorm(n.crew, 36, 10), 1), 18)
summary(ages.crew)
table(ages.crew)

age <- rep(0, n)
age[type.attr == "p"] <- ages.pass
age[type.attr == "c"] <- ages.crew
summary(age)

# Initialize the network
nw <- network.initialize(n, directed = FALSE)
nw <- set.vertex.attribute(nw, "type", type.attr)
nw <- set.vertex.attribute(nw, "pass.room", room.ids.pass, pass.ids)
nw <- set.vertex.attribute(nw, "age", age)

# Model 1: pass/pass contacts within rooms each day

# Define the formation model
formation = ~edges + concurrent + nodefactor("type", levels = -2) + absdiff("age")

# Input the appropriate target statistics for each term
# about one persistent pass/pass contact
md <- 0.98
edges <- n.pass * md/2
absdiff <- edges * 5

target.stats <- c(edges, 0, 0, absdiff)

# Parameterize the dissolution model
coef.diss <- dissolution_coefs(dissolution = ~offset(edges), duration = 25000)
coef.diss

# Fit the model
est1 <- netest(nw, formation, target.stats, coef.diss,
               set.control.ergm = control.ergm(MCMLE.maxit = 500,
                                               MCMC.interval = 3e4,
                                               MCMC.burnin = 2e6))
summary(est1)
mcmc.diagnostics(est1$fit)

# Model diagnostics
dx1a <- netdx(est1, nsims = 1000, dynamic = FALSE,
              nwstats.formula = ~edges + nodefactor("type", levels = NULL) + absdiff("age"),
              set.control.ergm = control.simulate.ergm(MCMC.burnin = 1e6))
print(dx1a)
plot(dx1a, sim.lines = TRUE)

dx1b <- netdx(est1, nsims = 10, ncores = 5, nsteps = 500, dynamic = TRUE,
              nwstats.formula = ~edges + nodefactor("type", levels = NULL),
              set.control.ergm = control.simulate.ergm(MCMC.burnin = 1e6))
print(dx1b)
plot(dx1b)

dx1c <- netdx(est1, nsims = 1, ncores = 1, nsteps = 100, dynamic = TRUE,
              keep.tnetwork = TRUE)
dx1c
df <- as.data.frame(get_network(dx1c))
df[which(df$onset.censored == FALSE | df$terminus.censored == FALSE), ]
table(c(df$tail, df$head))
summary(as.numeric(table(c(df$tail, df$head))))


## Model 2: crew/crew contacts each day

# about 2 ongoing contacts a day, but max at 3
formation2 <- ~edges + degrange(from = 4) + nodefactor("type", levels = -1)

md <- 2
edges <- n.crew * md/2
target.stats2 <- c(edges, 0, 0)

# Assume longer duration
coef.diss2 <- dissolution_coefs(dissolution = ~offset(edges), duration = 100)
coef.diss2

# Fit the model
est2 <- netest(nw, formation2, target.stats2, coef.diss2,
               set.control.ergm = control.ergm(MCMLE.maxit = 500,
                                               MCMC.interval = 3e4,
                                               MCMC.burnin = 2e6))
summary(est2)
mcmc.diagnostics(est2$fit)

dx2a <- netdx(est2, nsims = 1000, dynamic = FALSE,
             nwstats.formula = ~edges + nodefactor("type", levels = NULL) + absdiff("age"),
             set.control.ergm = control.simulate.ergm(MCMC.burnin = 1e6))
print(dx2a)
plot(dx2a, sim.lines = TRUE)

dx2b <- netdx(est2, nsims = 10, ncores = 5, nsteps = 500, dynamic = TRUE,
              nwstats.formula = ~edges + nodefactor("type", levels = NULL),
              set.control.ergm = control.simulate.ergm(MCMC.burnin = 1e6))
print(dx2b)

dx2c <- netdx(est2, nsims = 1, ncores = 1, nsteps = 100, dynamic = TRUE,
             keep.tnetwork = TRUE)
dx2c
df <- as.data.frame(get_network(dx2c))
df[which(df$onset.censored == FALSE | df$terminus.censored == FALSE), ]
table(c(df$tail, df$head))
summary(as.numeric(table(c(df$tail, df$head))))


## Model 3: crew/pass contacts each day

# crew/pass contacts: 3 times a day x 2 workers x each room x average 2 people per room
# 3 times a day will go into act rate
# assume making contact with one person per room
cp.edges <- 2*n.rooms/2

formation3 <- ~edges + nodematch("type") + degrange(from = 3)
target.stats3 <- c(cp, 0, 0)

coef.diss3 <- dissolution_coefs(dissolution = ~offset(edges), duration = 1)

est3 <- netest(nw, formation3, target.stats3, coef.diss3,
               set.control.ergm = control.ergm(MCMLE.maxit = 500))
summary(est3)
mcmc.diagnostics(est3$fit)

dx3a <- netdx(est3, nsims = 10000, dynamic = FALSE,
              nwstats.formula = ~edges + nodemix("type", levels = NULL))
print(dx3a)
plot(dx3a, sim.lines = TRUE)

est <- list(est1, est2, est3)
saveRDS(est, file = "est/est.covid.rds")


# Epidemic model simulation -----------------------------------------------

# Read in fitted network models
est <- readRDS("est/est.covid.rds")

# Model parameters
source("params.R")
param <- param.net(inf.prob.pp = 0.3,
                   inf.prob.pp.inter.rr = 1,
                   inf.prob.pp.inter.time = 15,
                   act.rate.pp = 10,
                   act.rate.pp.inter.rr = 1,
                   act.rate.pp.inter.time = 15,
                   inf.prob.pc = 0.3,
                   inf.prob.pc.inter.rr = 1,
                   inf.prob.pc.inter.time = 15,
                   act.rate.pc = 3,
                   act.rate.pc.inter.rr = 1,
                   act.rate.pc.inter.time = 15,
                   inf.prob.cc = 0.3,
                   inf.prob.cc.inter.rr = 1,
                   inf.prob.cc.inter.time = 15,
                   act.rate.cc = 2,
                   act.rate.cc.inter.rr = 1,
                   act.rate.cc.inter.time = 15,
                   inf.prob.a.rr = 0.5,
                   prop.clinical = 0.75,
                   ea.rate = 1/3,
                   ar.rate = 1/3,
                   eip.rate = 1/3,
                   ipic.rate = 1/5,
                   icr.rate = 1/2,
                   mort.rates = mr_vec,
                   mort.dis.mult = 100)

# Initial conditions
init <- init.net(e.num.pass = 10,
                 e.num.crew = 10)

# Control settings
source("module-fx.R", echo = FALSE)
control <- control.net(nsteps = 60,
                       nsims = 1,
                       ncores = 1,
                       initialize.FUN = init_covid,
                       aging.FUN = aging_covid,
                       departures.FUN = deaths_covid,
                       arrivals.FUN = NULL,
                       edges_correct.FUN = NULL,
                       resim_nets.FUN = resim_nets_covid,
                       infection.FUN = infect_covid,
                       recovery.FUN = progress_covid,
                       get_prev.FUN = prevalence_covid,
                       module.order = c("aging.FUN", "departures.FUN",
                                        "resim_nets.FUN", "infection.FUN",
                                        "recovery.FUN", "get_prev.FUN"),
                       depend = TRUE,
                       skip.check = TRUE)

sim <- netsim(est, param, init, control)
print(sim)

df <- as.data.frame(sim, out = "mean")
round(df, 1)

sum(df$se.flow)
summary(colSums(sim$epi$se.flow))

# Plot outcomes
par(mar = c(3,3,1,1), mgp = c(2,1,0))
pal <- RColorBrewer::brewer.pal(9, "Set1")

plot(sim,
     mean.col = pal, mean.lwd = 1, mean.smooth = TRUE,
     qnts = 1, qnts.col = pal, qnts.alpha = 0.25, qnts.smooth = TRUE,
     legend = TRUE)

plot(sim, y = c("i.pass.num", "i.crew.num"),
     mean.col = pal, mean.lwd = 1, mean.smooth = TRUE,
     qnts = 1, qnts.col = pal, qnts.alpha = 0.25, qnts.smooth = TRUE,
     legend = TRUE)

plot(sim, y = c("se.flow", "ei.flow", "ir.flow"),
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


