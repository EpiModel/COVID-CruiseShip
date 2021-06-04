#!/bin/bash

sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s4000 --export=ALL,SIMNO=4000,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,T4SCEN=1 runsim.T4.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s4001 --export=ALL,SIMNO=4001,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,T4SCEN=2 runsim.T4.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s4002 --export=ALL,SIMNO=4002,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,T4SCEN=3 runsim.T4.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s4003 --export=ALL,SIMNO=4003,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,T4SCEN=4 runsim.T4.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s4004 --export=ALL,SIMNO=4004,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,T4SCEN=5 runsim.T4.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s4005 --export=ALL,SIMNO=4005,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,T4SCEN=6 runsim.T4.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s4006 --export=ALL,SIMNO=4006,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,T4SCEN=7 runsim.T4.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s4007 --export=ALL,SIMNO=4007,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,T4SCEN=8 runsim.T4.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s4008 --export=ALL,SIMNO=4008,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,T4SCEN=9 runsim.T4.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s4009 --export=ALL,SIMNO=4009,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,T4SCEN=10 runsim.T4.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s4010 --export=ALL,SIMNO=4010,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,T4SCEN=11 runsim.T4.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s4011 --export=ALL,SIMNO=4011,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,T4SCEN=12 runsim.T4.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s4012 --export=ALL,SIMNO=4012,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,T4SCEN=13 runsim.T4.sh

sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s4013 --export=ALL,SIMNO=4013,NJOBS=1,NSIMS=1000,NLT=1,PPE=1,T4SCEN=1 runsim.T4.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s4014 --export=ALL,SIMNO=4014,NJOBS=1,NSIMS=1000,NLT=1,PPE=1,T4SCEN=2 runsim.T4.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s4015 --export=ALL,SIMNO=4015,NJOBS=1,NSIMS=1000,NLT=1,PPE=1,T4SCEN=3 runsim.T4.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s4016 --export=ALL,SIMNO=4016,NJOBS=1,NSIMS=1000,NLT=1,PPE=1,T4SCEN=4 runsim.T4.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s4017 --export=ALL,SIMNO=4017,NJOBS=1,NSIMS=1000,NLT=1,PPE=1,T4SCEN=5 runsim.T4.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s4018 --export=ALL,SIMNO=4018,NJOBS=1,NSIMS=1000,NLT=1,PPE=1,T4SCEN=6 runsim.T4.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s4019 --export=ALL,SIMNO=4019,NJOBS=1,NSIMS=1000,NLT=1,PPE=1,T4SCEN=7 runsim.T4.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s4020 --export=ALL,SIMNO=4020,NJOBS=1,NSIMS=1000,NLT=1,PPE=1,T4SCEN=8 runsim.T4.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s4021 --export=ALL,SIMNO=4021,NJOBS=1,NSIMS=1000,NLT=1,PPE=1,T4SCEN=9 runsim.T4.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s4022 --export=ALL,SIMNO=4022,NJOBS=1,NSIMS=1000,NLT=1,PPE=1,T4SCEN=10 runsim.T4.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s4023 --export=ALL,SIMNO=4023,NJOBS=1,NSIMS=1000,NLT=1,PPE=1,T4SCEN=11 runsim.T4.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s4024 --export=ALL,SIMNO=4024,NJOBS=1,NSIMS=1000,NLT=1,PPE=1,T4SCEN=12 runsim.T4.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s4025 --export=ALL,SIMNO=4025,NJOBS=1,NSIMS=1000,NLT=1,PPE=1,T4SCEN=13 runsim.T4.sh
