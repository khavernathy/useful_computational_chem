#!/bin/bash

num_atoms=152
num_frames=60
traj_file="SIFSIX18Ni-pos-1.xyz"

rm out*xyz
rm crystaltraj.xyz

awk '/ '$num_atoms'/{n++}{print >"out" n ".xyz" }' $traj_file 


for x in `seq 1 $num_frames`; do
awk -v num="$x" '{

    gsub(/XXX/,num);
    print;
}' mcmd.inp > a.inp;

echo $x " / " $num_frames
~/mcmd/mcmd a.inp > /dev/null;
cat crystalbuild.xyz >> crystaltraj.xyz



done
