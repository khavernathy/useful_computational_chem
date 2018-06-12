#!/bin/bash

# THIS FILE MAKES output.xyz
# which is a .xyz with mapped element labels to .cif labels

# it requires 2 files
# 1) an xyz with the element label version of the system
#  e.g.
#   H 1 2 4
#  Li 54 2 2
#  Ne 4 2 2 
# ...
#
# 2) a 2-column atom_match.txt file which has the 
# .cif labels in 1st and Elemental label in 2nd
# e.g.
#  Cd1  H
#  Si1  He
#  F1   Li
# ...



match_file="atom_match.txt"
element_label_xyz="947383elements_1.xyz"
output_file="output.xyz"

rm $output_file

count=1
while read p; do
    echo $count
  element=$(echo $p | awk {'print $1'})
    while read a; do
        second=$(echo $a | awk {'print $2'})
        if [[ "$second" == "$element" ]]; then
            #echo "found match! "
            
            first=$(echo $a | awk {'print $1'})
            coords=$(echo $p | awk {'print $2,$3,$4'})
            

            echo $element" matched to... "$first
            echo $first $coords >> $output_file
        fi
    done < $match_file
    echo ""
    echo ""
    let count=$count+1
done < $element_label_xyz


cat $output_file | sort -nk1 > tmp
mv tmp $output_file

echo "Done writing "$output_file"."



