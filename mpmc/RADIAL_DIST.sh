#!/bin/bash

######### THIS SCRIPT COMBINES THE TWO OLD SCRIPTS FOR CALCULATING 
######### AND GRAPHING RADIAL DISTRIBUTION BY DISTANCE IN ANGSTROMS.
## retrieves data from restart.pqr files, which means it's very current when run


# remove tmp files just in case
[ -e radial_diffs* ] && rm radial_diffs*
[ -e all_centers_tmp.dat ] && rm all_centers_tmp.dat
[ -e all_posits_tmp.dat ] && rm all_posits_tmp.dat
[ -e basis_vec.tmp ] && rm basis_vec.tmp
[ -e t.par ] && rm t.par

mof="MPM-1-Br"
binsize=0.3

# define atoms to analyze radial distribution
sorbate_str="co2"
#sorbate_str="h2"
model_str="polar nonpolar trappe" 
#model_str="BSSP BSS BUCH DL"
temp_str="273 298"
#temp_str="77 87"
c_site_str="BR1 BR2 CU"
o_site_str="COG"
pres_str="0.05 0.1 0.2 0.4 0.6 0.8 1.0"

basedir=$(pwd)

eog_str="" # string of image names to view after.


total_pressures_to_calc=$(( $(echo $sorbate_str | awk {'print NF'}) * $(echo $model_str | awk {'print NF'}) * $(echo $temp_str | awk {'print NF'}) * $(echo $c_site_str | awk {'print NF'}) * $(echo $o_site_str | awk {'print NF'}) * $(echo $pres_str | awk {'print NF'})     ));

current_pressure_counter=1;

for sorbate in $sorbate_str; do
for c_site in $c_site_str; do
for o_site in $o_site_str; do
for model in $model_str; do
for temp in $temp_str; do

#cd $sorbate"/"$temp"K/"$model"/" # so grace will open in, e.g. ./298K/polar/
cd $sorbate"/"$model"/"$temp"K/"
xmg_str=""

for pres in $pres_str; do 

	############ PART 1: Get positions, radial distances, and thus radial magnitudes
    	
    echo ""	
	echo " -------> $sorbate :: $temp K :: $model :: $c_site <-> $o_site :: pressure: "$pres" atm ( $current_pressure_counter / $total_pressures_to_calc )"
	# grab site coordinates
	cat $pres/*.restart-00000.pqr | grep "$c_site" > all_centers_tmp.dat
	#cat $pres/*.traj-00000.pqr | grep "$o_site" > all_posits_tmp.dat
    cat $pres/saved_data/traj.pqr | grep "$o_site" > all_posits_tmp.dat	

	#cat all_posits_tmp.dat
	#cat all_centers_tmp.dat
	
	m=1
	num_atoms=$(cat all_centers_tmp.dat | wc -l)
	limit=$(($num_atoms + 1))

	echo "number of center sites: "$c_site": "$num_atoms
	
	# 90 degree basis lengths
	cat $pres/*.inp | grep "basis" > basis_vec.tmp
	x_basis=$(cat basis_vec.tmp | head -1 | awk {'print $2'})
	y_basis=$(cat basis_vec.tmp | head -2 | tail -1 | awk {'print $3'})
	z_basis=$(cat basis_vec.tmp | tail -1 | awk {'print $4'})
	#echo "xyz basis lengths: "$x_basis,$y_basis,$z_basis

	# write all distance differences from CuC center site xyz to H2 xyz
	while [ "$m" -lt "$limit" ]; do
		cx=$(cat all_centers_tmp.dat | head -$m | tail -1 | awk {'print $7'})
		cy=$(cat all_centers_tmp.dat | head -$m | tail -1 | awk {'print $8'})
		cz=$(cat all_centers_tmp.dat | head -$m | tail -1 | awk {'print $9'})
		#echo "center "$m": "$cx $cy $cz
		
		cat all_posits_tmp.dat | awk '{printf("%10lf %10lf %10lf\n",'$cx'-$7,'$cy'-$8,'$cz'-$9)}' >> radial_diffs_xyz_tmp.dat
		
		#echo $x
		let m=$m+1
	done

	#cat radial_diffs_xyz_tmp.dat
	echo "done catting XYZ differences -- radial_diffs_xyz_tmp.dat";
	
	hbx=$(echo $x_basis*0.5 | bc)
	hby=$(echo $y_basis*0.5 | bc)
	hbz=$(echo $z_basis*0.5 | bc)
	
	echo "basis:" $x_basis $y_basis $z_basis
	echo "half basis: " $hbx $hby $hbz

	# remove negatives (just magnitudes) of xyz distances
	cat radial_diffs_xyz_tmp.dat | sed 's/-//g' > radial_diffs_xyz_tmp_positives.dat
	
	# reduce distances to half of basis dim. as a max.
	cat radial_diffs_xyz_tmp_positives.dat | awk '{
		if ($1 > '$hbx') 
		{
			printf("%10lf ",'$x_basis'-$1);
		}
		else {
			printf("%10lf ",$1);
		}
		 

		if ($2 > '$hby') 
		{
			printf("%10lf ",'$y_basis'-$2);
		}
		else {
			printf("%10lf ",$2);
		
		}

		if ($3 > '$hbz') 
		{
			printf("%10lf\n",'$z_basis'-$3);
		}
		else {
			printf("%10lf\n",$3);
		}
	}' >> radial_diffs_tmp_wrapped_half.dat
	
	#cat radial_diffs_tmp_wrapped_half.dat
	echo 'done catting radial half XYZs';
	
	# get magnitudes from xyz distances... r = (x^2 + y^2 + z^2)^(1/2)
	rm $pres/final_radial_diffs*
	cat radial_diffs_tmp_wrapped_half.dat | awk {'printf("%10lf\n",($1*$1+$2*$2+$3*$3)**(0.5))'} >> $pres/final_radial_diffs_$pres.dat
	

	#cat final_radial_diffs.dat
	echo 'done catting radial mags';
	
	#remove temp files
	rm radial_diffs*
	rm all_centers_tmp.dat
	rm all_posits_tmp.dat 
	rm basis_vec.tmp

	############### PART 2: MAKE GRAPH from magnitudes (get radial bins)
	
	#sort the radial magnitudes
	sort -nk1 $pres/final_radial* > $pres/tmp_sorted_radials.dat
	
	# insert 0 0 point on the bins file
	echo '0 0' > $pres/radial_hist.dat
	
	# bin 'em
		cat $pres/tmp_sorted_radials.dat | awk 'BEGIN {c=0;binsize='$binsize';bincount=binsize} {
							
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
								} END {print bincount,c}' >> $pres/radial_hist.dat
	
	
	# normalize: molecules (e.g. H2) in each slice per unit volume
	cat $pres/radial_hist.dat | awk {'printf("%lf %lf \n",$1,($2 / (((4.0/3.0)*3.14159265359*($1)**3) -((4.0/3.0)*3.14159265359*($1-'$binsize')**3))))'} > $pres/tmp.tmp
	mv $pres/tmp.tmp $pres/radial_hist.dat

	
	# normalize: scale bin sizes to 1 total								
	cat $pres/radial_hist.dat | awk 'BEGIN {sum=0;} { sum += $2; } END {print sum}' > sumd.tmp
	read sum < sumd.tmp; echo "sum of r counts: "$sum
	cat $pres/radial_hist.dat | awk {'printf("%lf %lf \n",$1,$2 / '$sum')'} > $pres/tmp.tmp
	mv $pres/tmp.tmp $pres/radial_hist.dat

	# normalize offset points to "mid-range"
	cat $pres/radial_hist.dat | awk {'printf("%lf %lf \n",($1 - ('$binsize' / 2.0)),$2)'} > $pres/tmp.tmp
	mv $pres/tmp.tmp $pres/radial_hist.dat

	#remove leftover tmp files
	rm sumd.tmp;
	rm $pres/tmp_sorted_radials.dat

    # add this pressure g(r) to the xmgrace list to graph
	xmg_str=$xmg_str" "$pres"/radial_hist.dat"

let current_pressure_counter=$current_pressure_counter+1;

done # done with pressure loop

cp $basedir/radial.par t.par
date=$(date);
filedate=$(date +%Y-%m-%d);
sed -i -- 's/sorbate/'"$sorbate"'/g' t.par
sed -i -- 's/c_site/'"$c_site"'/g' t.par
sed -i -- 's/o_site/'"$o_site"'/g' t.par
sed -i -- 's/model/'"$model"'/g' t.par
sed -i -- 's/temperature/'"$temp"'/g' t.par
sed -i -- 's/mof/'"$mof"'/g' t.par

echo "xmgrace string: "$xmg_str

# save graph to a PNG
savefile="rad_dists_"$model"."$c_site"_"$o_site"."$filedate".png"
xmgrace -par t.par -hdevice PNG -hardcopy -printfile rad_dists_$model.$c_site.$filedate.png $xmg_str 
echo "saved .png of graph as "$(pwd)"/"$savefile

#eog_str=$eog_str" "$(pwd)"/"$savefile

echo "_________________________________________________________________"
echo "opening graph of $c_site <-> $o_site at $temp K, for $model model."
echo "pwd: "$(pwd)
echo "_________________________________________________________________"
echo ""

# view graph in background
xmgrace -par t.par $xmg_str &

cd $basedir; #go back to base before next run.

done
done
done
done
done

