
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

## 1a: Base post-lockdown model

# Define the formation model
formation <- ~edges +
  nodematch("pass.room") +
  offset(nodefactor("type", levels = -2))

# Input target statistics for each term
# one persistent pass/pass contact (isolation)
md <- 1
edges <- n.pass * md/2
absdiff <- edges * 5

target.stats <- c(edges, edges)

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

## 1b. Pre-isolation model: 5x the contacts, retain same within-cabin rate
pre.isolation.scale <- c(5, 1)
target.stats.pre <- target.stats * pre.isolation.scale
est1.pre <- netest(nw, formation, target.stats.pre, coef.diss, coef.form = -Inf,
                   set.control.ergm = control.ergm(MCMLE.maxit = 500))
summary(est1.pre)
mcmc.diagnostics(est1.pre$fit)

dx1a.pre <- netdx(est1.pre, nsims = 1e4, dynamic = FALSE,
                  nwstats.formula = ~edges + nodefactor("type", levels = NULL) + absdiff("age"),
                  set.control.ergm = control.simulate.ergm(MCMC.burnin = 1e6))
print(dx1a.pre)



# Model 2: Crew/Crew Contacts ---------------------------------------------

# 2 contacts a day, but max at 3, with strong sectorization
formation2 <- ~edges +
               nodematch("sector") +
               offset(degrange(from = 4)) +
               offset(nodefactor("type", levels = -1))

md <- 2
edges <- n.crew * md/2

# assume 95% of contacts are within sector
target.stats2 <- c(edges, edges*0.95)

# Dissolution model
coef.diss2 <- dissolution_coefs(dissolution = ~offset(edges), duration = 1)
coef.diss2

# Fit the model
est2 <- netest(nw, formation2, target.stats2, coef.diss2, coef.form = c(-Inf, -Inf),
               set.control.ergm = control.ergm(MCMLE.maxit = 500))
summary(est2)
mcmc.diagnostics(est2$fit)

dx2a <- netdx(est2, nsims = 1e4, dynamic = FALSE,
              nwstats.formula = ~edges + nodefactor("type", levels = NULL),
              set.control.ergm = control.simulate.ergm(MCMC.burnin = 1e6))
print(dx2a)

# pre-isolation model: 2x contacts, relax sectorization, and remove degree constraint
formation2.pre <- ~edges +
                   nodematch("sector") +
                   offset(nodefactor("type", levels = -1))
pre.isolation.scale2 <- c(2, 0.5)
target.stats2.pre <- target.stats2 * pre.isolation.scale2

est2.pre <- netest(nw, formation2.pre, target.stats2.pre, coef.diss2, coef.form = -Inf,
                   set.control.ergm = control.ergm(MCMLE.maxit = 500))
summary(est2.pre)
mcmc.diagnostics(est2.pre$fit)

dx2a.pre <- netdx(est2.pre, nsims = 1e4, dynamic = FALSE,
                  nwstats.formula = ~edges + nodefactor("type", levels = NULL),
                  set.control.ergm = control.simulate.ergm(MCMC.burnin = 1e6))
print(dx2a.pre)



# Model 3: Crew/Pass Contacts ---------------------------------------------

# crew/pass contacts:
# 3 times a day per room
cp.edges <- 3*n.rooms

formation3 <- ~edges + nodematch("sector") + nodematch("type")
target.stats3 <- c(cp.edges, cp.edges*0.98, 0)

coef.diss3 <- dissolution_coefs(dissolution = ~offset(edges), duration = 1)

est3 <- netest(nw, formation3, target.stats3, coef.diss3,
               set.control.ergm = control.ergm(MCMLE.maxit = 500))
summary(est3)
mcmc.diagnostics(est3$fit)

dx3a <- netdx(est3, nsims = 1e4, dynamic = FALSE,
              nwstats.formula = ~edges + nodemix("type", levels = NULL))
print(dx3a)

## additional diagnostics
# sim1 <- simulate(est3$fit)
# sim1
# el1 <- as.edgelist(sim1)
# head(el1, 25)
# matrix(type.attr[el1], ncol = 2)
# summary(sim1 ~ degree(0, by = "type"))
# table(tabulate(pass.room[el1[, 1]], n.rooms))
# summary(get_degree(el1)[pass.ids])
# summary(get_degree(el1)[crew.ids])
# n.rooms/n.crew

# pre-isolation model: 3x contacts and remove sectorization
formation3.pre <- ~edges + nodematch("type")
target.stats3.pre <- c(cp.edges*3, 0)

est3.pre <- netest(nw, formation3.pre, target.stats3.pre, coef.diss3,
                   set.control.ergm = control.ergm(MCMLE.maxit = 500))
summary(est3.pre)
mcmc.diagnostics(est3.pre$fit)

dx3a.pre <- netdx(est3.pre, nsims = 1e4, dynamic = FALSE,
                  nwstats.formula = ~edges + nodemix("type", levels = NULL) +
                                     nodematch("sector"))
print(dx3a.pre)


## save out the data

# post isolation
est.post <- list(est1, est2, est3)
saveRDS(est.post, file = "est/est.covid-post.rds")

# pre isolation
est.pre <- list(est1.pre, est2.pre, est3.pre)
saveRDS(est.pre, file = "est/est.covid-pre.rds")
