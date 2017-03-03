#!/bin/bash

# THIS IS AN EXAMPLE SCRIPT WHERE WE SIMULATE 
# MULTIPLE SORBATES ON CIRCE IN ONE BIG COMMAND:
# bash kickoff.sh

current=$(pwd); # saving the current directory so we can remember it later
# this directory should contain the 3 essential files for 1 MPMC job:
    # s_m.pqr files, where s=sorbate and m=model, e.g. c2h2_polar.pqr
    # submit.sh, a template for CIRCE job submission
    # mpmc.inp, a template for MPMC run

for s in c2h2 c2h4 c2h6; do # sorbate models
mkdir $s
cd $s
for t in 298 273; do  # temps in K 
mkdir $t"K";
cd $t"K";
for m in polar nonpolar; do # type of model
mkdir $m;
	cd $m 

    onoroff="off"; # a variable to automatically set polarization on/off
    if [[ "$m" == "polar" ]]; then
        onoroff="on";
    fi

for pres in 0.05 0.1 0.2 0.4 0.6 0.8 1.0; do # pres in atm.

	mkdir $pres
	cd ./$pres; pwd
	
	# make the submission script
    awk -v pres="$pres" -v model="$m" -v temp="$t" -v polar="$onoroff" '{
        gsub(/YPRESY/, pres);
        gsub(/ZTEMPZ/, temp);
        gsub(/XMODELX/, model);
        gsub(/CPOLARC/, polar);
        print;
        }' $current/submit.sh > submit.sh
    
    # make the input
	awk -v pres="$pres" -v polar="$onoroff" -v sor="$s" '{
		gsub(/XPRESX/, pres);
        gsub(/CPOLARC/, polar);
		gsub(/XSORX/, sor);
        print;
	}' $current/mpmc.inp > mpmc.inp	

    # make the pqr input
	cp $current/$s"_"$m".pqr" input.pqr

	# SAVE AND RESTART
    # uncomment the stuff to save some important data and then
    # re-run from last restart.pqr checkpoint.
	mkdir saved_data;
    # =============================================
	#cat *restar*.pqr >> saved_data/restart.pqr
	#rm input.pqr
	#cat *.restart-00000.pqr >>  input.pqr
	#cat *traj*.pqr >> saved_data/traj.pqr
	#cat runlog* >> saved_data/runlog.log
    # =============================================

	sbatch submit.sh
	cd ../
done

cd ../

done
cd ..
done
cd ..
done
