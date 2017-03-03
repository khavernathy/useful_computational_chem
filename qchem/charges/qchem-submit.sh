#!/bin/bash -l        
############## TO SET AN OPTION , CHANGE FROM ##SBATCH to #SBATCH ############
#SBATCH -J "JOBNAME"              ### NAME OF THE JOB
#SBATCH -t 0:59:59                ### TIME ALLOCATED FOR JOB (HH:MM:SS)
##SBATCH --mem=3000              ### MEMORY ALLOC (DEFAULT IS UNLIMIMTED - SO DONT SET)
##SBATCH -N 1 --ntasks-per-node 9 ### SIMILAR TO nodes=;ppn=
#SBATCH -n 4                      ### SIMILAR TO pcpus= 
##SBATCH -C "cpu_xeon"             ### CONSTRAINS JOBS TO RUN ON INTEL NODES (REQ BY CHARMM)
##SBATCH -N 1 --exclusive         ### RESERVE ENTIRE NODES AND ALL PROCESSORS ON THE NODES


###### GENERATE THE HOST FILE
cat /proc/cpuinfo  | tail -25 | grep -i "model name"
hostname
srun hostname -s > machines.$$.mpich
export PBS_NODEFILE=`pwd`/machines.$$.mpich
cat $PBS_NODEFILE | tee hosts
module purge
############################# PICK WHICH QCHEM TO RUN #################################
############################# OPEN MP THREADED PARALLEL QCHEM 4.3 HLW #################
source /shares/chem_hlw/qchem/4.3.0-qmmm-nt/setqc
############################# MPI/THREADED PARALLEL QCHEM 4.22 ########################
#source /shares/cas.chem.hlw/hlw/chem/phillip/software/qchem/qc422/setqc
############################# MPI/THREADED GPU PARALLEL QCHEM 4.3 #####################
############################# GPU SUPPORT IS NOT WORKING BUT COMPILED #################
#source /shares/cas.chem.hlw/hlw/chem/phillip/software/qchem/gpu-qc422/setqc
############################ MULTITHREADED QCHEM 4.22 #################################
#source /shares/cas.chem.hlw/hlw/chem/phillip/software/qchem/QC422-OPENMP/setqc
############################ MPI PARALLEL QCHEM 4.22 ##################################
#source /shares/cas.chem.hlw/hlw/chem/phillip/software/qchem/QC422-MPI/setqc
#######################################################################################

############################# CHARMM ENVIRONMENTALS ###################################
#source /shares/cas.chem.hlw/hlw/chem/phillip/software/charmm/extlibs/compile.2.set
#######################################################################################

############################# CHARMM EXECUTABLES ######################################
#export MQC40=/shares/cas.chem.hlw/hlw/chem/phillip/software/charmm/c40b1/exec/mscale_qchem/charmm
#export MSC40=/shares/cas.chem.hlw/hlw/chem/phillip/software/charmm/c40b1/exec/mscale_sccdftb/charmm
#export MSQ40=/shares/cas.chem.hlw/hlw/chem/phillip/software/charmm/c40b1/exec/mscale_squantum/charmm
#export SCIO=/shares/cas.chem.hlw/hlw/chem/phillip/software/charmm/c40b1/exec/terse_sccdftb/charmm
#######################################################################################

############################# QCHEM ENVIRONMENTALS ###################################
export QCSCRATCH=/tmp/
unset QCLOCALSCR
unset QCRSH
export P4_RSHCOMMAND=ssh
#######################################################################################

############################ QCAUX RESET ##############################################
if [ -d /opt/qchem/aux/ ] 
then
   export QCAUX=/opt/qchem/aux/
else
   mkdir -p /tmp/$USER/
   cp /shares/chem_hlw/qchem/aux.tar.xz /tmp/$USER/
   tar Jxf /tmp/$USER/aux.tar.xz  -C /tmp/$USER/
   export QCAUX=/tmp/$USER/aux/
fi 
#######################################################################################


########################### RESERACH COMPUTING VARIABLES ##############################
export I_MPI_FABRICS=tcp
export I_MPI_TCP_NETMASK=ib0
#######################################################################################

which mpiexec
which qchem
#printenv
qchem -nt $SLURM_NTASKS qchem.in qchem.out
#qchem hexa.ompmpi.inp hexa.ompmpi.memtest.out
#mpiexec -np 1 $SCIO -i input.dat > output.dat
#qchem -np $SLURM_TASKS_PER_NODE input.dat output.dat 
#########
rm machines.$$.mpich
