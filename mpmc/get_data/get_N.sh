#!/bin/bash

for pres in 0.1 0.2 0.4 0.6 0.8 1.0 5.0 10.0 20.0 30.0 40.0 50.0 60.0; do
	
	cat $pres/*.energy.dat | awk {'print $9'} > $pres/Ns.dat
done

echo "xmgrace 0.1/Ns.dat 0.2/Ns.dat 0.4/Ns.dat  0.6/Ns.dat 0.8/Ns.dat 1.0/Ns.dat 5.0/Ns.dat 10.0/Ns.dat 20.0/Ns.dat 30.0/Ns.dat 40.0/Ns.dat 50.0/Ns.dat 60.0/Ns.dat"

