#!/bin/bash

c=1

while [ "$c" -lt 553 ]; do
	echo $c >> counter.dat
	let c=$c+1
done
