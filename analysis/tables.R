
##
## COVID-19 Cruise Ship Network Model
## Epidemic Model
##
## Authors: Samuel M. Jenness
## Date: February 2020
##

suppressPackageStartupMessages(library("EpiModelCOVID"))
suppressPackageStartupMessages(library("tidyverse"))
source("analysis/fx.R")


## Table 2
ref.sim <- 2000
base <- list.files("analysis/data", pattern = as.character(ref.sim), full.names = TRUE)
load(base)
sim.base <- sim
ref <- epi_stats(sim.base, table.num = 2)
ref

cf.sims <- 2001:2025
cfset <- do.call("rbind", lapply(cf.sims, make_row, 2))
all <- add_column(full_join(ref, cfset),
                  scenario = c(ref.sim, cf.sims), .before = 1)
all

write_csv(all, "analysis/T2.csv")


## Table 4
ref.sim <- 4000
base <- list.files("analysis/data", pattern = as.character(ref.sim), full.names = TRUE)
load(base)
sim.base <- sim
ref <- epi_stats(sim.base, table.num = 4)
ref

cf.sims <- 4001:4016
cfset <- do.call("rbind", lapply(cf.sims, make_row, 4))
all <- add_column(full_join(ref, cfset),
                  scenario = c(ref.sim, cf.sims), .before = 1)
all

write_csv(all, "analysis/T4.csv")


## Table 5
ref.sim <- 5000
base <- list.files("analysis/data", pattern = as.character(ref.sim), full.names = TRUE)
load(base)
sim.base <- sim
ref <- epi_stats(sim.base, table.num = 4)
ref

cf.sims <- 5001:5016
cfset <- do.call("rbind", lapply(cf.sims, make_row, 4))
all <- add_column(full_join(ref, cfset),
                  scenario = c(ref.sim, cf.sims), .before = 1)
all

write_csv(all, "analysis/T5.csv")


## Table 6
ref.sim <- 6004
base <- list.files("analysis/data", pattern = as.character(ref.sim), full.names = TRUE)
load(base)
sim.base <- sim
ref <- epi_stats(sim.base, table.num = 2)
ref

cf.sims <- 6000:6007
cfset <- do.call("rbind", lapply(cf.sims, make_row, 2))
all <- add_column(full_join(ref, cfset),
                  scenario = c(ref.sim, cf.sims), .before = 1)
all

write_csv(all, "analysis/T6a.csv")

ref.sim <- 6012
base <- list.files("analysis/data", pattern = as.character(ref.sim), full.names = TRUE)
load(base)
sim.base <- sim
ref <- epi_stats(sim.base, table.num = 2)
ref

cf.sims <- 6008:6015
cfset <- do.call("rbind", lapply(cf.sims, make_row, 2))
all <- add_column(full_join(ref, cfset),
                  scenario = c(ref.sim, cf.sims), .before = 1)
all

write_csv(all, "analysis/T6b.csv")
