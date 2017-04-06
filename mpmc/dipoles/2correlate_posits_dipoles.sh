#!/bin/bash

# choose a lower/upper limit for dipole magnitudes to produce an xyz file with coordinates of dipole moments with that magnitude 
# "dipole_xyz.xyz" is the product

lower_limit=0.175
upper_limit=0.5



for pres in 0.05; do # 0.2 0.4 0.6 0.8 1.0 5.0 10.0 20.0 30.0 40.0 50.0 60.0; do

	cat $pres/*.dipole-00000.dat | awk {'print sqrt($1*$1 + $2*$2 + $3*$3)'} > $pres/dipole_mags.dat
	cat $pres/*.traj-00000.pqr | grep ' H2G ' > $pres/tmp_sorb_coords.dat
	paste $pres/tmp_sorb_coords.dat $pres/dipole_mags.dat > $pres/tmp_correlated.dat
	
	cat $pres/tmp_correlated.dat | awk {'printf(" D %10lf %10lf %10lf %12lf\n",$7,$8,$9,$20)'} > $pres/tmp_dipole_posits_and_mags.dat
	

	cat $pres/tmp_dipole_posits_and_mags.dat | awk {'if ($5 > '$lower_limit' && $5 < '$upper_limit') {print ;}'} > dipole_xyz.xyz

    lines=$(cat dipole_xyz.xyz | grep -c "")
    echo $lines > dipole_points.xyz
    echo "" >> dipole_points.xyz
    cat dipole_xyz.xyz >> dipole_points.xyz
    rm dipole_xyz.xyz
	mv dipole_points.xyz dipole_points$lower_limit"_to_"$upper_limit".xyz"
								
	#rm $pres/tmp_di.dat	
done

#gmolden 0.1/dipole_xyz.xyz

#xmgrace 0.1/tmp_cutoff.dat
#echo "xmgrace 0.1/dipole_hist.dat"; xmgrace 0.1/dipole_hist.dat
echo "dipole magnitudes from "$lower_limit" to "$upper_limit" considered."
echo "output to ./dipole_points"$lower_limit"_to_"$upper_limit".xyz"
