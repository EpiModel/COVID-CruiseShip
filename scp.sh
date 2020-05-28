
#!/bin/bash

# Send
scp est/*.rds mox:/gscratch/csde/sjenness/cruise/est
scp 01.epi-params.R 04.epi-model-hpc*.R runsim*.sh master.*.sh mox:/gscratch/csde/sjenness/cruise


# Receive
scp mox:/gscratch/csde/sjenness/cruise/data/*.rda analysis/data/

scp mox:/gscratch/csde/sjenness/cruise/data/sim.n1000.rda analysis/data/
