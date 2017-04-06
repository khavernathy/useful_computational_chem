#!/bin/bash

# establishes a "reference" graph to show how frequent dipole magnitudes with respect to each other.

for pres in 0.1 0.2 0.4 0.6 0.8 1.0 5.0 10.0 20.0 30.0 40.0 50.0 60.0; do
	
	cat $pres/*.dipole-00000.dat | awk {'print sqrt($1*$1 + $2*$2 + $3*$3)'} > $pres/dipole_mags.dat
	sort -nk1 $pres/dipole_mags.dat > $pres/tmp_di.dat
	echo '0 0' > $pres/dipole_hist.dat
	cat $pres/tmp_di.dat | awk 'BEGIN {c=0;binsize=0.005;bincount=binsize} {
									while ($1 >= bincount)
									{
										print bincount,c
										c=0
										bincount=bincount+binsize
									}
									if ($1 < bincount)
									{
										c=c+1
									}
								} END {print bincount,c}' >> $pres/dipole_hist.dat
									
	cat $pres/dipole_hist.dat | awk 'BEGIN {sum=0;} { sum += $2; } END {print sum}' > sumd.tmp
	read sum < sumd.tmp; echo $sum
	cat $pres/dipole_hist.dat | awk {'printf("%lf %lf \n",$1,$2 / '$sum')'} > $pres/tmp.tmp
	mv $pres/tmp.tmp $pres/dipole_hist.dat

	rm sumd.tmp;

	#rm $pres/tmp_di.dat	
done

# change template date to current date time
cp df.par t.par
date=$(date);
filedate=$(date +%Y-%m-%d);
sed -i -- 's/as of 7-21-2015/as of '"$date"'/g' t.par
sed -i -- 's/Pressure = 0.1atm/Pressure = 0.1 to 60atm/g' t.par

# save a PNG of graph
xmgrace -autoscale none -par t.par -hdevice PNG -hardcopy -printfile BSSP_dipole_frequencies_$filedate.png 0.1/dipole_hist.dat 0.2/dipole_hist.dat 0.4/dipole_hist.dat 0.6/dipole_hist.dat 0.8/dipole_hist.dat 1.0/dipole_hist.dat 5.0/dipole_hist.dat 10.0/dipole_hist.dat 20.0/dipole_hist.dat 30.0/dipole_hist.dat 40.0/dipole_hist.dat 50.0/dipole_hist.dat 60.0/dipole_hist.dat

# view graph
xmgrace -par t.par 0.1/dipole_hist.dat 0.2/dipole_hist.dat 0.4/dipole_hist.dat 0.6/dipole_hist.dat 0.8/dipole_hist.dat 1.0/dipole_hist.dat 5.0/dipole_hist.dat 10.0/dipole_hist.dat 20.0/dipole_hist.dat 30.0/dipole_hist.dat 40.0/dipole_hist.dat 50.0/dipole_hist.dat 60.0/dipole_hist.dat
rm t.par
