
library("EpiModelHPC")

nsims <- 1000

# Table 2 -----------------------------------------------------------------

## Base Model
vars <- list(NLT = 15,
             PPE = 15,
             ARPP = 1,
             ARPC = 1,
             ARCC = 1)

sbatch_master(vars = vars,
              master.file = "master.T2.sh",
              runsim.file = "runsim.sh",
              rscript.file = "04.epi-model-hpc.R",
              build.runsim = TRUE,
              simno.start = 2000,
              append = FALSE,
              ckpt = FALSE,
              nsims = nsims,
              ncores = 28,
              narray = 1,
              walltime = "00:10:00",
              mem = "100G")


## Network Isolation Timing

vars <- list(NLT = c(1, 5, 10, 20, 25, Inf),
             PPE = c(15, Inf),
             ARPP = 1,
             ARPC = 1,
             ARCC = 1)

sbatch_master(vars = vars,
              master.file = "master.T2.sh",
              runsim.file = "runsim.sh",
              rscript.file = "04.epi-model-hpc.R",
              build.runsim = TRUE,
              append = TRUE,
              ckpt = FALSE,
              nsims = nsims,
              ncores = 28,
              narray = 1,
              walltime = "00:10:00",
              mem = "100G")


## Act Rate Reduction --------------------------------------------------

vars <- list(NLT = 15,
             PPE = 15,
             ARPP = c(1, 0.5, 0.1, 1, 1, 1, 1, 1, 1),
             ARPC = c(1, 1, 1, 1, 0.5, 0.1, 1, 1, 1),
             ARCC = c(1, 1, 1, 1, 1, 1, 1, 0.5, 0.1))

sbatch_master(vars = vars,
              expand.vars = FALSE,
              master.file = "master.T2.sh",
              runsim.file = "runsim.sh",
              rscript.file = "04.epi-model-hpc.R",
              build.runsim = TRUE,
              append = TRUE,
              ckpt = FALSE,
              nsims = nsims,
              ncores = 28,
              narray = 1,
              walltime = "00:10:00",
              mem = "100G")

