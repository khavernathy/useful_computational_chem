#!/bin/bash

num_atoms=140
num_frames=157
traj_file="SIFSIX18Nibeta-pos-1.xyz"

rm out*xyz
rm crystaltraj.xyz

awk '/ '$num_atoms'/{n++}{print >"out" n ".xyz" }' $traj_file 


for x in `seq 1 $num_frames`; do
echo $x
awk -v num="$x" '{

    gsub(/XXX/,num);
    print;
}' mcmd.inp > a.inp;

~/mcmd/mcmd a.inp;
cat crystalbuild.xyz >> crystaltraj.xyz



done
