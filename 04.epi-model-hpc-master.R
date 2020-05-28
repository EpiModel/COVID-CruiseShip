
library("EpiModelHPC")

nsims <- 1000
ckpt <- TRUE

# Table 2 -----------------------------------------------------------------

## Base Model
vars <- list(NLT = 15,
             PPE = 15,
             ARPP = 1,
             ARPC = 1,
             ARCC = 1)

sbatch_master(vars = vars,
              master.file = "master.T2.sh",
              runsim.file = "runsim.T2.sh",
              rscript.file = "04.epi-model-hpc-t2.R",
              build.runsim = TRUE,
              simno.start = 2000,
              append = FALSE,
              ckpt = ckpt,
              nsims = nsims,
              ncores = 28,
              narray = 1,
              walltime = "00:10:00",
              mem = "100G")


## Network Isolation Timing

vars <- list(NLT = c(1, 5, 10, 20, 25, Inf),
             PPE = 15,
             ARPP = 1,
             ARPC = 1,
             ARCC = 1)

sbatch_master(vars = vars,
              master.file = "master.T2.sh",
              runsim.file = "runsim.T2.sh",
              rscript.file = "04.epi-model-hpc-t2.R",
              build.runsim = TRUE,
              append = TRUE,
              ckpt = ckpt,
              nsims = nsims,
              ncores = 28,
              narray = 1,
              walltime = "00:10:00",
              mem = "100G")

## Network Isolation Timing

vars <- list(NLT = c(1, 5, 10, 15, 20, 25, Inf),
             PPE = Inf,
             ARPP = 1,
             ARPC = 1,
             ARCC = 1)

sbatch_master(vars = vars,
              master.file = "master.T2.sh",
              runsim.file = "runsim.T2.sh",
              rscript.file = "04.epi-model-hpc-t2.R",
              build.runsim = TRUE,
              append = TRUE,
              ckpt = ckpt,
              nsims = nsims,
              ncores = 28,
              narray = 1,
              walltime = "00:10:00",
              mem = "100G")


## Act Rate Reduction

vars <- list(NLT = 15,
             PPE = 15,
             ARPP = c(0.75, 0.5, 0.25, 0.1, 1, 1, 1, 1, 1, 1, 1, 1),
             ARPC = c(1, 1, 1, 1, 0.75, 0.5, 0.25, 0.1, 1, 1, 1, 1),
             ARCC = c(1, 1, 1, 1, 1, 1, 1, 1, 0.75, 0.5, 0.25, 0.1))

sbatch_master(vars = vars,
              expand.vars = FALSE,
              master.file = "master.T2.sh",
              runsim.file = "runsim.T2.sh",
              rscript.file = "04.epi-model-hpc-t2.R",
              build.runsim = TRUE,
              append = TRUE,
              ckpt = ckpt,
              nsims = nsims,
              ncores = 28,
              narray = 1,
              walltime = "00:10:00",
              mem = "100G")


# Table 3 -----------------------------------------------------------------




# Table 4 -----------------------------------------------------------------

## Varying Asymptomatic Diagnosis Rates with Day 15 Lockdown
vars <- list(NLT = 15,
             PPE = 15,
             ARPP = 1,
             ARPC = 1,
             ARCC = 1,
             ADM = c(1, 1.5, 2, 5, 10),
             SII = 0.1,
             DII = 0.1)

sbatch_master(vars = vars,
              master.file = "master.T4.sh",
              runsim.file = "runsim.T4.sh",
              rscript.file = "04.epi-model-hpc-t4.R",
              build.runsim = TRUE,
              simno.start = 4000,
              append = FALSE,
              ckpt = ckpt,
              nsims = nsims,
              ncores = 28,
              narray = 1,
              walltime = "00:10:00",
              mem = "100G")

vars <- list(NLT = 15,
             PPE = 15,
             ARPP = 1,
             ARPC = 1,
             ARCC = 1,
             ADM = 1,
             SII = 1 - c(1, 0.9, 0.75, 0.50, 0.25, 0),
             DII = 0.1)

sbatch_master(vars = vars,
              master.file = "master.T4.sh",
              runsim.file = "runsim.T4.sh",
              rscript.file = "04.epi-model-hpc-t4.R",
              build.runsim = TRUE,
              append = TRUE,
              ckpt = ckpt,
              nsims = nsims,
              ncores = 28,
              narray = 1,
              walltime = "00:10:00",
              mem = "100G")

vars <- list(NLT = 15,
             PPE = 15,
             ARPP = 1,
             ARPC = 1,
             ARCC = 1,
             ADM = 1,
             SII = 0.1,
             DII = 1 - c(1, 0.9, 0.75, 0.50, 0.25, 0))

sbatch_master(vars = vars,
              master.file = "master.T4.sh",
              runsim.file = "runsim.T4.sh",
              rscript.file = "04.epi-model-hpc-t4.R",
              build.runsim = TRUE,
              append = TRUE,
              ckpt = ckpt,
              nsims = nsims,
              ncores = 28,
              narray = 1,
              walltime = "00:10:00",
              mem = "100G")

# Table 5 -----------------------------------------------------------------

## Varying Asymptomatic Diagnosis Rates with No Lockdown and No PPE
vars <- list(NLT = Inf,
             PPE = Inf,
             ARPP = 1,
             ARPC = 1,
             ARCC = 1,
             ADM = c(1, 1.5, 2, 5, 10),
             SII = 0.1,
             DII = 0.1)

sbatch_master(vars = vars,
              master.file = "master.T5.sh",
              runsim.file = "runsim.T5.sh",
              rscript.file = "04.epi-model-hpc-t4.R",
              build.runsim = TRUE,
              simno.start = 5000,
              append = FALSE,
              ckpt = ckpt,
              nsims = nsims,
              ncores = 28,
              narray = 1,
              walltime = "00:10:00",
              mem = "100G")

## Varying Symptomatic Isolation Intensity at Lockdown

vars <- list(NLT = Inf,
             PPE = Inf,
             ARPP = 1,
             ARPC = 1,
             ARCC = 1,
             ADM = 1,
             SII = 1 - c(1, 0.9, 0.75, 0.50, 0.25, 0),
             DII = 0.1)

sbatch_master(vars = vars,
              master.file = "master.T5.sh",
              runsim.file = "runsim.T5.sh",
              rscript.file = "04.epi-model-hpc-t4.R",
              build.runsim = TRUE,
              append = TRUE,
              ckpt = ckpt,
              nsims = nsims,
              ncores = 28,
              narray = 1,
              walltime = "00:10:00",
              mem = "100G")

## Varying Diagnosed Isolation Intensity at Lockdown

vars <- list(NLT = Inf,
             PPE = Inf,
             ARPP = 1,
             ARPC = 1,
             ARCC = 1,
             ADM = 1,
             SII = 0.1,
             DII = 1 - c(1, 0.9, 0.75, 0.50, 0.25, 0))

sbatch_master(vars = vars,
              master.file = "master.T5.sh",
              runsim.file = "runsim.T5.sh",
              rscript.file = "04.epi-model-hpc-t4.R",
              build.runsim = TRUE,
              append = TRUE,
              ckpt = ckpt,
              nsims = nsims,
              ncores = 28,
              narray = 1,
              walltime = "00:10:00",
              mem = "100G")


# Table 6 -----------------------------------------------------------------

# Timing of Asymptomatic Screening

## Asymptomatic Diagnosis Timing with No Lockdown and No PPE
vars <- list(NLT = Inf,
             PPE = Inf,
             ARPP = 1,
             ARPC = 1,
             ARCC = 1,
             ADM = 1,
             DII = 0.1,
             SII = 0.1,
             DXTIME = c(1, 2, 5, 10, 15, 20, 25, 50))

sbatch_master(vars = vars,
              master.file = "master.T6.sh",
              runsim.file = "runsim.T6.sh",
              rscript.file = "04.epi-model-hpc-t6.R",
              build.runsim = TRUE,
              simno.start = 6000,
              append = FALSE,
              ckpt = ckpt,
              nsims = nsims,
              ncores = 28,
              narray = 1,
              walltime = "00:10:00",
              mem = "100G")

## Asymptomatic Diagnosis Timing, with No Lockdown and Yes PPE
vars <- list(NLT = Inf,
             PPE = 1,
             ARPP = 1,
             ARPC = 1,
             ARCC = 1,
             ADM = 1,
             DII = 0.1,
             SII = 0.1,
             DXTIME = c(1, 2, 5, 10, 15, 20, 25, 50))

sbatch_master(vars = vars,
              master.file = "master.T6.sh",
              runsim.file = "runsim.T6.sh",
              rscript.file = "04.epi-model-hpc-t6.R",
              build.runsim = TRUE,
              append = TRUE,
              ckpt = ckpt,
              nsims = nsims,
              ncores = 28,
              narray = 1,
              walltime = "00:10:00",
              mem = "100G")

