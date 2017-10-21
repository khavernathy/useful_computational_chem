#!/bin/bash


# takes $1 as the filename which is a one-column file to sum and average

cat $1 | awk 'BEGIN {sum=0; n=0;} { sum += $1; n += 1; } END { print sum/n; }'
