#!/bin/bash

sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2000 --export=ALL,SIMNO=2000,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1,ARRT=15 runsim.T2.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2001 --export=ALL,SIMNO=2001,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=0.5,ARPC=1,ARCC=1,ARRT=15 runsim.T2.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2002 --export=ALL,SIMNO=2002,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=0.1,ARPC=1,ARCC=1,ARRT=15 runsim.T2.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2003 --export=ALL,SIMNO=2003,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=0,ARPC=1,ARCC=1,ARRT=15 runsim.T2.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2004 --export=ALL,SIMNO=2004,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=0.5,ARCC=1,ARRT=15 runsim.T2.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2005 --export=ALL,SIMNO=2005,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=0.1,ARCC=1,ARRT=15 runsim.T2.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2006 --export=ALL,SIMNO=2006,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=0,ARCC=1,ARRT=15 runsim.T2.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2007 --export=ALL,SIMNO=2007,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=0.5,ARRT=15 runsim.T2.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2008 --export=ALL,SIMNO=2008,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=0.1,ARRT=15 runsim.T2.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2009 --export=ALL,SIMNO=2009,NJOBS=1,NSIMS=1000,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=0,ARRT=15 runsim.T2.sh

sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2010 --export=ALL,SIMNO=2010,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=1,ARPP=1,ARPC=1,ARCC=1,ARRT=1 runsim.T2.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2011 --export=ALL,SIMNO=2011,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=1,ARPP=0.5,ARPC=1,ARCC=1,ARRT=1 runsim.T2.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2012 --export=ALL,SIMNO=2012,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=1,ARPP=0.1,ARPC=1,ARCC=1,ARRT=1 runsim.T2.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2013 --export=ALL,SIMNO=2013,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=1,ARPP=0,ARPC=1,ARCC=1,ARRT=1 runsim.T2.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2014 --export=ALL,SIMNO=2014,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=1,ARPP=1,ARPC=0.5,ARCC=1,ARRT=1 runsim.T2.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2015 --export=ALL,SIMNO=2015,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=1,ARPP=1,ARPC=0.1,ARCC=1,ARRT=1 runsim.T2.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2016 --export=ALL,SIMNO=2016,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=1,ARPP=1,ARPC=0,ARCC=1,ARRT=1 runsim.T2.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2017 --export=ALL,SIMNO=2017,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=1,ARPP=1,ARPC=1,ARCC=0.5,ARRT=1 runsim.T2.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2018 --export=ALL,SIMNO=2018,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=1,ARPP=1,ARPC=1,ARCC=0.1,ARRT=1 runsim.T2.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2019 --export=ALL,SIMNO=2019,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=1,ARPP=1,ARPC=1,ARCC=0,ARRT=1 runsim.T2.sh

sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2100 --export=ALL,SIMNO=2100,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=1,ARRT=Inf runsim.T2.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2101 --export=ALL,SIMNO=2101,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=0.5,ARPC=1,ARCC=1,ARRT=Inf runsim.T2.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2102 --export=ALL,SIMNO=2102,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=0.1,ARPC=1,ARCC=1,ARRT=Inf runsim.T2.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2103 --export=ALL,SIMNO=2103,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=0,ARPC=1,ARCC=1,ARRT=Inf runsim.T2.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2104 --export=ALL,SIMNO=2104,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=0.5,ARCC=1,ARRT=Inf runsim.T2.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2105 --export=ALL,SIMNO=2105,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=0.1,ARCC=1,ARRT=Inf runsim.T2.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2106 --export=ALL,SIMNO=2106,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=0,ARCC=1,ARRT=Inf runsim.T2.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2107 --export=ALL,SIMNO=2107,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=0.5,ARRT=Inf runsim.T2.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2108 --export=ALL,SIMNO=2108,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=0.1,ARRT=Inf runsim.T2.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:15:00 --mem=100G --job-name=s2109 --export=ALL,SIMNO=2109,NJOBS=1,NSIMS=1000,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=0,ARRT=Inf runsim.T2.sh
