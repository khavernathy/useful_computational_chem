#!/bin/bash

## cancels all jobs running on this server by fetching id's


rm *.tmp
squeue -o "%.18i" -u dfranz > jobids.tmp
tail -n +2 jobids.tmp > jobids_list.tmp

while read p; do
  scancel $p
done <jobids_list.tmp

rm *.tmp

echo "done canceling all jobs."
