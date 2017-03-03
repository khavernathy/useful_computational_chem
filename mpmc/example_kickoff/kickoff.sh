#!/bin/bash

current=$(pwd);

for s in h2; do
#for s in co2 ch4; do
#for s in c2h2; do
#for s in c2h2 c2h4 c2h6; do
cd $s
for t in 77 87;do
#for t in 298; do 
#mkdir $t"K";
cd $t"K";
for m in BSSP BSS BUCH DL; do 
#for m in polar nonpolar trappe; do
#for m in polar nonpolar; do
 #   mkdir $m;
	cd $m 

    onoroff="off";
    if [[ "$m" == "polar" ]] || [[ "$m" == "BSSP"  ]]; then
        onoroff="on";
    fi

for pres in 0.05 0.1 0.2 0.4 0.6 0.8 1.0; do # 5.0 10.0 20.0 30.0 40.0 50.0 60.0; do

#	mkdir $pres
	cd ./$pres; pwd
	
	# make the submission script
    awk -v pres="$pres" -v model="$m" -v temp="$t" -v polar="$onoroff" '{
        sub(/YPRESY/, pres);
        sub(/ZTEMPZ/, temp);
        sub(/XMODELX/, model);
        sub(/CPOLARC/, polar);
       
        print;
        }' $current/submit.sh > submit.sh
    # make the input
	awk -v pres="$pres" -v polar="$onoroff" -v sor="$s" '{
		sub(/XPRESX/, pres);
        sub(/CPOLARC/, polar);
		sub(/XSORX/, sor);
        print;
	}' $current/mpmc.inp > mpmc.inp	

    # make the pqr input
	cp $current/$s"_"$m".pqr" input.pqr

	# SAVE AND RESTART
	mkdir saved_data;
	#cat *restar*.pqr >> saved_data/restart.pqr
	#rm input.pqr
	#cat *.restart-00000.pqr >>  input.pqr
	#cat *traj*.pqr >> saved_data/traj.pqr
	#cat runlog* >> saved_data/runlog.log

	sbatch submit.sh
	cd ../
done

cd ../

done
cd ..
done
cd ..
done
