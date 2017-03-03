for pres in 0.1 0.2 0.4 0.6 0.8 1.0 5.0 10.0 20.0 30.0 40.0 50.0 60.0; do echo $pres; cd $pres; cat runlog.log | grep Completed | tail -1; cat runlog.log | grep ETA | tail -1; cd ..; done
