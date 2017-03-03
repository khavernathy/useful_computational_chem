# vmd extension procedures
#
# $Id: vmd_draw_vector.tcl,v 1.2 2005/01/03 14:06:39 akohlmey Exp $

# define vector drawing function.
# contrary to the example from the users guide, the vector is
# defined by it's origin, a vector at this point, and a scaling factor.
# the function returns a list of the graphics ids for easy deletion.
proc vmd_draw_vector {mol cnt vec {scale 1.0} {res 10} {radius 0.2}} {
    
    set vechalf [vecscale [expr $scale *0.5] $vec]
    return [list \
      [graphics $mol cylinder [vecsub $cnt $vechalf] \
        [vecadd $cnt [vecscale 0.7 $vechalf]] \
        radius $radius resolution $res filled yes] \
      [graphics $mol cone [vecadd $cnt [vecscale 0.7 $vechalf]] \
   	[vecadd $cnt $vechalf] radius [expr $radius * 1.7] \
	resolution $res]]
}

# alternative version of a vector drawing subroutine
# give basepoint and direction
proc vmd_draw_vector2 { mol pos val {scale 1.0} {res 10} {radius 0.2}} {
    set cnt  [ vecadd $pos [ vecscale [expr 0.5 * $scale] $val ] ]
    set rv [vmd_draw_vector $mol $cnt $val $scale $res $radius]
    return $rv
}


# draw a whole list of vectors. a convenience functions to draw a
# lot of vectors easily.
# field has to be a list of pairs of xyz triples (center and vector).
# the function returns a list of the graphics ids for easy deletion.
proc vmd_draw_vecfield {mol field {scale 1.0} {res 10} {radius 0.2}} {
    set gids ""
    foreach i $field {
        lassign $i cnt vec
        append gids " " [vmd_draw_vector $mol $cnt $vec $scale $res $radius]
    }
    return $gids
}

############################################################
# Local Variables:
# mode: tcl
# time-stamp-format: "%u %02d.%02m.%y %02H:%02M:%02S %s"
# End:
############################################################
