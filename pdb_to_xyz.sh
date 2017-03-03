#!/bin/bash

if [[ $# -eq 0 ]]; then
        echo 'No argument supplied. Give a pdb with no header data.';
        exit 0
fi

filename=$1;
repeat=$2;

[ -e xs ] && rm xs
[ -e ys ] && rm ys
[ -e zs ] && rm zs
[ -e elements ] && rm elements
[ -e charges ] && rm charges

cat $filename | awk {'print $3'} > elements
cat $filename | awk {'print $7'} > xs
cat $filename | awk {'print $8'} > ys
cat $filename | awk {'print $9'} > zs
cat $filename | awk {'print $11'} > charges

paste elements xs ys zs charges > output.xyz

rm xs ys zs elements charges;

for x in `seq 1 $repeat`; do
	cat output.xyz >> new;
done

mv new output.xyz

echo "done converting pdb -> xyx :: wrote to output.xyz."
