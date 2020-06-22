#!/bin/bash

sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s3000 --export=ALL,SIMNO=3000,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=0 runsim.T3.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s3001 --export=ALL,SIMNO=3001,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=0.1 runsim.T3.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s3002 --export=ALL,SIMNO=3002,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=0.25 runsim.T3.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s3003 --export=ALL,SIMNO=3003,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=0.5 runsim.T3.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s3004 --export=ALL,SIMNO=3004,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=0.75 runsim.T3.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s3005 --export=ALL,SIMNO=3005,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=1 runsim.T3.sh

sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s3006 --export=ALL,SIMNO=3006,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=0 runsim.T3.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s3007 --export=ALL,SIMNO=3007,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=0.1 runsim.T3.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s3008 --export=ALL,SIMNO=3008,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=0.25 runsim.T3.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s3009 --export=ALL,SIMNO=3009,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=0.5 runsim.T3.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s3010 --export=ALL,SIMNO=3010,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=0.75 runsim.T3.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s3011 --export=ALL,SIMNO=3011,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=1,ADM=1,SII=0.1,DII=1 runsim.T3.sh
