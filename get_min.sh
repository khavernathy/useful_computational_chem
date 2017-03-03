#!/bin/bash

rm min.log
cat cage-without-header.xyz | awk 'BEGIN{min=100000000} {
                
		printf("X is %10lf\n",$2);
		if ($2 < min) 
                {
			min=$2;
                }
                else {
			min=min;
                }
		printf("Min is %10lf\n",min);

}' >> min.log

cat min.log | tail -1
