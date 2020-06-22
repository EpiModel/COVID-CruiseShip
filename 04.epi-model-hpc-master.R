
library("EpiModelHPC")

nsims <- 1000
ckpt <- TRUE

# Table 1 -----------------------------------------------------------------

## Base Model
vars <- list(NLT = 15,
             PPE = 15,
             ARPP = 1,
             ARPC = 1,
             ARCC = 1)

sbatch_master(vars = vars,
              master.file = "master.T1.sh",
              runsim.file = "runsim.T1.sh",
              rscript.file = "04.epi-model-hpc-t1.R",
              build.runsim = TRUE,
              simno.start = 1000,
              append = FALSE,
              ckpt = ckpt,
              nsims = nsims,
              ncores = 28,
              narray = 1,
              walltime = "00:15:00",
              mem = "100G")


## Network Isolation Timing, with PPE

vars <- list(NLT = c(1, 5, 10, 20, 25, Inf),
             PPE = c(1, 5, 10, 20, 25, Inf),
             ARPP = 1,
             ARPC = 1,
             ARCC = 1)

sbatch_master(vars = vars,
              expand.vars = FALSE,
              master.file = "master.T1.sh",
              runsim.file = "runsim.T1.sh",
              rscript.file = "04.epi-model-hpc-t1.R",
              append = TRUE,
              ckpt = ckpt,
              nsims = nsims,
              ncores = 28,
              narray = 1,
              walltime = "00:15:00",
              mem = "100G")

## Network Isolation Timing, No PPE

vars <- list(NLT = c(1, 5, 10, 15, 20, 25, Inf),
             PPE = Inf,
             ARPP = 1,
             ARPC = 1,
             ARCC = 1)

sbatch_master(vars = vars,
              expand.vars = FALSE,
              master.file = "master.T1.sh",
              runsim.file = "runsim.T1.sh",
              rscript.file = "04.epi-model-hpc-t1.R",
              build.runsim = TRUE,
              append = TRUE,
              ckpt = ckpt,
              nsims = nsims,
              ncores = 28,
              narray = 1,
              walltime = "00:15:00",
              mem = "100G")




# Table 2 -----------------------------------------------------------------

## Act Rate Reduction, NLT and PPE at 15

vars <- list(NLT = 15,
             PPE = 15,
             ARPP = c(1, 0.5, 0.1, 0, 1, 1, 1, 1, 1, 1),
             ARPC = c(1, 1, 1, 1, 0.5, 0.1, 0, 1, 1, 1),
             ARCC = c(1, 1, 1, 1, 1, 1, 1, 0.5, 0.1, 0),
             ARRT = 15)

sbatch_master(vars = vars,
              expand.vars = FALSE,
              master.file = "master.T2.sh",
              runsim.file = "runsim.T2.sh",
              rscript.file = "04.epi-model-hpc-t1.R",
              build.runsim = TRUE,
              simno.start = 2000,
              append = FALSE,
              ckpt = ckpt,
              nsims = nsims,
              ncores = 28,
              narray = 1,
              walltime = "00:15:00",
              mem = "100G")


## Act Rate Reduction, No NLT, Yes PPE, ARRT at 1

vars <- list(NLT = Inf,
             PPE = 1,
             ARPP = c(1, 0.5, 0.1, 0, 1, 1, 1, 1, 1, 1),
             ARPC = c(1, 1, 1, 1, 0.5, 0.1, 0, 1, 1, 1),
             ARCC = c(1, 1, 1, 1, 1, 1, 1, 0.5, 0.1, 0),
             ARRT = 1)

sbatch_master(vars = vars,
              expand.vars = FALSE,
              master.file = "master.T2.sh",
              runsim.file = "runsim.T2.sh",
              rscript.file = "04.epi-model-hpc-t1.R",
              build.runsim = TRUE,
              append = TRUE,
              ckpt = ckpt,
              nsims = nsims,
              ncores = 28,
              narray = 1,
              walltime = "00:15:00",
              mem = "100G")

## Supp Table 2: Act Rate Reduction, No Network Lockdown or PPE

vars <- list(NLT = Inf,
             PPE = Inf,
             ARPP = c(1, 0.5, 0.1, 0, 1, 1, 1, 1, 1, 1),
             ARPC = c(1, 1, 1, 1, 0.5, 0.1, 0, 1, 1, 1),
             ARCC = c(1, 1, 1, 1, 1, 1, 1, 0.5, 0.1, 0),
             ARRT = Inf)

sbatch_master(vars = vars,
              expand.vars = FALSE,
              master.file = "master.T2.sh",
              runsim.file = "runsim.T2.sh",
              rscript.file = "04.epi-model-hpc-t1.R",
              build.runsim = TRUE,
              simno.start = 2100,
              append = TRUE,
              ckpt = ckpt,
              nsims = nsims,
              ncores = 28,
              narray = 1,
              walltime = "00:15:00",
              mem = "100G")


# Table 3 -----------------------------------------------------------------

## Lockdown and PPE at Day 15

vars <- list(NLT = 15,
             PPE = 15,
             ARPP = 1,
             ARPC = 1,
             ARCC = 1,
             ADM = 1,
             SII = 0.1,
             DII = 1 - c(1, 0.9, 0.75, 0.50, 0.25, 0))

sbatch_master(vars = vars,
              master.file = "master.T3.sh",
              runsim.file = "runsim.T3.sh",
              rscript.file = "04.epi-model-hpc-t3.R",
              build.runsim = TRUE,
              simno.start = 3000,
              append = FALSE,
              ckpt = ckpt,
              nsims = nsims,
              ncores = 28,
              narray = 1,
              walltime = "00:15:00",
              mem = "100G")

# No Lockdown or PPE

vars <- list(NLT = Inf,
             PPE = Inf,
             ARPP = 1,
             ARPC = 1,
             ARCC = 1,
             ADM = 1,
             SII = 0.1,
             DII = 1 - c(1, 0.9, 0.75, 0.50, 0.25, 0))

sbatch_master(vars = vars,
              master.file = "master.T3.sh",
              runsim.file = "runsim.T3.sh",
              rscript.file = "04.epi-model-hpc-t3.R",
              append = TRUE,
              ckpt = ckpt,
              nsims = nsims,
              ncores = 28,
              narray = 1,
              walltime = "00:15:00",
              mem = "100G")



# Table 4 -----------------------------------------------------------------

vars <- list(NLT = 15,
             PPE = 15,
             T4SCEN = 1:13)

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
              walltime = "00:15:00",
              mem = "100G")

vars <- list(NLT = 1,
             PPE = 1,
             T4SCEN = 1:13)

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
              walltime = "00:15:00",
              mem = "100G")


# Table 5 -----------------------------------------------------------------

## Asymptomatic Diagnosis Timing with No Lockdown and No PPE
vars <- list(NLT = Inf,
             PPE = Inf,
             ARPP = 1,
             ARPC = 1,
             ARCC = 1,
             ADM = 1,
             DII = 0,
             SII = 0,
             DXTIME = c(1, 5, 10, 15, 20, 25, 50))

sbatch_master(vars = vars,
              master.file = "master.T5.sh",
              runsim.file = "runsim.T5.sh",
              rscript.file = "04.epi-model-hpc-t5.R",
              build.runsim = TRUE,
              simno.start = 5000,
              append = FALSE,
              ckpt = ckpt,
              nsims = nsims,
              ncores = 28,
              narray = 1,
              walltime = "00:15:00",
              mem = "100G")

## Asymptomatic Diagnosis Timing, with No Lockdown and Yes PPE
vars <- list(NLT = Inf,
             PPE = 1,
             ARPP = 1,
             ARPC = 1,
             ARCC = 1,
             ADM = 1,
             DII = 0,
             SII = 0,
             DXTIME = c(1, 5, 10, 15, 20, 25, 50))

sbatch_master(vars = vars,
              master.file = "master.T5.sh",
              runsim.file = "runsim.T5.sh",
              rscript.file = "04.epi-model-hpc-t5.R",
              append = TRUE,
              ckpt = ckpt,
              nsims = nsims,
              ncores = 28,
              narray = 1,
              walltime = "00:15:00",
              mem = "100G")


# Fig 3a: Contour Screening Timing x Dx contact intensity redux

vars <- list(NLT = Inf,
             PPE = Inf,
             ARPP = 1,
             ARPC = 1,
             ARCC = 1,
             ADM = 1,
             DII = seq(0, 1, 0.1),
             SII = 0,
             DXTIME = 1:31)

sbatch_master(vars = vars,
              master.file = "master.T5-F3.sh",
              runsim.file = "runsim.T5.sh",
              rscript.file = "04.epi-model-hpc-t5.R",
              simno.start = 5100,
              append = FALSE,
              ckpt = ckpt,
              nsims = nsims,
              ncores = 28,
              narray = 1,
              walltime = "00:15:00",
              mem = "100G")

# Fig 3b: Contour Screening Timing x PCR sensitivity

vars <- list(NLT = Inf,
             PPE = Inf,
             ARPP = 1,
             ARPC = 1,
             ARCC = 1,
             ADM = 1,
             DII = 0,
             SII = 0,
             DXTIME = 1:31,
             PCR = seq(0, 1, 0.05))

sbatch_master(vars = vars,
              master.file = "master.T5-F3b.sh",
              runsim.file = "runsim.T5.sh",
              rscript.file = "04.epi-model-hpc-t5.R",
              simno.start = 5500,
              append = FALSE,
              ckpt = ckpt,
              nsims = nsims,
              ncores = 28,
              narray = 1,
              walltime = "00:15:00",
              mem = "100G")

# Fig 3c: DII x PCR sensitivity

vars <- list(NLT = Inf,
             PPE = Inf,
             ARPP = 1,
             ARPC = 1,
             ARCC = 1,
             ADM = 1,
             DII = seq(0, 0.2, 0.01),
             SII = 0,
             DXTIME = 1,
             PCR = seq(0.75, 1, 0.01))

sbatch_master(vars = vars,
              master.file = "master.T5-F3c.sh",
              runsim.file = "runsim.T5.sh",
              rscript.file = "04.epi-model-hpc-t5.R",
              simno.start = 6500,
              append = FALSE,
              ckpt = ckpt,
              nsims = 224,
              ncores = 28,
              narray = 1,
              walltime = "00:15:00",
              mem = "100G")
