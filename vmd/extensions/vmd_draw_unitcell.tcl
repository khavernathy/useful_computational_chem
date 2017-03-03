# vmd extension procedure: 
# provide a 'draw unitcell' command
#
# $Id: vmd_draw_unitcell.tcl,v 1.2 2005/01/11 13:05:12 akohlmey Exp $
# Time-stamp: <akohlmey 10.01.2005 21:01:20 yello.theochem.ruhr-uni-bochum.de>
#
# Copyright (c) 2003-2005 by <Axel.Kohlmeyer@theochem.ruhr-uni-bochum.de>

# add a unitcell graphic to a molecule via a draw subcommand.
#
#  options:
#  cell  (vmd|auto|[list <a> <b> <c> <alpha> <beta> <gamma>]), default: "vmd"
#          "vmd"  will use the internal values, 
#          "auto" will build an orthogonal unitcell from the result of 
#           'measure minmax' plus 1 angstrom added in each direction.
#         else a list of a,b,c,alpha,beta,gamma will be assumed.
#  origin ([list <x> <y> <z>]|auto), default: {0.0 0.0 0.0}, "auto" with 'cell auto' 
#  style: (lines|dashed|rod)  default: line
#  width:  <lines/rod width>  default: 1.0  
#  resolution: <res>       default: 8
#  

proc vmd_draw_unitcell {molid args} {

    # parse arguments
    foreach {flag arg} $args {
        switch $flag {
            cell       { set cell       "$arg" }
            origin     { set origin     "$arg" }
            style      { set style      "$arg" }
            width      { set width      "$arg" }
            resolution { set resolution "$arg" }
            default   { puts "unknown option: $flag"; return }
        }
    }

    if [info exists cell] {
        if {![info exists origin] && $cell == "auto"} { set origin auto }
    } else {
        set cell vmd
    }

    if ![info exists origin]      { set origin     {0.0 0.0 0.0} }
    if ![info exists style]       { set style       lines        }
    if ![info exists width]       { set width       1            }
    if ![info exists resolution]  { set resolution  8            }
    # FIXME: add some checks on the arguments here.

    # handle auto keywords
    if {$cell == "auto" || $origin == "auto" } {
        set sel [atomselect $molid {all}]
        set minmax [measure minmax $sel]
        $sel delete
        unset sel

        if {$origin == "auto" } {set origin [vecsub [lindex $minmax 0] {1 1 1}]}
        if {$cell == "auto"} {
            set cell [vecadd [vecsub [lindex $minmax 1] [lindex $minmax 0]] {2 2 2}]
            lappend cell 90.0 90.0 90.0
        }
    }

    if {$cell == "vmd" } {set cell [molinfo $molid get {a b c alpha beta gamma}]}
    global M_PI
    set sa [expr sin([lindex $cell 3]/180.0*$M_PI)]
    set ca [expr cos([lindex $cell 3]/180.0*$M_PI)]
    set cb [expr cos([lindex $cell 4]/180.0*$M_PI)]
    set cg [expr cos([lindex $cell 5]/180.0*$M_PI)]
    set sg [expr sin([lindex $cell 5]/180.0*$M_PI)]

    # set up cell vectors according to the VMD unitcell conventions.
    # the a-vector is collinear with the x-axis and
    # the b-vector is in the xy-plane. 
    set a [vecscale [lindex $cell 0] {1 0 0}]
    set b [vecscale [lindex $cell 1] "$ca $sa 0"]
    set c [vecscale [lindex $cell 2] "$cb [expr ($ca - $cb*$cg)/$sg] [expr sqrt((1.0 + 2.0*$ca*$cb*$cg - $ca*$ca - $cb*$cb - $cg*$cg)/(1.0 - $cg*$cg))]"] 

    # set up cell vertices
    set vert(0) $origin
    set vert(1) [vecadd $origin $a]
    set vert(2) [vecadd $origin $b]
    set vert(3) [vecadd $origin $a $b]
    set vert(4) [vecadd $origin $c]
    set vert(5) [vecadd $origin $a $c]
    set vert(6) [vecadd $origin $b $c]
    set vert(7) [vecadd $origin $a $b $c]
    unset sa ca cb cg sg

    set gid ""
    switch $style {
        rod {
            # set size and radius of spheres and cylinders 
            set srad [expr $width * 0.003 * [veclength [vecadd $a $b $c]]]
            set crad [expr 0.99 * $srad]

            # draw spheres into the vertices ...
            for {set i 0} {$i < 8} {incr i} {
                lappend gid [graphics $molid sphere $vert($i) radius $srad resolution $resolution]
            }
            # ... and connect them with cylinders
            foreach {i j} {0 1  0 2  0 4  1 5  2 3  4 6  1 3  2 6  4 5  7 3  7 5  7 6}  {
                lappend gid [graphics $molid cylinder $vert($i) $vert($j) radius $crad resolution $resolution]
            }
        }

        lines {
            set width [expr int($width + 0.5)]
            foreach {i j} {0 1  0 2  0 4  1 5  2 3  4 6  1 3  2 6  4 5  7 3  7 5  7 6}  {
                lappend gid [graphics $molid line $vert($i) $vert($j) width $width style solid]
            }
        }

        dashed {
            set width [expr int($width + 0.5)]
            foreach {i j} {0 1  0 2  0 4  1 5  2 3  4 6  1 3  2 6  4 5  7 3  7 5  7 6}  {
                lappend gid [graphics $molid line $vert($i) $vert($j) width $width style dashed]
            }
        }
        default { puts "unknown unitcell style: $style" ; return }
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
