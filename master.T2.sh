#!/bin/bash

sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s2000 --export=ALL,SIMNO=2000,NJOBS=1,NSIMS=250,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1 runsim.sh

sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s2001 --export=ALL,SIMNO=2001,NJOBS=1,NSIMS=250,NLT=1,PPE=15,ARPP=1,ARPC=1,ARCC=1 runsim.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s2002 --export=ALL,SIMNO=2002,NJOBS=1,NSIMS=250,NLT=5,PPE=15,ARPP=1,ARPC=1,ARCC=1 runsim.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s2003 --export=ALL,SIMNO=2003,NJOBS=1,NSIMS=250,NLT=10,PPE=15,ARPP=1,ARPC=1,ARCC=1 runsim.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s2004 --export=ALL,SIMNO=2004,NJOBS=1,NSIMS=250,NLT=20,PPE=15,ARPP=1,ARPC=1,ARCC=1 runsim.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s2005 --export=ALL,SIMNO=2005,NJOBS=1,NSIMS=250,NLT=25,PPE=15,ARPP=1,ARPC=1,ARCC=1 runsim.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s2006 --export=ALL,SIMNO=2006,NJOBS=1,NSIMS=250,NLT=Inf,PPE=15,ARPP=1,ARPC=1,ARCC=1 runsim.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s2007 --export=ALL,SIMNO=2007,NJOBS=1,NSIMS=250,NLT=1,PPE=Inf,ARPP=1,ARPC=1,ARCC=1 runsim.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s2008 --export=ALL,SIMNO=2008,NJOBS=1,NSIMS=250,NLT=5,PPE=Inf,ARPP=1,ARPC=1,ARCC=1 runsim.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s2009 --export=ALL,SIMNO=2009,NJOBS=1,NSIMS=250,NLT=10,PPE=Inf,ARPP=1,ARPC=1,ARCC=1 runsim.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s2010 --export=ALL,SIMNO=2010,NJOBS=1,NSIMS=250,NLT=20,PPE=Inf,ARPP=1,ARPC=1,ARCC=1 runsim.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s2011 --export=ALL,SIMNO=2011,NJOBS=1,NSIMS=250,NLT=25,PPE=Inf,ARPP=1,ARPC=1,ARCC=1 runsim.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s2012 --export=ALL,SIMNO=2012,NJOBS=1,NSIMS=250,NLT=Inf,PPE=Inf,ARPP=1,ARPC=1,ARCC=1 runsim.sh

sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s2013 --export=ALL,SIMNO=2013,NJOBS=1,NSIMS=250,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1 runsim.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s2014 --export=ALL,SIMNO=2014,NJOBS=1,NSIMS=250,NLT=15,PPE=15,ARPP=0.5,ARPC=1,ARCC=1 runsim.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s2015 --export=ALL,SIMNO=2015,NJOBS=1,NSIMS=250,NLT=15,PPE=15,ARPP=0.1,ARPC=1,ARCC=1 runsim.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s2016 --export=ALL,SIMNO=2016,NJOBS=1,NSIMS=250,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1 runsim.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s2017 --export=ALL,SIMNO=2017,NJOBS=1,NSIMS=250,NLT=15,PPE=15,ARPP=1,ARPC=0.5,ARCC=1 runsim.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s2018 --export=ALL,SIMNO=2018,NJOBS=1,NSIMS=250,NLT=15,PPE=15,ARPP=1,ARPC=0.1,ARCC=1 runsim.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s2019 --export=ALL,SIMNO=2019,NJOBS=1,NSIMS=250,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=1 runsim.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s2020 --export=ALL,SIMNO=2020,NJOBS=1,NSIMS=250,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=0.5 runsim.sh
sbatch -p ckpt -A csde-ckpt --array=1  --nodes=1 --ntasks-per-node=28 --time=00:10:00 --mem=100G --job-name=s2021 --export=ALL,SIMNO=2021,NJOBS=1,NSIMS=250,NLT=15,PPE=15,ARPP=1,ARPC=1,ARCC=0.1 runsim.sh
