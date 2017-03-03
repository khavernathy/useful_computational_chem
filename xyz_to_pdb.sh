#!/bin/bash

if [[ $# -eq 0 ]]; then
	echo 'No argument supplied. Give an xyz with no header data.';
	exit 0
fi

[ -e output.pdb ] && rm output.pdb
[ -e elements ] && rm elements
[ -e xs ] && rm xs
[ -e ys ] && rm ys
[ -e zs ] && rm zs
[ -e charges ] && rm charges
[ -e atoms ] && rm atoms
[ -e nums ] && rm nums
[ -e mol_name ] && rm mol_name
[ -e mol_id ] && rm mol_id
[ -e MF ] && rm MF
[ -e temppdb ] && rm temppdb
[ -e end_labels ] && rm end_labels
[ -e mass_labels ] && rm mass_labels


filename=$1;
total_lines=$(cat $filename | grep -c ""); # counts lines
cat $filename | awk {'print $1'} > elements
cat $filename | awk {'print $1"XXX"'} > end_labels
cat $filename | awk {'print $1"MASSXXX"'} > mass_labels
cat $filename | awk {'print $2'} > xs
cat $filename | awk {'print $3'} > ys
cat $filename | awk {'print $4'} > zs
cat $filename | awk {'print $5'} > charges

for i in `seq 1 $total_lines`; do
	mover=$(echo $i" + 0" | bc -l);
	echo "ATOM  " >> atoms
	echo $mover"  " >> nums
	echo "fec  " >> mol_name   # for now just gives mol as the name of all molecules
	echo 1"  " >> mol_id # 1 for all for now just gives unique mol_id to all atoms
	echo "M  " >> MF # for now just makes all atoms movable
done

paste atoms nums elements mol_name MF mol_id xs ys zs mass_labels charges end_labels > temppdb

cat temppdb | awk {'printf("%s %i %s %s %s %i %10f %10f %10f %s %10f %s\n",$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)'} > output.pdb;

echo "wrote converted xyz -> pdb to output.pdb.";
[ -e elements ] && rm elements
[ -e xs ] && rm xs
[ -e ys ] && rm ys
[ -e zs ] && rm zs
[ -e charges ] && rm charges
[ -e atoms ] && rm atoms
[ -e nums ] && rm nums
[ -e mol_name ] && rm mol_name
[ -e mol_id ] && rm mol_id
[ -e MF ] && rm MF
[ -e temppdb ] && rm temppdb
[ -e end_labels ] && rm end_labels
[ -e mass_labels ] && rm mass_labels

