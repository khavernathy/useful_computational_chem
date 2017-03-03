#!/bin/bash

rm max.log
cat half-copper-circle-cage.xyz | awk 'BEGIN{max=0} {
                
		printf("X is %10lf\n",$2);
		if ($2 > max) 
                {
			max=$2;
                }
                else {
			max=max;
                }
		printf("Max is %10lf\n",max);

}' >> max.log

cat max.log | tail -1
