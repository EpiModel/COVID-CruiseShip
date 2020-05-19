
#!/bin/bash

clus=mox

# Send
scp est/*.rds $clus:/gscratch/csde/sjenness/cruise/est
scp 01.epi-params.R 04.epi-model-hpc.R runsim.sh master.*.sh $clus:/gscratch/csde/sjenness/cruise


# Receive
scp $clus:/gscratch/csde/sjenness/cruise/data/*.rda analysis/data/
