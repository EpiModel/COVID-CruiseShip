
##
## COVID-19 Cruise Ship Network Model
##
## Authors: Samuel M. Jenness
## Date: February 2020
##

## Load EpiModel
remotes::install_github("statnet/EpiModel")
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

crew.ids <- which(nw %v% "type" == "c")
crew.ids
room.ids

n.sectors <- 10
room.sectors <- apportion_lr(length(room.ids), 1:n.sectors,
                             rep(1/n.sectors, n.sectors))
# head(data.frame(room.ids, room.sectors), 200)
df.match <- data.frame(room.ids, room.sectors)

sector <- rep(NA, n)
for (id in pass.ids) {
  sector[id] <- df.match[df.match$room.ids == room.ids.pass[id], "room.sectors"]
}
sector[pass.ids]

room.sectors.c <- apportion_lr(length(crew.ids), 1:n.sectors,
                               rep(1/n.sectors, n.sectors), shuffled = TRUE)
sector[crew.ids] <- room.sectors.c
sector[crew.ids]
sector

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
nw <- set.vertex.attribute(nw, "sector", sector)

# Model 1: pass/pass contacts within rooms each day

# Define the formation model
formation <- ~edges +
              nodematch("pass.room") +
              offset(nodefactor("type", levels = -2))

# Input target statistics for each term
# one persistent pass/pass contact (isolation)
md <- 1
edges <- n.pass * md/2
absdiff <- edges * 5

pre.isolation.scale <- c(2, 1)

target.stats <- c(edges, edges)
target.stats.pre <- target.stats * pre.isolation.scale

# Parameterize the dissolution model
coef.diss <- dissolution_coefs(dissolution = ~offset(edges), duration = 1)
coef.diss

# Fit the model
est1 <- netest(nw, formation, target.stats, coef.diss, coef.form = -Inf,
               set.control.ergm = control.ergm(MCMLE.maxit = 500))
summary(est1)
mcmc.diagnostics(est1$fit)

# Model diagnostics
dx1a <- netdx(est1, nsims = 1e4, dynamic = FALSE,
              nwstats.formula = ~edges + nodefactor("type", levels = NULL) + absdiff("age"),
              set.control.ergm = control.simulate.ergm(MCMC.burnin = 1e6))
print(dx1a)
plot(dx1a, sim.lines = TRUE)

# Pre-isolation model
est1.pre <- netest(nw, formation, target.stats.pre, coef.diss, coef.form = -Inf,
               set.control.ergm = control.ergm(MCMLE.maxit = 500))
summary(est1.pre)
mcmc.diagnostics(est1.pre$fit)

dx1a.pre <- netdx(est1.pre, nsims = 1e4, dynamic = FALSE,
              nwstats.formula = ~edges + nodefactor("type", levels = NULL) + absdiff("age"),
              set.control.ergm = control.simulate.ergm(MCMC.burnin = 1e6))
print(dx1a.pre)


## Model 2: crew/crew contacts each day

# about 2 ongoing contacts a day, but max at 3
formation2 <- ~edges +
               nodematch("sector") +
               offset(degrange(from = 4)) +
               offset(nodefactor("type", levels = -1))

md <- 2
edges <- n.crew * md/2
target.stats2 <- c(edges, edges)

# Dissolution model
coef.diss2 <- dissolution_coefs(dissolution = ~offset(edges), duration = 1)
coef.diss2

# Fit the model
est2 <- netest(nw, formation2, target.stats2, coef.diss2, coef.form = c(-Inf, -Inf),
               set.control.ergm = control.ergm(MCMLE.maxit = 500))
summary(est2)
mcmc.diagnostics(est2$fit)

dx2a <- netdx(est2, nsims = 1e4, dynamic = FALSE,
             nwstats.formula = ~edges + nodefactor("type", levels = NULL) + absdiff("age"),
             set.control.ergm = control.simulate.ergm(MCMC.burnin = 1e6))
print(dx2a)
plot(dx2a, sim.lines = TRUE)


## Model 3: crew/pass contacts each day

# crew/pass contacts:
# 3 times a day
cp.edges <- 3*n.rooms

formation3 <- ~edges + nodematch("sector") + nodematch("type")
target.stats3 <- c(cp.edges, cp.edges, 0)

coef.diss3 <- dissolution_coefs(dissolution = ~offset(edges), duration = 1)

est3 <- netest(nw, formation3, target.stats3, coef.diss3,
               set.control.ergm = control.ergm(MCMLE.maxit = 500))
summary(est3)
mcmc.diagnostics(est3$fit)

dx3a <- netdx(est3, nsims = 1e4, dynamic = FALSE,
              nwstats.formula = ~edges + nodemix("type", levels = NULL))
print(dx3a)

# sim1 <- simulate(est3$fit)
# sim1
# el1 <- as.edgelist(sim1)
# head(el1, 25)
# matrix(type[el1], ncol = 2)
# summary(sim1 ~ degree(0, by = "type"))
# # table(tabulate(pass.room[el1[, 1]], n.rooms))
# summary(get_degree(el1)[pass.ids])
# summary(get_degree(el1)[crew.ids])
# n.rooms/n.crew

## save out the data

# post isolation
est <- list(est1, est2, est3)
saveRDS(est, file = "est/est.covid.rds")

# pre isolation
# est <- list(est1.pre, est2, est3)
# saveRDS(est, file = "est/est.pre.covid.rds")



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
                   act.rate.pc = 1,
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
                   act.rate.dx.inter.rr = 0.1,
                   act.rate.dx.inter.time = 15,
                   act.rate.sympt.inter.rr = 0.5,
                   act.rate.sympt.inter.time = 15,
                   ea.rate = 1/3,
                   ar.rate = 1/3,
                   eip.rate = 1/3,
                   ipic.rate = 1/5,
                   icr.rate = 1/2,
                   dx.start = 10,
                   dx.rate.pass = 0.1,
                   dx.rate.crew = 0.1,
                   dx.elig.status = c("s", "e", "a", "ip", "ic"),
                   mort.rates = mr_vec,
                   mort.dis.mult = 1000,
                   exit.rate.pass = 0,
                   exit.rate.crew = 0,
                   exit.elig.status = c("ip", "ic"),
                   exit.require.dx = FALSE)

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
print(sim)

df <- as.data.frame(sim, out = "mean")
round(df, 2)

# 8.2 deaths expected
sum(df$d.flow)
sum(df$se.flow)

(sum(df$d.flow)-8.2)/sum(df$se.flow)

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
