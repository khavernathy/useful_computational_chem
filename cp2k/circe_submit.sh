#!/bin/bash
#SBATCH -J cp2k_kikdoz_H_q -t 168:00:00 
#SBATCH--mail-type=END --mail-user=dfranz@mail.usf.edu 
#SBATCH -o runlog.log
########SBATCH --partition=mri2016 --qos=mri16
#SBATCH --partition=circe
#SBATCH --ntasks=16
#SBATCH -N 1
#SBATCH --mem=30000

# 1)
# to get this stuff, gotta grab from gitub
# git clone https://github.com/cp2k/cp2k.git
datadir="/work/d/dfranz/cp2k/cp2k/data/"

# 2)
# u can download this precompiled file from 
# https://sourceforge.net/projects/cp2k/files/precompiled/
exe="/work/d/dfranz/cp2k_precompiled/cp2k-5.1-Linux-x86_64.ssmp"

module purge
module load compilers/intel/11.1.064
module load mpi/mvapich2/1.8a2


export CP2K_DATA_DIR=$datadir
export OMP_NUM_THREADS=$SLURM_NTASKS
$exe *.inp
