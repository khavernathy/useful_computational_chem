#!/bin/bash

#this script will add all values in column 1 of data file $1
# e.g.
# add.sh myfile.txt 11

awk '{s+=$1} END {print s}' $1
