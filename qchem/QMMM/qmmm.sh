#!/bin/bash
#SBATCH --comment=qmmm
#SBATCH -p development   ### development, or circe, etc.  ...partition of circe you want to submit to!
#SBATCH -J FINALqmmm ### helps track submitted jobs, name whatever you like
#SBATCH -t 00:59:00  ####### amount of time for the job to run, always overestimate
#SBATCH -n 12  ## number of CPUs/processors
###SBATCH -C cpu_xeon ### constraint to get the good computers!!
#SBATCH --mem=1024 ### memory allocation, may have to be raised depending on system size
#SBATCH --output=runlog.log
#SBATCH --qos=development

export QCHARMM=/shares/cas.chem.hlw/hlw/chem/phillip/software/charmm/c39a2/exec/mscale_qchem/charmm
export SCCHARMM=/shares/cas.chem.hlw/hlw/chem/phillip/software/charmm/c39a2/exec/mscale_scc/charmm
cat /proc/cpuinfo  | tail -25 | grep -i "model name"
hostname
srun hostname -s > machines.$$.mpich
export PBS_NODEFILE=`pwd`/machines.$$.mpich
cat $PBS_NODEFILE | tee hosts
module purge
source /shares/cas.chem.hlw/hlw/chem/phillip/software/charmm/extlibs/compile.2.set
########## MPI PARALLEL
### below is qchem source code
source /shares/cas.chem.hlw/hlw/chem/phillip/software/qchem/qc422/setqc
########## THREADS PARALLEL
#source /shares/cas.chem.hlw/hlw/chem/phillip/software/qchem/QC422-OPENMP/setqc
##########
export QCSCRATCH=/tmp/
unset QCLOCALSCR
unset QCRSH
export P4_RSHCOMMAND=ssh
#### QCAUX RESET ###########
if [ -d /opt/qchem/aux/ ]
then
   export QCAUX=/opt/qchem/aux/
else
   mkdir -p /tmp/$USER/
   cp /shares/chem_hlw/qchem/aux.tar.xz /tmp/$USER/
   tar Jxf /tmp/$USER/aux.tar.xz  -C /tmp/$USER/
   export QCAUX=/tmp/$USER/aux/
fi
## RESERACH COMPUTING VARIABLES ##
export I_MPI_FABRICS=tcp
export I_MPI_TCP_NETMASK=ib0
#########################
which mpiexec
which qchem
#########################
###### Below is the singular command to run qchem. The general format is:
###### qchem input_file output_file
#qchem my-qchem-input-file.inp my-qchem-output-file.out

###### Below is the command to run qm/mm (CHARMM+QChem). Doug this is for you! 
###### You will need to comment this in when you want to run QM/MM and comment the 
###### above qchem command out to run qm/mm
###### The general format is:
###### mpiexec -np 1 $QCHARMM -i input_file -o output_file
#mpiexec -np $SLURM_NTASKS $QCHARMM -i charmm.inp -o charmm.out
#mpiexec -np $SLURM_NTASKS $QCHARMM -i input.dat -o charmm.out

export MQC40=/shares/cas.chem.hlw/hlw/chem/phillip/software/charmm/c40b1/exec/mscale_qchem/charmm

#######################################################
########## finally run the business. ##################
#######################################################
rm done_check.txt;
echo "false" >> done_check.txt;

max_iter=10;
echo "Maximum QM/MM iterations prescribed in submission file: "$max_iter;
for i in `seq 1 $max_iter`; do
	done_check=$(cat done_check.txt);
	if [ "$done_check" = "false" ]; then
		echo "\n\nQM/MM iteration: "$i;
		$MQC40 -i charmm.inp -o charmm.out  # the real meat-and-taters is here. QM/MM calc.
		rm ex.txt;
		sed -n '/Kollman ESP Net Atomic Charges/,/Sum of atomic charges/{/Ground/{p;n};/Sum of/q;p}' q1.out > ex.txt
		bash iteration_routine.sh ex.txt # writes H.dat and H.avg.dat etc. then processes the new mof.str
		echo "Rewrote mof.str with new charges for MM region.\n\n";
	fi
done

echo "\n\n==========================================";
echo "...done with QM/MM iterations.";
echo "FINAL CHARGES: ";
echo "Cu: "
cat Cu.avg.dat;
echo "O: "
cat O.avg.dat;
echo "C1: "
cat C1.avg.dat;
echo "C2: "
cat C2.avg.dat;
echo "C3: "
cat C3.avg.dat;
echo "H: "
cat H.avg.dat;

