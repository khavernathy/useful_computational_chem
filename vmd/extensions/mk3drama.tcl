#!/usr/local/bin/vmd -e 
# $Id: mk3drama.tcl,v 1.3 2004/05/18 06:38:47 akohlmey Exp $
#
# creates a nice color coded 3d-ramachandran histogram graph 
# in a new 'molecule'
#
# the first (optional) argument is a selection to be analyzed
# the second is the resolution of the histogram.
#
# Copyright (c) 2003-2004 by Axel.Kohlmeyer@theochem.ruhr-uni-bochum.de
# some ideas 'borrowed' from the script 3D_grapher by Andrew Dalke.
#
# updated versions of this script may be found at:
# http://www.theochem.ruhr-uni-bochum.de/go/cpmd-vmd.html

proc mk3drama {{sel alltop} {res 48}} {

    # create a selection from all protein C-alpha atoms of 
    # the top molecule or copy the old one.
    if {![string compare $sel alltop]} {
        set sel [atomselect top {protein and name CA}]
    } else {
        set sel [atomselect [$sel molid] "[$sel text]"]
    }

    # sanity check(s).
    set a [$sel num]
    if { $a < 1} {
        puts "no atoms in selection"
        return
    }
    set n [molinfo [$sel molid] get numframes]
    if {$n < 1} {
        puts "no coordinate data available"
        return
    }

    # define binwidth
    set w [expr ($res - 1.0)/360.0]

    # clear histogram
    for {set i 0} {$i <= $res} {incr i} {
        for {set j 0} {$j <= $res} {incr j} {
            set data($i,$j) 0
        }
    }

    # collect data into histogram
    puts "collecting dihedral data from $n frames for $a atoms"
    for {set i 0 } { $i < $n } { incr i } {
        $sel frame $i
        $sel update

        foreach a [$sel get {phi psi}] {
            set phi [lindex $a 0]
            set psi [lindex $a 1]
            incr data([expr int(($phi + 180.0) * $w)],[expr int(($psi + 180.0) * $w)])
        }
    }

    # find maximum for normalization
    set maxz 0
    for {set i 0} {$i < $res} {incr i} {
        for {set j 0} {$j < $res} {incr j} {
            if { $data($i,$j) > $maxz } {set maxz $data($i,$j)}
        }
    }

    # turn off all existing molecules
    foreach mol [molinfo list] {
        mol off $mol
    }

    # create dummy molecule to draw into
    set mol [mol new]
    mol rename top {3d Ramachandran Histogram}

    # the resulting graph should have a size of 10x10x5
    # and centered at the origin. get scaling factors for that.
    set len  [expr 10.0 / $res]
    set norm [expr 5.0 / $maxz]

    # make sure the data wraps around nicely
    # and normalize the histogram
    for {set i 0} {$i <= $res} {incr i} {
        set data([expr $res - 1],$i) $data(0,$i)
        set data($res,$i) $data(1,$i)
        set data($i,[expr $res - 1]) $data($i,0)
        set data($i,$res) $data($i,1)
    }
    for {set i 0} {$i <= $res} {incr i} {
        for {set j 0} {$j <= $res} {incr j} {
            set data($i,$j) [expr $data($i,$j) * $norm]
        }
    }

    # setup color scaling
    color scale method BGR
    color scale max 0.9
    color scale midpoint 0.3

    # finally draw the surface by drawing triangles between
    # the midpoint and the corners of each square of data points
    for {set i 0} {$i < $res} {incr i} {
        for {set j 0} {$j < $res} {incr j} {

            # precalculate some coordinates and indices
            set i2 [expr $i + 1]
            set j2 [expr $j + 1]

            set x1 [expr ($i  - (0.5 * $res)) * $len]
            set x2 [expr ($i2 - (0.5 * $res)) * $len]
            set xm [expr 0.5 * ($x1 + $x2)]

            set y1 [expr ($j  - (0.5 * $res)) * $len]
            set y2 [expr ($j2 - (0.5 * $res)) * $len]
            set ym [expr 0.5 * ($y1 + $y2)]

            set zm [expr ($data($i,$j) + $data($i2,$j2) \
                        + $data($i2,$j) + $data($i,$j2)) / 4.0] 

            # calculate color for the triangles
            graphics $mol color [expr 17 + int (200 * $zm)] 

            # draw 4 triangles
            graphics $mol triangle "$x1 $y1 $data($i,$j)"     \
                "$xm $ym $zm" "$x2 $y1 $data($i2,$j)"
            graphics $mol triangle "$x1 $y1 $data($i,$j)"     \
                "$x1 $y2 $data($i,$j2)" "$xm $ym $zm"
            graphics $mol triangle "$x2 $y2 $data($i2,$j2)"   \
                "$x2 $y1 $data($i2,$j)" "$xm $ym $zm"
            graphics $mol triangle "$x2 $y2 $data($i2,$j2)"   \
                "$xm $ym $zm" "$x1 $y2 $data($i,$j2)"
        }
    }

    # add some decorations to the graph so that the 
    # peaks can be more easily located.
    # border
    graphics $mol color red
    graphics $mol sphere {-5.0 -5.0 0.0} radius 0.15 resolution 30
    graphics $mol sphere { 5.0 -5.0 0.0} radius 0.15 resolution 30
    graphics $mol sphere {-5.0  5.0 0.0} radius 0.15 resolution 30
    graphics $mol sphere { 5.0  5.0 0.0} radius 0.15 resolution 30
    graphics $mol cylinder { 5.0  5.0 0.0} {-5.0  5.0 0.0} radius 0.15 resolution 30
    graphics $mol cylinder {-5.0  5.0 0.0} {-5.0 -5.0 0.0} radius 0.15 resolution 30
    graphics $mol cylinder {-5.0 -5.0 0.0} { 5.0 -5.0 0.0} radius 0.15 resolution 30
    graphics $mol cylinder { 5.0 -5.0 0.0} { 5.0  5.0 0.0} radius 0.15 resolution 30
    # 0 degree lines
    graphics $mol color yellow
    graphics $mol sphere {-5.0  0.0 0.0} radius 0.1 resolution 30
    graphics $mol sphere { 5.0  0.0 0.0} radius 0.1 resolution 30
    graphics $mol sphere { 0.0 -5.0 0.0} radius 0.1 resolution 30
    graphics $mol sphere { 0.0  5.0 0.0} radius 0.1 resolution 30
    graphics $mol cylinder { 5.0  0.0 0.0} {-5.0  0.0 0.0} radius 0.1 resolution 30
    graphics $mol cylinder { 0.0  5.0 0.0} { 0.0 -5.0 0.0} radius 0.1 resolution 30
    # text labels (in black so they com
    graphics $mol color green
    graphics $mol text {0.0 -5.8 0.0} {Phi} size 2
    graphics $mol text {5.2  0.0 0.0} {Psi} size 2

    # set viewing angle to a resonable default.
    display resetview
    rotate x by -55
    rotate y by 10
    scale by 0.95

    # clean up
    $sel delete
    unset data
}


