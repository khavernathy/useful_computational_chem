#!/bin/bash
#!/bin/bash

# fetches ESP coordinates from runlog.log or whatever argument is provided.

if [ $# -eq 0 ]; then
	arg="runlog.log"
    inp="orca.inp"
else
	arg=$1
    inp=$2
fi

rm ready.tmp
rm charges.tmp
rm charges2.tmp
rm final_charges.xyz
rm coords.tmp

ln=$(cat $arg | grep -n "CHELPG Charges" | awk {'print $1'})
rep="${ln/:CHELPG/}"

echo "Line where CHELPG appears: "$rep
echo "Coordinates writing to temp file charges.tmp:";
echo "";
cl=$(($rep + 2));
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



head -n -3 charges.tmp  | awk {'print $4'} > charges2.tmp
echo "total atoms: "$(($total_atoms - 3));

echo $(($total_atoms - 3)) >> final_charges.xyz;
echo "" >> final_charges.xyz;




echo "grabbing coords from "$inp
rep=$(grep -nr "*xyz" $inp | gawk '{print $1}' FS=":")

echo "Line where *xyz appears: "$rep
echo "Coordinates writing to temp file coords.tmp:";
echo "";
cl=$(($rep + 1));
stopc=0;
total_atoms=0;
while [ $stopc -ne 1 ]; do
	this_line=$(head -$cl $inp | tail -1);
	if grep -q "$this_line" <<<"*"; then
		break;
		stopc=1; # JIC
	else
		echo $this_line;
		echo $this_line >> coords.tmp
	fi
	let total_atoms=$total_atoms+1;
	let cl=$cl+1;
done
cat coords.tmp
echo "............";
echo "";


paste coords.tmp charges2.tmp > ready.tmp
cat ready.tmp >> final_charges.xyz

#cat charges2.tmp | awk {'printf("%2s %10f %10f %10f %10f\n",$2,$3*10,$4*10,$5*10,$6)'} >> final_charges.xyz

rm ready.tmp
rm charges.tmp
rm charges2.tmp
rm coords.tmp

echo "..done fetching ORCA CHELPG output >> final_charges.xyz.";
