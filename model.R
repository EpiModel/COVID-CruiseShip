
##
## COVID-19 Cruise Ship Network Model
##
## Authors: Samuel M. Jenness
## Date: February 2020
##

## Load EpiModel
suppressMessages(library(EpiModel))


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
formation = ~edges + nodematch("pass.room") + nodefactor("type", levels = -2)

# Input the appropriate target statistics for each term
# one contact per day
md <- 1
edges <- n.pass * md/2

target.stats <- c(edges, edges, 0)

# Parameterize the dissolution model
coef.diss <- dissolution_coefs(dissolution = ~offset(edges), duration = 1)
coef.diss

# Fit the model
est <- netest(nw, formation, target.stats, coef.diss,
              set.control.ergm = control.ergm(MCMLE.maxit = 500))

# Model diagnostics
dx <- netdx(est, nsims = 10000, dynamic = FALSE,
            nwstats.formula = ~edges + nodematch("pass.room") + nodefactor("type", levels = NULL))
print(dx)


## Model 2: crew/pass and crew/crew contacts each day

# model for worker/worker and worker/guest contact
# 5 contacts per day, 3 with guests (x 2 workers per time) and 2 within workers

# crew/crew contacts
cc <- 2*n.crew/2

# crew/pass contacts
cp <- 3*2*n/2

# pass/pass contacts
pp <- 0

formation2 <- ~nodemix("type", levels = NULL)
target.stats2 <- c(cc, cp, pp)

est2 <- netest(nw, formation2, target.stats2, coef.diss,
               set.control.ergm = control.ergm(MCMLE.maxit = 500))

dx2 <- netdx(est2, nsims = 10000, dynamic = FALSE,
            nwstats.formula = ~edges + nodemix("type", levels = NULL))
print(dx2)



# Epidemic model simulation -----------------------------------------------

# Model parameters
param <- param.net(inf.prob = 0.5, act.rate = 1,
                   ei.rate = 1/5.2, ir.rate = 1/7)

# Initial conditions
init <- init.net(i.num = 10)

# Read in the module functions
source("module-fx.R")

# Control settings
control <- control.net(nsteps = nsteps,
                       nsims = nsims,
                       ncores = ncores,
                       infection.FUN = infect,
                       progress.FUN = progress,
                       recovery.FUN = NULL)

# Run the network model simulation with netsim
sim <- netsim(est, param, init, control)
print(sim)

# Plot outcomes
par(mar = c(3,3,1,1), mgp = c(2,1,0))
plot(sim,
     mean.col = 1:4, mean.lwd = 1, mean.smooth = FALSE,
     qnts = 1, qnts.col = 1:4, qnts.alpha = 0.25, qnts.smooth = FALSE,
     legend = TRUE)

plot(sim, y = c("se.flow", "ei.flow", "ir.flow"),
     mean.col = 1:4, mean.lwd = 1, mean.smooth = TRUE,
     qnts.col = 1:4, qnts.alpha = 0.25, qnts.smooth = TRUE,
     ylim = c(0, 3), legend = TRUE)

# Average across simulations at beginning, middle, end
df <- as.data.frame(sim)
df[c(2, 100, 500), ]
