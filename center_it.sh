#!/bin/bash

# takes an xyz file and centers all atoms about the origin 0,0,0
# make sure the xyz has NO HEADER (immediately starts w/ atoms and coords)

if [[ $# -eq 0 ]]; then
	echo 'no argument suppled. Give an xyz with no header data.';
	exit 0
fi

filename=$1;

[ -e atomstemp ] && rm atomstemp
[ -e xtemp ] && rm xtemp
[ -e ytemp ] && rm ytemp
[ -e ztemp ] && rm ztemp
[ -e newxtemp ] && rm newxtemp
[ -e newytemp ] && rm newytemp
[ -e newztemp ] && rm newztemp


echo "writing column files..."
cat $filename | awk {'print $1'} > atomstemp;
cat $filename | awk {'print $2'} > xtemp;
cat $filename | awk {'print $3'} > ytemp;
cat $filename | awk {'print $4'} > ztemp;

echo "calculating minimums..."
minx=$(cut -f1 -d"," xtemp |sort -n| head -1);
miny=$(cut -f1 -d"," ytemp |sort -n| head -1);
minz=$(cut -f1 -d"," ztemp |sort -n| head -1);

echo "calculating maximums..."
maxx=$(cut -f1 -d"," xtemp |sort -n|tail -1);
maxy=$(cut -f1 -d"," ytemp |sort -n|tail -1);
maxz=$(cut -f1 -d"," ztemp |sort -n|tail -1);

echo "translating x coords..."
while read x; do
  newx=$(echo "scale=5; "$x" - ("$minx" + ("$maxx" - "$minx")/2.0)" | bc -l);
  echo $newx >> newxtemp;
done < xtemp;

echo "translating y coords..."
while read y; do
  newy=$(echo "scale=5; "$y" - ("$miny" + ("$maxy" - "$miny")/2.0)" | bc -l);
  echo $newy >> newytemp;
done < ytemp;

echo "translating z coords..."
while read z; do
  newz=$(echo "scale=5; "$z" - ("$minz" + ("$maxz" - "$minz")/2.0)" | bc -l);
  echo $newz >> newztemp;
done < ztemp;

echo "combining columns..."
paste atomstemp newxtemp newytemp newztemp > centered.xyz

echo "reformatting file..."
cat centered.xyz | awk {'printf("%3s %10f %10f %10f\n",$1,$2,$3,$4)'} > centered.out

rm centered.xyz atomstemp xtemp ytemp ztemp newxtemp newytemp newztemp;
echo "done. Final result in centered.out"
