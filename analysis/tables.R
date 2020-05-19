
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

base <- list.files("analysis/data", pattern = "2000", full.names = TRUE)
load(base)
sim.base <- sim
ref <- epi_stats(sim.base)
ref

cf.sims <- 2001:2021
make_table <- function(x) {
  fn <- list.files(path = "analysis/data/",
                   pattern = paste0("sim.n",as.character(x)), full.names = TRUE)
  load(fn)
  sim.comp <- sim
  epi_stats(sim.base, sim.comp)
}
# make_table(2006)

t2set <- lapply(cf.sims, make_table)
t2set <- do.call("rbind", t2set)

t2 <- full_join(ref, t2set)
t2 <- add_column(t2, scenario = 2000:2021, .before = 1)
t2

write_csv(t2, "analysis/T2.csv")
