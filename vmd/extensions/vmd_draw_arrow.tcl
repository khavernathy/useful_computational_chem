# vmd extension procedures
#
# $Id: vmd_draw_arrow.tcl,v 1.1 2005/01/03 14:06:39 akohlmey Exp $

# this is an improved version of the 'draw arrow' extension
# as described in the user's guide. this version also returns
# the list of graphic ids for easy selective deletion.
proc vmd_draw_arrow {mol start end {scale 1.0} {res 10} {radius 0.2}} { 
  set middle [vecadd $start [vecscale $scale [vecsub $end $start]]] 
  return [list \
      [graphics $mol cylinder $start $middle radius $radius \
                resolution $res filled yes] \
      [graphics $mol cone $middle $end radius [expr $radius * 1.7] \
                resolution $res ] \
  ]
}

# draw a whole list of arrows. a convenience functions to draw a
# lot of vectors easily.
# field has to be a list of pairs of xyz triples (start- and endpoint).
# the function returns a list of the graphics ids for easy deletion.
proc vmd_draw_arrowfield {mol field {scale 1.0} {res 10} {radius 0.2}} {
    set gids ""
    foreach i $field {
        lassign $i cnt vec
        append gids " " [vmd_draw_arrow $mol $cnt $vec $scale $res $radius]
    }
    return $gids
}

############################################################
# Local Variables:
# mode: tcl
# time-stamp-format: "%u %02d.%02m.%y %02H:%02M:%02S %s"
# End:
############################################################
