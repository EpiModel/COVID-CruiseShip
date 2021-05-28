
##
## COVID-19 Cruise Ship Network Model
## Epidemic Model
##
## Authors: Samuel M. Jenness
## Date: February 2020
##

# ABC ---------------------------------------------------------------------

install.packages("EasyABC")
library("EasyABC")

f <- function(x) {
  library("EpiModelCOVID")
  est.pre <- readRDS("est/est.pre.v2.rds")
  est.post <- readRDS("est/est.post.base.v2.rds")
  est <- c(est.pre, est.post)
  set.seed(x[1])
  source("01.epi-params.R")
  params <- param.net(inf.prob.pp = x[7],
                      inf.prob.pp.inter.rr = 0.6,
                      inf.prob.pp.inter.time = Inf,
                      act.rate.pp = x[8],
                      act.rate.pp.inter.rr = 1,
                      act.rate.pp.inter.time = Inf,
                      inf.prob.pc = x[7],
                      inf.prob.pc.inter.rr = 0.6,
                      inf.prob.pc.inter.time = 15,
                      act.rate.pc = 1,
                      act.rate.pc.inter.rr = 1,
                      act.rate.pc.inter.time = Inf,
                      inf.prob.cc = x[7],
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
                      dx.rate.sympt = c(rep(0, 15), rep(x[2], 5), rep(x[3], 5), rep(x[4], 100)),
                      dx.rate.other = c(rep(0, 15), rep(0, 5), rep(x[5], 5), rep(x[6], 100)),
                      allow.rescreen = FALSE,
                      mort.rates = mr_vec,
                      mort.dis.mult = 180,
                      exit.rate.pass = 0,
                      exit.rate.crew = 0,
                      exit.elig.status = c("ip", "ic"),
                      exit.require.dx = FALSE)

  inits <- init.net(e.num.pass = 8,
                    e.num.crew = 0)
  controls <- control.net(nsteps = 31,
                         nsims = 1, #100,
                         ncores = 1, #4,
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
                         tergmLite = TRUE,
                         verbose = FALSE)
  sim <- netsim(est, params, inits, controls)
  sim <- mutate_epi(sim, se.cuml = cumsum(se.flow),
                    dx.cuml = cumsum(nDx),
                    dx.pos.cuml = cumsum(nDx.pos),
                    totI = e.num + a.num + ip.num + ic.num)
  df <- as.data.frame(sim)
  # out <- df$dx.pos.cuml[c(16, 21, 26, 31)]
  out <- df$dx.pos.cuml[c(26, 31)]
  return(out)
}

d <- f(c(sample(1e5, 1), 0.5, 0, 0.6, 0.01, 0.15, 0.11))
d

priors <- list(c("unif", 0.10, 0.30),
               c("unif", 0.10, 0.30),
               c("unif", 0.70, 0.90),
               c("unif", 0.01, 0.15),
               c("unif", 0.15, 0.30),
               c("unif", 0.05, 0.15),
               c("unif", 1, 9))

targets <- pos.tests.day[c(16, 21, 26, 31)]
targets <- pos.tests.day[c(26, 31)]

fit1 <- ABC_rejection(model = f,
                      prior = priors,
                      nb_simul = 1000,
                      summary_stat_target = targets,
                      tol = 0.05,
                      use_seed = TRUE,
                      n_cluster = parallel::detectCores() - 1)
save(fit1, file = "fit1.10k.norej.rda")
abc <- fit1
saveRDS(abc, file = "est/abc.rds")

p <- function(dat) {

}

apply(fit1$param, 2, summary)
apply(fit1$stats, 2, summary)
summary(fit1$stats)

targets
ssd <- (fit1$stats[, 1] - targets[1])^2 + (fit1$stats[, 2] - targets[2])^2 +
       (fit1$stats[, 3] - targets[3])^2 + (fit1$stats[, 4] - targets[4])^2

ssd.top10 <- head(sort(ssd), 100)
colMeans(fit1$param[ssd.top10, ])
colMeans(fit1$stats[ssd.top10, ])

told <- abs(fit1$stats[, 1] - targets[1]) < 5 &
  abs(fit1$stats[, 2] - targets[2]) < 25

apply(fit1$param[told, ], 2, summary)
apply(fit1$stats[told, ], 2, summary)

fit2 <- ABC_sequential(method = "Lenormand",
                       model = f,
                       prior = priors,
                       summary_stat_target = targets,
                       nb_simul = 300,
                       p_acc = 0.05,
                       alpha = 0.25,
                       progress_bar = TRUE,
                       use_seed = TRUE,
                       n_cluster = parallel::detectCores())

apply(fit2$param, 2, summary)
apply(fit2$stats, 2, summary)

