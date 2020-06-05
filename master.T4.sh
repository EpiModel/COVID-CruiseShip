#!/bin/bash

sbatch -p csde -A csde --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s4000 --export=ALL,SIMNO=4000,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=0.1 runsim.T4.sh
sbatch -p csde -A csde --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s4001 --export=ALL,SIMNO=4001,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1,ADM=1.5,SII=0.1,DII=0.1 runsim.T4.sh
sbatch -p csde -A csde --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s4002 --export=ALL,SIMNO=4002,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1,ADM=2,SII=0.1,DII=0.1 runsim.T4.sh
sbatch -p csde -A csde --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s4003 --export=ALL,SIMNO=4003,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1,ADM=5,SII=0.1,DII=0.1 runsim.T4.sh
sbatch -p csde -A csde --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s4004 --export=ALL,SIMNO=4004,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1,ADM=10,SII=0.1,DII=0.1 runsim.T4.sh

sbatch -p csde -A csde --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s4005 --export=ALL,SIMNO=4005,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0,DII=0.1 runsim.T4.sh
sbatch -p csde -A csde --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s4006 --export=ALL,SIMNO=4006,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=0.1 runsim.T4.sh
sbatch -p csde -A csde --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s4007 --export=ALL,SIMNO=4007,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.25,DII=0.1 runsim.T4.sh
sbatch -p csde -A csde --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s4008 --export=ALL,SIMNO=4008,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.5,DII=0.1 runsim.T4.sh
sbatch -p csde -A csde --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s4009 --export=ALL,SIMNO=4009,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.75,DII=0.1 runsim.T4.sh
sbatch -p csde -A csde --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s4010 --export=ALL,SIMNO=4010,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=1,DII=0.1 runsim.T4.sh

sbatch -p csde -A csde --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s4011 --export=ALL,SIMNO=4011,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=0 runsim.T4.sh
sbatch -p csde -A csde --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s4012 --export=ALL,SIMNO=4012,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=0.1 runsim.T4.sh
sbatch -p csde -A csde --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s4013 --export=ALL,SIMNO=4013,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=0.25 runsim.T4.sh
sbatch -p csde -A csde --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s4014 --export=ALL,SIMNO=4014,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=0.5 runsim.T4.sh
sbatch -p csde -A csde --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s4015 --export=ALL,SIMNO=4015,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=0.75 runsim.T4.sh
sbatch -p csde -A csde --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s4016 --export=ALL,SIMNO=4016,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=1 runsim.T4.sh
