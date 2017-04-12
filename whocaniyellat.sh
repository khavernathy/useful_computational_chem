#!/bin/sh

# with modifications by Doug. Messy code but useful output.
# only running jobs counted.

#squeue | awk '{print $4,$7}' > out

squeue -o '"'"' %u %8i %3t %4p %18j %9M %12l %12L %17B %4C %5D %Z'"'"' -S -t,i | awk '
	BEGIN{
		x=0;
	}

	{
		if ($4 == "R") {
		list[x]=$2;
		procs[x]=$11;
		x+=1;
		}
	}

	END{
			unique_names=0;
			for(y=2; y<x; y++){
				found = 0;
				for(u=0; u<unique_names; u++){
					if(match(list[y], unique_array[u])){
						found=1;
						unique_procs[u]+=procs[y];}
				}
				if(!found){
					unique_array[unique_names]=list[y];
					unique_procs[unique_names]=procs[y];
					unique_names+=1;
				}	
			}


			printf("  Current users        #CPUS       usage Factor\n");
			printf("------------------------------------------------\n");
			for(y=0; y<unique_names; y++){
				afac=1;
				printf("%16s\t%d\t\t%.3f\n", unique_array[y],unique_procs[y],afac);
			}
		
	}' > ./yell.tmp

cat yell.tmp | sort -nk3 > sorted.tmp
rm ./yell.tmp
#cat sorted.tmp

cat sorted.tmp | awk '{s+=$2} END {print s}' > sum.tmp
sum=$(cat sum.tmp); 

## that was just for the sum #####, now pull all again.



squeue -o '"'"' %u %8i %3t %4p %18j %9M %12l %12L %17B %4C %5D %Z'"'"' -S -t,i | awk '
        BEGIN{
                x=0;
        }

        {
		if ($4 == "R") {
                list[x]=$2;
		if ($2 == "dfranz") { list[x] = "#########DFRANZ"; }
                procs[x]=$11;
                x+=1;
		}
        }

        END{
                        unique_names=0;
                        for(y=2; y<x; y++){
                                found = 0;
                                for(u=0; u<unique_names; u++){
                                        if(match(list[y], unique_array[u])){
                                                found=1;
                                                unique_procs[u]+=procs[y];
                                        }
                                }
                                if(!found){
                                        unique_array[unique_names]=list[y];
                                        unique_procs[unique_names]=procs[y];
                                        unique_names+=1;
                                }       
                        }


                        printf("  Current users        #CPUS       usage Factor\n");
                        printf("------------------------------------------------\n");
                        for(y=0; y<unique_names; y++){
                                afac=unique_procs[y]/'$sum'*100;
                                printf("%16s\t%d\t\t%.2f%%\n", unique_array[y],unique_procs[y],afac);
                        }
        }' > ./yell.tmp


cat yell.tmp | sort -nk3

echo $sum' / 7168 CIRCE cores being used (actively, not queued.)';
printf "That's %.2f%% of total CIRCE cores.\n" $(bc -q <<< scale=6\;$sum/7168*100)
echo "This was output on "$(date)

rm sum.tmp sorted.tmp yell.tmp;
