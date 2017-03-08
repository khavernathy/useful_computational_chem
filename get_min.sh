#!/bin/bash

rm min.log
cat myfile.txt | awk 'BEGIN{min=1000000000000000} {
                
		printf("X is %10f\n",$2);
		if ($2 < min) 
                {
			min=$2;
                }
                else {
			min=min;
                }
		printf("Min is %10f\n",min);

}' >> min.log

cat min.log | tail -1
rm min.log
