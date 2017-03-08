#!/bin/bash

rm max.log

cat myfile.txt | awk 'BEGIN{max=-10000000000000000000} {
		printf("X is %10f\n",$2);
		if ($2 > max) 
                {
			max=$2;
                }
                else {
			max=max;
                }
		printf("Max is %10f\n",max);
}' >> max.log

cat max.log | tail -1
rm max.log
