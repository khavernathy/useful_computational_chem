#!/bin/bash

for pres in 0.1 0.2 0.4 0.6 0.8 1.0 5.0 10.0 20.0 30.0 40.0 50.0 60.0; do

	mkdir $pres
	cp input.pqr ./$pres
	cat NOTT-112+h2.inp | sed 's/xxx/'$pres'/' > ./$pres/NOTT-112+h2.inp
	cat sub_it.sge | sed 's/XXX/'$pres'/' > ./$pres/sub_it.sge
	
	cd ./$pres
	sbatch sub_it.sge
	cd ../
done
