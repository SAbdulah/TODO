#!/bin/bash
#SBATCH --job-name=ExaGeoStat200-%j
#SBATCH --output=exact_ibex_%A.out
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
##SBATCH --partition=group-stsda
#SBATCH --time=01:00:00


#free -g
srun Rscript your_script.R
