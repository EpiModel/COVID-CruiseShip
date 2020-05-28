#!/bin/bash

sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s5000 --export=ALL,SIMNO=5000,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=0.1 runsim.T5.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s5001 --export=ALL,SIMNO=5001,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=1,ADM=1.5,SII=0.1,DII=0.1 runsim.T5.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s5002 --export=ALL,SIMNO=5002,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=1,ADM=2,SII=0.1,DII=0.1 runsim.T5.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s5003 --export=ALL,SIMNO=5003,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=1,ADM=5,SII=0.1,DII=0.1 runsim.T5.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s5004 --export=ALL,SIMNO=5004,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=1,ADM=10,SII=0.1,DII=0.1 runsim.T5.sh

sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s5005 --export=ALL,SIMNO=5005,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0,DII=0.1 runsim.T5.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s5006 --export=ALL,SIMNO=5006,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=0.1 runsim.T5.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s5007 --export=ALL,SIMNO=5007,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.25,DII=0.1 runsim.T5.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s5008 --export=ALL,SIMNO=5008,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.5,DII=0.1 runsim.T5.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s5009 --export=ALL,SIMNO=5009,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.75,DII=0.1 runsim.T5.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s5010 --export=ALL,SIMNO=5010,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=1,DII=0.1 runsim.T5.sh

sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s5011 --export=ALL,SIMNO=5011,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=0 runsim.T5.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s5012 --export=ALL,SIMNO=5012,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=0.1 runsim.T5.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s5013 --export=ALL,SIMNO=5013,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=0.25 runsim.T5.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s5014 --export=ALL,SIMNO=5014,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=0.5 runsim.T5.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s5015 --export=ALL,SIMNO=5015,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=0.75 runsim.T5.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s5016 --export=ALL,SIMNO=5016,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=1 runsim.T5.sh
