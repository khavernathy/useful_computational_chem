#!/bin/bash

# this script compares two files
# it's not a line-by-line like diff (kinda) 
# rather, it will find matches ANYWHERE in 
# the other file, and output matches to
# match_output.txt

# because File2.txt is bigger, it gets the main loop.
while read string; do
    while read string2; do
    if [[ $string == *"$string2"* ]]; then
        echo $string >> match_output.txt
        echo "wrote "$string" to match_output.txt..."
    fi
    done < File1.txt
done < File2.txt
