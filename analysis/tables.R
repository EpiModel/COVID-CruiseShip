
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

## Table 1
ref.sim <- 1000
base <- list.files("analysis/dat", pattern = as.character(ref.sim), full.names = TRUE)
load(base)
sim.base <- sim
ref <- epi_stats(sim.base, table.num = 1)
ref

cf.sims <- 1001:1013
cfset <- do.call("rbind", lapply(cf.sims, make_row, 1))
all <- add_column(full_join(ref, cfset),
                  scenario = c(ref.sim, cf.sims), .before = 1)
all

write_csv(all, "analysis/T1.csv")


## Table 2
# Top half
ref.sim <- 2000
base <- list.files("analysis/dat", pattern = as.character(ref.sim), full.names = TRUE)
load(base)
sim.base <- sim
ref <- epi_stats(sim.base, table.num = 2)
ref

cf.sims <- 2001:2009
cfset <- do.call("rbind", lapply(cf.sims, make_row, 2))
all <- add_column(full_join(ref, cfset),
                  scenario = c(ref.sim, cf.sims), .before = 1)
all

write_csv(all, "analysis/T2.csv")

# Bottom half
ref.sim <- 2010
base <- list.files("analysis/dat", pattern = as.character(ref.sim), full.names = TRUE)
load(base)
sim.base <- sim
ref <- epi_stats(sim.base, table.num = 2)
ref

cf.sims <- 2011:2019
cfset <- do.call("rbind", lapply(cf.sims, make_row, 2))
all <- add_column(full_join(ref, cfset),
                  scenario = c(ref.sim, cf.sims), .before = 1)
all

write_csv(all, "analysis/T2b.csv")

## Supplemental Table 2

ref.sim <- 2100
base <- list.files("analysis/dat", pattern = as.character(ref.sim), full.names = TRUE)
load(base)
sim.base <- sim
ref <- epi_stats(sim.base, table.num = 2)
ref

cf.sims <- 2101:2109
cfset <- do.call("rbind", lapply(cf.sims, make_row, 2))
all <- add_column(full_join(ref, cfset),
                  scenario = c(ref.sim, cf.sims), .before = 1)
all

write_csv(all, "analysis/ST2.csv")


## Table 3

# Top half
ref.sim <- 3001
base <- list.files("analysis/dat", pattern = as.character(ref.sim), full.names = TRUE)
load(base)
sim.base <- sim
ref <- epi_stats(sim.base, table.num = 1)
ref

cf.sims <- 3000:3005
cfset <- do.call("rbind", lapply(cf.sims, make_row, 1))
all <- add_column(full_join(ref, cfset),
                  scenario = c(ref.sim, cf.sims), .before = 1)
all

write_csv(all, "analysis/T3a.csv")

# Bottom half
ref.sim <- 3007
base <- list.files("analysis/dat", pattern = as.character(ref.sim), full.names = TRUE)
load(base)
sim.base <- sim
ref <- epi_stats(sim.base, table.num = 1)
ref

cf.sims <- 3006:3011
cfset <- do.call("rbind", lapply(cf.sims, make_row, 1))
all <- add_column(full_join(ref, cfset),
                  scenario = c(ref.sim, cf.sims), .before = 1)
all

write_csv(all, "analysis/T3b.csv")


## Table 4

# Top Half
ref.sim <- 4000
base <- list.files("analysis/dat", pattern = as.character(ref.sim), full.names = TRUE)
load(base)
sim.base <- sim
ref <- epi_stats(sim.base, table.num = 4)
ref

cf.sims <- 4001:4012
cfset <- do.call("rbind", lapply(cf.sims, make_row, 4))
all <- add_column(full_join(ref, cfset),
                  scenario = c(ref.sim, cf.sims), .before = 1)
all

write_csv(all, "analysis/T4a.csv")


# Bottom Half
ref.sim <- 4013
base <- list.files("analysis/dat", pattern = as.character(ref.sim), full.names = TRUE)
load(base)
sim.base <- sim
ref <- epi_stats(sim.base, table.num = 4)
ref

cf.sims <- 4014:4025
cfset <- do.call("rbind", lapply(cf.sims, make_row, 4))
all <- add_column(full_join(ref, cfset),
                  scenario = c(ref.sim, cf.sims), .before = 1)
all

write_csv(all, "analysis/T4b.csv")


## Table 5

# Top half
ref.sim <- 5006
base <- list.files("analysis/dat", pattern = as.character(ref.sim), full.names = TRUE)
load(base)
sim.base <- sim
ref <- epi_stats(sim.base, table.num = 1)
ref

cf.sims <- 5000:5006
cfset <- do.call("rbind", lapply(cf.sims, make_row, 1))
all <- add_column(full_join(ref, cfset),
                  scenario = c(ref.sim, cf.sims), .before = 1)
all

write_csv(all, "analysis/T5a.csv")

# Bottom half
ref.sim <- 5013
base <- list.files("analysis/dat", pattern = as.character(ref.sim), full.names = TRUE)
load(base)
sim.base <- sim
ref <- epi_stats(sim.base, table.num = 1)
ref

cf.sims <- 5007:5013
cfset <- do.call("rbind", lapply(cf.sims, make_row, 1))
all <- add_column(full_join(ref, cfset),
                  scenario = c(ref.sim, cf.sims), .before = 1)
all

write_csv(all, "analysis/T5b.csv")
