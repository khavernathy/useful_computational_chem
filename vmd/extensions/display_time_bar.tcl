# vmd tcl procedure: display simulation time with a thermometer like bar.
# 
# $Id: display_time_bar.tcl,v 1.1 2003/07/16 13:29:12 wwwadmin Exp $
# Time-stamp: <akohlmey 13.04.2003 15:16:19 timburton.bochum>
#
# Copyright (c) 2003 by <Axel.Kohlmeyer@theochem.ruhr-uni-bochum.de>
#
# TODO: find a smart way to position the bar at the side of the
#       screen regardless of the number and size of molecules loaded.
#

# arguments:
#  mult:   length of a timestep  (default 1.0)
#  tdelta: increment of the tics (default 50)
#  unit:   unit of a timestep    (default ps)
#  tmol:   molecule id where the dial is added (default: current top)

proc display_time_bar {{mult 1.0} {tdelta 50} {unit "ps"} {tmol top}} {
    global display_time_bar_molid

    display update off
    if {![string compare $tmol top]} {
        set tmol [molinfo top]
    }

    set oldtop [molinfo top]
    if {![info exists display_time_bar_molid]} {
        set display_time_bar_molid [mol new]
        mol rename $display_time_bar_molid "time bar $tmol"
        mol fix $display_time_bar_molid
    }
    set bar $display_time_bar_molid
    mol top $oldtop

    # first delete the old bar (if any)
    graphics $bar delete all

    #########################################
    # set scale factor
    set scale 1.2
    # resolution of spheres
    set sres 15
    # resolution of cylindes
    set cres 10
    # radius of the inner cylinder
    set radi [ expr 0.01 * $scale ]
    # radius of the outer cylinder
    set rado [ expr 0.02 * $scale ]
    # radius of tics
    set radt [ expr 0.05 * $scale ]
    # height of tics
    set thgt [ expr 0.005 * $scale ]

    # offset of display from center in Angstrom
    set xsep [ expr -0.95 * $scale ]
    set ysep [ expr -0.9  * $scale ]
    set zsep [ expr  0.9  * $scale ]
    set ylen [ expr  1.7  * $scale ]

    #########################################
    # step size
    set tstep [molinfo $tmol get frame]
    if {$tstep < 1} {set tstep 1}
    set tmax  [molinfo $tmol get numframes]
    if {$tmax < 1} {set tmax 1}
    set delta [expr $ylen / $tmax ]

    # draw caption
    set sy [expr $ysep + 1.1 * $ylen ]
    graphics $bar color white
    graphics $bar text "$xsep $sy $zsep" "time ($unit)"

    # draw background cylinder and tics
    graphics $bar color silver
    graphics $bar material Opaque
    graphics $bar sphere "$xsep $ysep $zsep" radius $rado resolution $sres
    graphics $bar sphere [list $xsep [expr $ysep + $ylen] $zsep] \
        radius $rado resolution $sres
    graphics $bar cylinder "$xsep $ysep $zsep" \
        [list $xsep [expr $ysep + $ylen] $zsep] \
        radius $rado resolution $cres

    set c 0
    for {set i 0.0} {$i <= $ylen} \
        {set i [expr $i + ($delta * $tdelta / $mult)]} {

        set sy [expr $ysep + $i]
        graphics $bar color silver
        graphics $bar cylinder [list $xsep [expr $sy - $thgt] $zsep] \
            [list $xsep [expr $sy + $thgt] $zsep] \
            radius $radt resolution $cres filled yes
        graphics $bar color white
        graphics $bar text [list [expr $xsep + 1.5 * $radt] $sy $zsep] \
            [expr $c * $tdelta]
        incr c
    }

    # draw the cylinder representing the time.
    graphics $bar color red
    set sz [expr $zsep + 0.7 * $rado]
    graphics $bar cylinder [list $xsep $ysep $sz] \
        [list $xsep [expr $ysep + $tstep * $delta] $sz] \
        radius $radi resolution $cres filled yes

    display update on
    # restore top molecule (just in case we messed it up).
    mol top $oldtop
}

############################################################
# Local Variables:
# mode: tcl
# time-stamp-format: "%u %02d.%02m.%y %02H:%02M:%02S %s"
# End:
############################################################
