#!/bin/bash

#SBATCH -J mn_Polariz -t 48:00:00 --mail-type=END --mail-user=dfranz@mail.usf.edu -o runlog.log
#SBATCH --partition=mri2016 --qos=mri16
#SBATCH --ntasks=1
#SBATCH --mem=6000

module purge
module load compilers/gcc/4.4.2
module load mpi/openmpi-1.4.1/gcc-4.4.2

atom="Mn"
base=$(pwd);
mpmc='/work/d/dfranz/mpmc/build/mpmc' # THE EXECUTABLE DIRECTORY
echo "#isotropic   #"$atom"_pol" > isotropics.txt   # ISOTROPIC AS A FUNCTION OF ATOM POLARIZ. overwrites isotropics.txt

rm -r  polar_*

str=""
for ((i=1; i<1000; i++)); do
    str=$str" "$(echo "("$i" / 1000.0) + 2.0" | bc -l); # tests values 2.000, 2.001, ... 2.999; 
done

#for ((i=0; i<12; i++)); do
#    str=$str" "$(echo "("$i" / 2.0)" | bc -l); # tests values 0.0, 0.5, 1.0, 1.5, ... 6.0
#done

for polariz in  $str; do
    mkdir polar_$polariz;
    cd polar_$polariz;
    echo ""$atom" = "$polariz;

    cp $base/polar.inp .
    
    # make PQR by replacing XXX with actual trial number
        awk -v polariz="$polariz" '{
                gsub(/XXX/, polariz);
                print;
        }' $base/input.pqr > input.pqr

    # run it.
    mpirun -np 1 $mpmc *inp > runlog;

    # get isotropic
    iso=$(cat runlog | grep "isotropic =" | tail -1 | awk {'print $3'});

    # write isotropic value to master list  (iso as function of the atom's polar)
    echo $iso"    "$polariz >> $base/isotropics.txt
    
    cd .. # out of polar
done
