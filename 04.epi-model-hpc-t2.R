
##
## COVID-19 Cruise Ship Network Model
## Epidemic Model
##
## Authors: Samuel M. Jenness
## Date: February 2020
##

suppressPackageStartupMessages(library("EpiModelCOVID"))
library("EpiModelHPC")

# Read in fitted network models
est.pre <- readRDS("est/est.pre.rds")
est.post <- readRDS("est/est.post.base.rds")
est <- c(est.pre, est.post)

pull_env_vars(num.vars = c("NLT", "PPE",
                           "ARPP", "ARPC", "ARCC"))

# Base model parameters
source("01.epi-params.R")
param <- param.net(inf.prob.pp = 0.1,
                   inf.prob.pp.inter.rr = 0.6,
                   inf.prob.pp.inter.time = Inf,
                   act.rate.pp = 5,
                   act.rate.pp.inter.rr = 1,
                   act.rate.pp.inter.time = Inf,
                   inf.prob.pc = 0.1,
                   inf.prob.pc.inter.rr = 0.6,
                   inf.prob.pc.inter.time = 15,
                   act.rate.pc = 1,
                   act.rate.pc.inter.rr = 1,
                   act.rate.pc.inter.time = Inf,
                   inf.prob.cc = 0.1,
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
                   dx.rate.sympt = c(rep(0, 15), rep(0.10, 5), rep(0.4, 5), rep(0.6, 100)),
                   dx.rate.other = c(rep(0, 15), rep(0, 5), rep(0.07, 5), rep(0.19, 100)),
                   allow.rescreen = FALSE,
                   mort.rates = mr_vec,
                   mort.dis.mult = 205,
                   exit.rate.pass = 0,
                   exit.rate.crew = 0,
                   exit.elig.status = c("ip", "ic"),
                   exit.require.dx = FALSE)

# Intervention parameters
param$act.rate.pp.inter.rr = ARPP
param$act.rate.pp.inter.time = NLT
param$inf.prob.pc.inter.time = PPE
param$act.rate.pc.inter.rr = ARPC
param$act.rate.pc.inter.time = NLT
param$inf.prob.cc.inter.time = PPE
param$act.rate.cc.inter.rr = ARCC
param$act.rate.cc.inter.time = NLT
param$network.lockdown.time = NLT

# Initial conditions
init <- init.net(e.num.pass = 8,
                 e.num.crew = 0)

# Control settings
control <- control.net(simno = fsimno,
                       nsteps = 31,
                       nsims = nsims,
                       ncores = ncores,
                       initialize.FUN = init_covid_ship,
                       aging.FUN = aging_covid_ship,
                       departures.FUN = deaths_covid_ship,
                       offload.FUN = offload_covid_ship,
                       arrivals.FUN = NULL,
                       edges_correct.FUN = NULL,
                       resim_nets.FUN = resim_nets_covid_ship,
                       infection.FUN = infect_covid_ship,
                       recovery.FUN = progress_covid_ship,
                       dx.FUN = dx_covid_ship,
                       get_prev.FUN = prevalence_covid_ship,
                       module.order = c("aging.FUN",
                                        "departures.FUN",
                                        "offload.FUN",
                                        "resim_nets.FUN",
                                        "infection.FUN",
                                        "recovery.FUN",
                                        "dx.FUN",
                                        "get_prev.FUN"),
                       depend = TRUE,
                       skip.check = TRUE)

sim <- netsim(est, param, init, control)

savesim(sim, save.min = TRUE, save.max = FALSE, compress = TRUE)
process_simfiles(simno = simno, min.n = 1, nsims = nsims, compress = TRUE)

