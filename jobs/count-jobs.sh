#!/bin/bash

# counts all active/queued jobs

rm *.tmp
squeue -o "%.18i" -u dfranz > d.tmp
tail -n +2 d.tmp > jobs.tmp

wc -l  jobs.tmp

rm *.tmp

echo "done counting jobs."
