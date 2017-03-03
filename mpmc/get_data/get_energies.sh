#!/bin/bash

for pres in 0.1 0.2 0.4 0.6 0.8 1.0 5.0 10.0 20.0 30.0 40.0 50.0 60.0; do
	
	cat $pres/*.energy.dat | awk {'print $2'} > $pres/energies.dat
done

echo "xmgrace 0.1/energies.dat 0.2/energies.dat 0.4/energies.dat  0.6/energies.dat 0.8/energies.dat 1.0/energies.dat 5.0/energies.dat 10.0/energies.dat 20.0/energies.dat 30.0/energies.dat 40.0/energies.dat 50.0/energies.dat 60.0/energies.dat"

