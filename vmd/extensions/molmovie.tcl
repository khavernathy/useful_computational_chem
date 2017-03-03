# vmd tcl procedure: animate by turning all molecules on and off 
#
# $Id: molmovie.tcl,v 1.1 2005/01/03 14:06:39 akohlmey Exp $
# Time-stamp: <akohlmey 02.01.2005 16:18:10 timburton.site>
#
# Copyright (c) 2004-2005 by <Axel.Kohlmeyer@theochem.ruhr-uni-bochum.de>
#
# the molmovie procedure creates an animation by 
# sequentially turning the molecules on and off
# default is to wait a 500 miliseconds between 'frames'
proc molmovie {{loops 10} {delay 500}} {
    global molmovie_last

    set nmols [molinfo num]
    if {![info exists molmovie_last]} {
        set molmovie_last [expr $nmols - 1]
    }

    for {set i 0} {$i < $loops} {incr i} {
        for {set n 0} {$n < $nmols} {incr n} {
            display update
            display update ui
            mol on $n
            mol off $molmovie_last
            set molmovie_last $n
            after $delay
        }
    }
}

############################################################
# Local Variables:
# mode: tcl
# time-stamp-format: "%u %02d.%02m.%y %02H:%02M:%02S %s"
# End:
############################################################
