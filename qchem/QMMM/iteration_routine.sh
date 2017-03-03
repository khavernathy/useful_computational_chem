#!/bin/bash

#the only argument for this script is the filename, e.g. ex.txt, 
# which is written by qmmm.sh and contains the final QM/MM output charges
# e.g.
# Cu 1 2 3 1.38480
# O  0 3 2 -0.93813
# etc.

for atom in "Cu" "O" "C1" "C2" "C3" "H"; do
	cp $atom.dat $atom.dat.old;
	cp $atom.avg.dat $atom.avg.dat.old
done

rm Cu*.dat O*.dat C1*.dat C2*.dat C3*.dat H*.dat

function gl {
        # gl is for "grep line" -- pull specific lines from a file as desired.
        # supply filename as $1 then lines to print as $2, $3 etc.
        #e.g.
        # gl myfile.txt 1 4 30 31 42
        filename=$1;
        str="";
        for var in "$@"
        do
                if [[ $var != $1 ]]; then
                        if [[ $var == $2 ]]; then
                                str=$str"NR == "$var
                        else
                                str=$str" || NR == "$var
                        fi
                fi
        done
#       echo $str
        cat $filename | awk "$str"
}

# write new charges from calculation result
echo "Cu";
gl $1 5 6 7 8 9 10 | awk {'print $3'} | tee Cu.dat
echo "O";
gl $1 36 37 40 41 43 44 | awk {'print $3'} | tee O.dat
echo "C1"
gl $1 15 16 18 | awk {'print $3'} | tee C1.dat
echo "C2"
gl $1 23 24 25 | awk {'print $3'} | tee C2.dat
echo "C3"
gl $1 26 27 28 | awk {'print $3'} | tee C3.dat
echo "H"
gl $1 53 54 55 | awk {'print $3'} | tee H.dat


#============================================

# write averages
for atom in "Cu" "O" "C1" "C2" "C3" "H"; do
	cat $atom.dat | awk '{sum+=$1; c+=1} END {print sum/c}' > $atom.avg.dat
done


# check for convergence!!
converged=false;

# grab charge values
h_charge=$(cat H.avg.dat); h_charge_old=$(cat H.avg.dat.old);
o_charge=$(cat O.avg.dat); o_charge_old=$(cat O.avg.dat.old);
c1_charge=$(cat C1.avg.dat); c1_charge_old=$(cat C1.avg.dat.old);
c2_charge=$(cat C2.avg.dat); c2_charge_old=$(cat C2.avg.dat.old);
c3_charge=$(cat C3.avg.dat); c3_charge_old=$(cat C3.avg.dat.old);
cu_charge=$(cat Cu.avg.dat); cu_charge_old=$(cat Cu.avg.dat.old);

# calculate differences from previous.
h_diff=$(echo $h_charge"-"$h_charge_old | bc -l); echo "H diff: "$h_diff;
o_diff=$(echo $o_charge"-"$o_charge_old | bc -l); echo "O diff: "$o_diff;
c1_diff=$(echo $c1_charge"-"$c1_charge_old | bc -l); echo "C1 diff: "$c1_diff;
c2_diff=$(echo $c2_charge"-"$c2_charge_old | bc -l); echo "C2 diff: "$c2_diff;
c3_diff=$(echo $c3_charge"-"$c3_charge_old | bc -l); echo "C3 diff: "$c3_diff;
cu_diff=$(echo $cu_charge"-"$cu_charge_old | bc -l); echo "Cu diff: "$cu_diff;

if [ $(echo $h_diff" < 0.1" | bc -l) -eq 1 ]; then
	if [ $(echo $o_diff" < 0.1" | bc -l) -eq 1 ]; then
		if [ $(echo $c1_diff" < 0.1" | bc -l) -eq 1 ]; then
			if [ $(echo $c2_diff" < 0.1" | bc -l) -eq 1 ]; then
				if [ $(echo $c3_diff" < 0.1" | bc -l) -eq 1 ]; then
					if [ $(echo $cu_diff" < 0.1" | bc -l) -eq 1 ]; then
						converged=true;
					fi
				fi
			fi
		fi
	fi
fi

if [ "$converged" = false ] ; then

	rm charge_list.tmp

	for x in `seq 1 48`; do 
	echo $cu_charge >> charge_list.tmp
	done
	for x in `seq 49 144`; do
	echo $c1_charge >> charge_list.tmp
	done
	for x in `seq 145 240`; do
	echo $c2_charge >> charge_list.tmp
	done
	for x in `seq 241 336`; do 
	echo $c3_charge >> charge_list.tmp
	done
	for x in `seq 337 528`; do
	echo $o_charge >> charge_list.tmp
	done
	for x in `seq 529 624`;do
	echo $h_charge >> charge_list.tmp
	done

	# write new charges to the charges portion
	rm mof.str.2
	paste mof.str.2.empty charge_list.tmp > mof.str.2 

	# compile new mof.str
	rm mof.str
	cat mof.str.1 >> mof.str
	cat mof.str.2 >> mof.str
	cat mof.str.3 >> mof.str
	# now we've made our new mof.str.
	
	rm done_check.txt;
	echo "false" >> done_check.txt
	
else
	rm done_check.txt;
	echo "true" >> done_check.txt

fi
# now qmmm.sh can read done_check.txt to see if it should re-run charmm/qchem.

# if you are some poor soul looking at this years from now, find me and email me
# dfranz@mail.usf.edu
# khaverim7@gmail.com
