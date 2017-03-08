#!/bin/bash

# fetches ESP coordinates from runlog.log or whatever argument is provided.

if [ $# -eq 0 ]; then
	arg="runlog.log"
else
	arg=$1
fi

rm charges.tmp
rm charges2.tmp
rm final_charges.xyz

ln=$(cat $arg | grep -n " ESP" | awk {'print $1'})
rep="${ln/:/}"

echo "Line where ESP appears: "$rep
echo "Coordinates writing to temp file charges.tmp:";
echo "";
cl=$(($rep + 3));
stopc=0;
total_atoms=0;
while [ $stopc -ne 1 ]; do
	this_line=$(head -$cl $arg | tail -1);
	if grep -q "$this_line" <<<"-----"; then
		break;
		stopc=1; # JIC
	else
		echo $this_line;
		echo $this_line >> charges.tmp
	fi
	let total_atoms=$total_atoms+1;
	let cl=$cl+1;
done
cat charges.tmp
echo "............";
echo "";

head -n -2 charges.tmp > charges2.tmp

echo $(($total_atoms - 2)) >> final_charges.xyz;
echo "" >> final_charges.xyz;
cat charges2.tmp | awk {'printf("%2s %10f %10f %10f %10f\n",$2,$3*10,$4*10,$5*10,$6)'} >> final_charges.xyz


rm charges.tmp
rm charges2.tmp

echo "..done fetching nwchem output >> final_charges.xyz.";
