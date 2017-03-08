#!/bin/bash
#
#SBATCH --comment=nwchem-test
#SBATCH --ntasks=8
#SBATCH --job-name=Mn-form-opt
#SBATCH --export=ARMCI_DEFAULT_SHMMAX=8192
#SBATCH --output=runlog.log
#SBATCH --time=167:59:00
#SBATCH --mem=2048
#SBATCH -p circe

#### slurm blah blah

module purge
module load apps/nwchem/6.5

mpirun -np 8 nwchem *.inp
