
#!/bin/bash

# Send
scp est/*.rds mox:/gscratch/csde/sjenness/cruise/est
scp 01.epi-params.R 04.epi-model-hpc*.R runsim*.sh master.*.sh mox:/gscratch/csde/sjenness/cruise


# Receive
scp mox:/gscratch/csde/sjenness/cruise/data/*.rda analysis/dat/

scp mox:/gscratch/csde/sjenness/COVID-CruiseShip/fit1.10k.norej.rda analysis/
scp klone:/gscratch/csde/sjenness/COVID-CruiseShip/abc.smc.rds analysis/

scp klone:/gscratch/csde/sjenness/COVID-CruiseShip/sim.sensitivityABC.*.rds analysis/
