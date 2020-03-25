
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

# Initialize the network
nw <- network.initialize(n, directed = FALSE)
nw <- set.vertex.attribute(nw, "type", type.attr)
nw <- set.vertex.attribute(nw, "pass.room", room.ids.pass, pass.ids)


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


# Epidemic model simulation -----------------------------------------------

# Read in fitted network models
est <- readRDS("est/est.covid.rds")

# Model parameters
param <- param.net(inf.prob = 0.5, act.rate = 1,
                   ei.rate = 1/5.2, ir.rate = 1/7)

# Initial conditions
init <- init.net(e.num = 10)

# Read in the module functions
source("module-fx.R", echo = FALSE)

# Control settings
control <- control.net(nsteps = 60,
                       nsims = 24,
                       ncores = 8,
                       initialize.FUN = init_covid,
                       departures.FUN = NULL,
                       arrivals.FUN = NULL,
                       edges_correct.FUN = NULL,
                       resim_nets.FUN = resim_nets_covid,
                       infection.FUN = infect_covid,
                       recovery.FUN = progress_covid,
                       get_prev.FUN = prevalence_covid,
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

plot(sim, y = c("se.flow", "ei.flow", "ir.flow"),
     mean.col = pal, mean.lwd = 1, mean.smooth = TRUE,
     qnts.col = pal, qnts.alpha = 0.25, qnts.smooth = TRUE,
     legend = TRUE)
