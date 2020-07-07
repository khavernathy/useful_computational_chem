#!/bin/bash

# writes a list of integers 1 -> $1 

c=1
x=$(($1+1))
echo 'writing one-column integer list 1 -> '$x' to counter.dat'

while [ "$c" -lt $x ]; do
	echo $c >> counter.dat
	let c=$c+1
done
