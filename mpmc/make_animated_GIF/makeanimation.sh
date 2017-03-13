#!/bin/bash

# TODO
# avoid xmgracing not-existent frames


basedir=$(pwd)
str="";
max_output_count=0
padwidth=8
corrtime=250
m_str="mpmc mine"
p_str="0.005 0.01 0.05 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1"
total_pressures_to_write=$(( $(echo $m_str | awk {'print NF'}) * $(echo $p_str | awk {'print NF'}) )); 
current_pressure=1
full_lines_in_files=$(( $(echo $p_str | awk {'print NF'}) + 1  )); # +1 because of the 0 0 line

for type in $m_str; do
    cd $type
        for p in $p_str; do
            cd $p
            # initialize frames for this pressure.
            echo "initializing frame files for "$type" at p = "$p" atm"
            for endfileID in 0 `seq 1 $(($count_instances-1))`; do 
                endfileID=$(printf "%0*d" $padwidth $endfileID)
                echo "0.0    0.0" > "../uptakes-"$endfileID".dat"
            done
            cd ..
        done
    cd ..
done


for type in $m_str; do
    cd $type;
            for p in $p_str; do
                cd $p;
                echo "calculating "$(pwd)" :: ( "$current_pressure" / "$total_pressures_to_write" )"

                # MPMC TREATMENTS
                if [[ "$type" == "mpmc" ]]; then
                    # get number of corrtime outputs
                    count_instances=$(cat runlog.log | grep -c "wt % = ")

                    if [[ "$max_output_count" -lt "$count_instances" ]]; then
                        max_output_count=$count_instances
                    fi

                    # get all frames and save to files -000.dat, -001.dat, -002.dat...
                    echo "MPMC: writing frame values"
                    counter=1;
                    for endfileID in 0 `seq 1 $(($count_instances-1))`; do
                        endfileID=$(printf "%0*d" $padwidth $endfileID)
                        uptake=$(grep -m$counter "wt % = " runlog.log | tail -n1 | awk {'print $5'})
                        echo $p"    "$uptake >> "../uptakes-"$endfileID".dat"
                        let counter=$counter+1
                    done

                # MY PROGRAM TREATMENTS
                elif [[ "$type" == "mine" ]]; then
                    # get number of corrtime outputs
                    count_instances=$(cat runlog.log | grep -c "wt % = ")
                    
                    if [[ "$max_output_count" -lt "$count_instances" ]]; then
                        max_output_count=$count_instances
                    fi

                    # get all frames and save to files
                    echo "MINE: writing frame values"
                    counter=1
                    for endfileID in 0 `seq 1 $(($count_instances - 1))`; do
                        endfileID=$(printf "%0*d" $padwidth $endfileID)
                        uptake=$(grep -m$counter "wt % = " runlog.log | tail -n1 | awk {'print $4'})
                        echo $p"    "$uptake >> "../uptakes-"$endfileID".dat"
                        let counter=$counter+1
                    done
    
                fi # end if mpmc/mine

                cd .. # out of pressure
                let current_pressure=$current_pressure+1
            done #with pressure loop
    cd .. # out of mpmc/mine
done # with model loop

cd $basedir; # JIC

echo "max_output_count = "$max_output_count
#echo "full file line count = "$full_lines_in_files
echo "writing .png files for each frame: Exp. vs MPMC vs mine"
count=1
for endfileID in 0 `seq 1 $(($max_output_count - 1))`; do
        endfileID=$(printf "%0*d" $padwidth $endfileID)
        #mpmcl=$(cat "mpmc/uptakes-"$endfileID".dat" | grep -c "")
        #minel=$(cat "mpmc/uptakes-"$endfileID".dat" | grep -c "")
        #if [[ "$mpmcl" -eq "$full_lines_in_files" ]]; then
        #if [[ "$minel" -eq "$full_lines_in_files" ]]; then
        echo "writing image "$count" / "$max_output_count
        cp isotherm.par t.par
        sed -i -- 's/XMCSTEPX/'"$(($corrtime * $count))"'/g' t.par
        str="mpmc/uptakes-"$endfileID".dat mine/uptakes-"$endfileID".dat 0.dat" # 0.dat is the placeholder for MC step.
        xmgrace -autoscale none -par t.par -hdevice PNG -hardcopy -printfile image.$endfileID.png mof5_77k.dat $str
        let count=$count+1
        rm t.par
        #fi
        #fi
done

echo "converting .png files to animation .gif"
convert -delay 5 -loop 0 image.*.png animation.gif

echo "CLEANUP: removing data files"
rm image.*.png
rm -f sed*
rm */uptakes-*.dat

echo "all done. Animation output to animation.gif"
echo ""
