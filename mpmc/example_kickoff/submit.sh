#!/bin/bash

#SBATCH -J 2rht_XMODELX_YPRESY_CPOLARC_ZTEMPZ -t 48:00:00 --mail-type=END --mail-user=dfranz@mail.usf.edu -o runlog.log
#SBATCH --partition=mri2016 --qos=mri16
#SBATCH --ntasks=1
#SBATCH --mem=6000

module purge
module load compilers/gcc/4.4.2
module load mpi/openmpi-1.4.1/gcc-4.4.2

mpirun -np 1 /work/d/dfranz/mpmc/build/mpmc *.inp
