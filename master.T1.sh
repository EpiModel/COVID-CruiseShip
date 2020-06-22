#!/bin/bash

sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s1000 --export=ALL,SIMNO=1000,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1 runsim.T1.sh

sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s1001 --export=ALL,SIMNO=1001,NJOBS=1,NSIMS=1000,NLT=1,PPE=1,ARPP=1,ARPC=1,ARCC=1 runsim.T1.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s1002 --export=ALL,SIMNO=1002,NJOBS=1,NSIMS=1000,NLT=5,PPE=5,ARPP=1,ARPC=1,ARCC=1 runsim.T1.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s1003 --export=ALL,SIMNO=1003,NJOBS=1,NSIMS=1000,NLT=10,PPE=10,ARPP=1,ARPC=1,ARCC=1 runsim.T1.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s1004 --export=ALL,SIMNO=1004,NJOBS=1,NSIMS=1000,NLT=20,PPE=20,ARPP=1,ARPC=1,ARCC=1 runsim.T1.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s1005 --export=ALL,SIMNO=1005,NJOBS=1,NSIMS=1000,NLT=25,PPE=25,ARPP=1,ARPC=1,ARCC=1 runsim.T1.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s1006 --export=ALL,SIMNO=1006,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=1 runsim.T1.sh

sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s1007 --export=ALL,SIMNO=1007,NJOBS=1,NSIMS=1000,NLT=1,PPE=Inf,ARPP=1,ARPC=1,ARCC=1 runsim.T1.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s1008 --export=ALL,SIMNO=1008,NJOBS=1,NSIMS=1000,NLT=5,PPE=Inf,ARPP=1,ARPC=1,ARCC=1 runsim.T1.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s1009 --export=ALL,SIMNO=1009,NJOBS=1,NSIMS=1000,NLT=10,PPE=Inf,ARPP=1,ARPC=1,ARCC=1 runsim.T1.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s1010 --export=ALL,SIMNO=1010,NJOBS=1,NSIMS=1000,NLT=15,PPE=Inf,ARPP=1,ARPC=1,ARCC=1 runsim.T1.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s1011 --export=ALL,SIMNO=1011,NJOBS=1,NSIMS=1000,NLT=20,PPE=Inf,ARPP=1,ARPC=1,ARCC=1 runsim.T1.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s1012 --export=ALL,SIMNO=1012,NJOBS=1,NSIMS=1000,NLT=25,PPE=Inf,ARPP=1,ARPC=1,ARCC=1 runsim.T1.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s1013 --export=ALL,SIMNO=1013,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=1 runsim.T1.sh
