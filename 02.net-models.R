
##
## COVID-19 Cruise Ship Network Model
## Network Parameters and Model
##
## Authors: Samuel M. Jenness
## Date: February 2020
##

library("EpiModelCOVID")


# Model Parameters --------------------------------------------------------

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

crew.ids <- which(type.attr == "c")
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

table(sector, type.attr)

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



# Model 1. Pass/Pass Contacts ---------------------------------------------

# Base Target Stats
md <- 5
edges <- n.pass * md/2
target.stats1 <- c(edges, edges)

# Formation model
formation1 <- ~edges +
               nodematch("pass.room") +
               offset(nodefactor("type", levels = -2))

## 1a. Pre-Lockdown Model
target.stats1.pre <- target.stats1
coef.diss <- dissolution_coefs(dissolution = ~offset(edges), duration = 1)
est1.pre <- netest(nw, formation1, target.stats1.pre, coef.diss, coef.form = -Inf,
                   set.control.ergm = control.ergm(MCMLE.maxit = 500))
summary(est1.pre)

mcmc.diagnostics(est1.pre$fit)
dx1.pre <- netdx(est1.pre, nsims = 1e4, dynamic = FALSE,
                 nwstats.formula = ~edges + nodefactor("type", levels = NULL),
                 set.control.ergm = control.simulate.ergm(MCMC.burnin = 1e6))
print(dx1.pre)


## 1b. Post-Lockdown Model: 20% of contact rate, all within cabin
post.isolation.scale <- c(0.2, 1)
target.stats1.post <- target.stats1 * post.isolation.scale

# Fit the model
est1.post <- netest(nw, formation1, target.stats1.post, coef.diss, coef.form = -Inf,
                    set.control.ergm = control.ergm(MCMLE.maxit = 500))
summary(est1.post)

mcmc.diagnostics(est1.post$fit)
dx1.post <- netdx(est1.post, nsims = 1e4, dynamic = FALSE,
                  nwstats.formula = ~edges + nodefactor("type", levels = NULL),
                  set.control.ergm = control.simulate.ergm(MCMC.burnin = 1e6))
print(dx1.post)


# Model 2: Crew/Crew Contacts ---------------------------------------------

## 2a. Pre-Lockdown Model

# Target Stats Pre
md.pre <- 10
edges.pre <- n.crew * md/2
prop.within.sector.pre <- 0.50
target.stats2.pre <- c(edges.pre, edges.pre*prop.within.sector.pre)

formation2.pre <- ~edges +
                   nodematch("sector") +
                   offset(nodefactor("type", levels = -1))
coef.diss2 <- dissolution_coefs(dissolution = ~offset(edges), duration = 1)

est2.pre <- netest(nw, formation2.pre, target.stats2.pre, coef.diss2, coef.form = -Inf,
                   set.control.ergm = control.ergm(MCMLE.maxit = 500))
summary(est2.pre)

mcmc.diagnostics(est2.pre$fit)
dx2.pre <- netdx(est2.pre, nsims = 1e4, dynamic = FALSE,
                  nwstats.formula = ~edges + nodefactor("type", levels = NULL),
                  set.control.ergm = control.simulate.ergm(MCMC.burnin = 1e6))
print(dx2.pre)


## 2b. Post-Lockdown Model

# Target Stats Post
md.pre <- 2
edges.pre <- n.crew * md/2
prop.within.sector.post <- 0.98
target.stats2.post <- c(edges, edges*prop.within.sector.post)

formation2.post <- ~edges +
                    nodematch("sector") +
                    offset(nodefactor("type", levels = -1))

est2.post <- netest(nw, formation2.post, target.stats2.post, coef.diss2, coef.form = -Inf,
                    set.control.ergm = control.ergm(MCMLE.maxit = 500))
summary(est2.post)

mcmc.diagnostics(est2.post$fit)
dx2.post <- netdx(est2.post, nsims = 1e4, dynamic = FALSE,
                  nwstats.formula = ~edges + nodefactor("type", levels = NULL),
                  set.control.ergm = control.simulate.ergm(MCMC.burnin = 1e6))
print(dx2.post)


# Model 3: Crew/Pass Contacts ---------------------------------------------

## 3a. Pre-Lockdown Model
md.pre <- 8
edges.pre <- md.pre * n.rooms
target.stats3.pre <- c(edges.pre, 0)

formation3.pre <- ~edges + nodematch("type")
coef.diss3 <- dissolution_coefs(dissolution = ~offset(edges), duration = 1)

est3.pre <- netest(nw, formation3.pre, target.stats3.pre, coef.diss3,
                   set.control.ergm = control.ergm(MCMLE.maxit = 500))
summary(est3.pre)

mcmc.diagnostics(est3.pre$fit)
dx3.pre <- netdx(est3.pre, nsims = 1e4, dynamic = FALSE,
                 nwstats.formula = ~edges + nodemix("type", levels = NULL) +
                                    nodematch("sector"))
print(dx3.pre)


## 3b. Post-Lockdown Model

# 3 times a day per room
edges.post <- 3*n.rooms
prop.within.sector.post <- 0.98
target.stats3 <- c(edges.post, edges.post*prop.within.sector.post, 0)

formation3.post <- ~edges + nodematch("sector") + nodematch("type")

est3.post <- netest(nw, formation3.post, target.stats3, coef.diss3,
                    set.control.ergm = control.ergm(MCMLE.maxit = 500))
summary(est3.post)

mcmc.diagnostics(est3.post$fit)
dx3.post <- netdx(est3.post, nsims = 1e4, dynamic = FALSE,
                  nwstats.formula = ~edges + nodemix("type", levels = NULL))
print(dx3.post)


# Save Data ---------------------------------------------------------------

# Pre-Lockdown
est.pre <- list(est1.pre, est2.pre, est3.pre)
saveRDS(est.pre, file = "est/est.pre.rds")

# Post-Lockdown
est.post <- list(est1.post, est2.post, est3.post)
saveRDS(est.post, file = "est/est.post.base.rds")
