
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

pass.ids <- 1:n.pass

room.ids <- 1:n.rooms
room.ids.pass <- apportion_lr(n.pass, room.ids, rep(1/n.rooms, n.rooms))
table(room.ids.pass)

type.attr <- rep(c("p", "c"), times = c(n.pass, n.crew))

ages <- seq(30, 80, 1/365)
age <- sample(ages, n, TRUE)

# Initialize the network
nw <- network.initialize(n, directed = FALSE)
nw <- set.vertex.attribute(nw, "type", type.attr)
nw <- set.vertex.attribute(nw, "pass.room", room.ids.pass, pass.ids)
nw <- set.vertex.attribute(nw, "age", age)

# Model 1: pass/pass contacts within rooms each day

# Define the formation model
formation = ~edges + concurrent + nodefactor("type", levels = -2)

# Input the appropriate target statistics for each term
# one contact per day
md <- 1
edges <- n.pass * md/2

target.stats <- c(edges, 0, 0)

# Parameterize the dissolution model
coef.diss <- dissolution_coefs(dissolution = ~offset(edges), duration = 25000)
coef.diss

# Fit the model
est1 <- netest(nw, formation, target.stats, coef.diss,
              set.control.ergm = control.ergm(MCMLE.maxit = 500))
summary(est1)

# Model diagnostics
dx1 <- netdx(est1, nsims = 10000, dynamic = FALSE,
             nwstats.formula = ~edges + nodematch("pass.room") +
                     nodefactor("type", levels = NULL))
print(dx1)
plot(dx1, sim.lines = TRUE)

dx2 <- netdx(est1, nsims = 10, ncores = 5, nsteps = 500, dynamic = TRUE,
             nwstats.formula = ~edges + nodematch("pass.room") +
                     nodefactor("type", levels = NULL))
print(dx2)
plot(dx2)

dx3 <- netdx(est1, nsims = 1, ncores = 1, nsteps = 100, dynamic = TRUE,
             keep.tnetwork = TRUE)
dx3
as.data.frame(get_network(dx3))

## Model 2: crew/pass and crew/crew contacts each day

# model for worker/worker and worker/guest contact
# 5 contacts per day, 3 with guests (x 2 workers per time) and 2 within workers

# crew/crew contacts
cc <- 2*n.crew/2

# crew/pass contacts: 3 times a day x 2 workers x each room x average 2 people per room
cp <- 3*2*n.rooms*2/2

# pass/pass contacts
pp <- 0

formation2 <- ~nodemix("type", levels = NULL)
target.stats2 <- c(cc, cp, pp)
target.stats2

coef.diss2 <- dissolution_coefs(dissolution = ~offset(edges), duration = 1)

est2 <- netest(nw, formation2, target.stats2, coef.diss2,
               set.control.ergm = control.ergm(MCMLE.maxit = 500))

dx4 <- netdx(est2, nsims = 10000, dynamic = FALSE,
             nwstats.formula = ~edges + nodemix("type", levels = NULL))
print(dx4)
plot(dx4, sim.lines = TRUE)

est <- list(est1, est2)
saveRDS(est, file = "est/est.covid.rds")



# Other Parameter Estimation ----------------------------------------------

# Mortality Rates
# Rates per 100,000 for age groups: <1, 1-4, 5-9, 10-14, 15-19, 20-24, 25-29,
#                                   30-34, 35-39, 40-44, 45-49, 50-54, 55-59,
#                                   60-64, 65-69, 70-74, 75-79, 80-84, 85+
# source: https://www.statista.com/statistics/241572/death-rate-by-age-and-sex-in-the-us/
mortality_rate <- c(588.45, 24.8, 11.7, 14.55, 47.85, 88.2, 105.65, 127.2,
                    154.3, 206.5, 309.3, 495.1, 736.85, 1051.15, 1483.45,
                    2294.15, 3642.95, 6139.4, 13938.3)
# rate per person, per day
mr_pp_pd <- mortality_rate / 1e5 / 365

# Build out a mortality rate vector
age_spans <- c(1, 4, rep(5, 16), 1)
mr_vec <- rep(mr_pp_pd, times = age_spans)



# Epidemic model simulation -----------------------------------------------

# Read in fitted network models
est <- readRDS("est/est.covid.rds")

# Model parameters
param <- param.net(inf.prob.pp = 0.5,
                   act.rate.pp = 1,
                   inf.prob.pc = 0.5,
                   act.rate.pc = 1,
                   inf.prob.cc = 0.5,
                   act.rate.cc = 1,
                   ei.rate = 1/5.2,
                   ir.rate = 1/7,
                   mort.rates = mr_vec,
                   mort.dis.mult = 100)

# Initial conditions
init <- init.net(e.num = 10)

# Read in the module functions
source("module-fx.R", echo = FALSE)

# Control settings
control <- control.net(nsteps = 60,
                       nsims = 1,
                       ncores = 1,
                       initialize.FUN = init_covid,
                       aging.FUN = aging_covid,
                       departures.FUN = dfunc_covid,
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

# Plot outcomes
par(mar = c(3,3,1,1), mgp = c(2,1,0))
pal <- RColorBrewer::brewer.pal(4, "Set1")

plot(sim,
     mean.col = pal, mean.lwd = 1, mean.smooth = FALSE,
     qnts = 1, qnts.col = pal, qnts.alpha = 0.25, qnts.smooth = FALSE,
     legend = TRUE)

plot(sim, y = c("se.flow", "ei.flow", "ir.flow", "d.flow"),
     mean.col = pal, mean.lwd = 1, mean.smooth = TRUE,
     qnts.col = pal, qnts.alpha = 0.25, qnts.smooth = TRUE,
     legend = TRUE)

df <- as.data.frame(sim, out = "mean")
df
