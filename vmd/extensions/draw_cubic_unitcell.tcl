# vmd tcl procedure: draw a cubic box grid with a given 
#                    edgelength and centered at the origin.
#
# $Id: draw_cubic_unitcell.tcl,v 1.1 2003/07/16 13:29:12 wwwadmin Exp $
# Time-stamp: <akohlmey 15.07.2003 22:08:38 timburton.bochum>
#
# Copyright (c) 2003 by <Axel.Kohlmeyer@theochem.ruhr-uni-bochum.de>
#

# add a cubic unitcell graphic to a molecule. molicule id, color 
# and offset are optional.
#
# arguments: 
#  cell  = edgelength
#  molid = molecule id where the unitcell is added to (default top)

proc draw_cubic_unitcell {cell {molid top} {col iceblue} {xoff 0.0} {yoff 0.0} {zoff 0.0}} {

    if {![string compare $molid top]} {
        set molid [molinfo top]
    }

    # set size and radius of spheres and cylinders
    set chalf [expr  0.5 * $cell]
    set srad [expr 0.012 * $cell]
    set sres 15
    set crad [expr 0.010 * $cell]
    set cres 10
    set off [list $xoff $yoff $zoff]

    # define vertices of the unitcell
    set vert(0) [list [expr -1.0 * $chalf] [expr -1.0 * $chalf] [expr -1.0 * $chalf]] 
    set vert(1) [list [expr  1.0 * $chalf] [expr -1.0 * $chalf] [expr -1.0 * $chalf]]
    set vert(2) [list [expr -1.0 * $chalf] [expr  1.0 * $chalf] [expr -1.0 * $chalf]]
    set vert(3) [list [expr  1.0 * $chalf] [expr  1.0 * $chalf] [expr -1.0 * $chalf]]
    set vert(4) [list [expr -1.0 * $chalf] [expr -1.0 * $chalf] [expr  1.0 * $chalf]]
    set vert(5) [list [expr  1.0 * $chalf] [expr -1.0 * $chalf] [expr  1.0 * $chalf]]
    set vert(6) [list [expr -1.0 * $chalf] [expr  1.0 * $chalf] [expr  1.0 * $chalf]]
    set vert(7) [list [expr  1.0 * $chalf] [expr  1.0 * $chalf] [expr  1.0 * $chalf]]

    graphics $molid color $col

    # draw spheres into the vertices ...
    set gid ""
    for {set i 0} {$i < 8} {incr i} {
        lappend gid [graphics $molid sphere [vecadd $vert($i) $off] radius $srad resolution $sres]
    }

    # ... and connect them with cylinders
    foreach i {{0 1} {0 2} {0 4} {1 5} {2 3} {4 6} {1 3} {2 6} {4 5} {7 3} {7 5} {7 6}} {
        lappend gid [graphics $molid cylinder [vecadd $vert([lindex $i 0]) $off] [vecadd $vert([lindex $i 1]) $off] radius $crad resolution $cres]
    }

    # return list of graphics indices so that they can be saved and deleted later.
    return $gid
}

############################################################
# Local Variables:
# mode: tcl
# time-stamp-format: "%u %02d.%02m.%y %02H:%02M:%02S %s"
# End:
############################################################
