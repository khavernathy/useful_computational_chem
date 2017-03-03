#!/bin/bash

## cancels all specified jobs running on this server by fetching id's
## start id is first arg.; end is second

startj=$1
endj=$2

for i in $(seq $startj $endj);
do
	echo $i
	scancel $i
done




echo "done canceling specifed jobs."
