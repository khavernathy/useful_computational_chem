# vmd extension procedures
#
# $Id: vmd_draw_prism.tcl,v 1.1 2005/01/03 14:06:39 akohlmey Exp $

# add a 'draw prism' command similar to triangle
# but with an optional width (i.e. a 'thick triangle').
proc vmd_draw_prism {mol v1 v2 v3 {w 0.1}} {

    # empty list to store graphics indices in. is used as
    # return value, so that they can be selectively deleted.
    set objs {}

    set norm  [veccross [vecsub $v1 $v2] [vecsub $v2 $v3]]
    set scale [expr 0.5 * $w * [veclength $norm]]

    # construct edge positions:
    set off [vecscale $scale $norm]
    set vt1 [vecadd $v1 $off]
    set vt2 [vecadd $v2 $off]
    set vt3 [vecadd $v3 $off]
    set vb1 [vecsub $v1 $off]
    set vb2 [vecsub $v2 $off]
    set vb3 [vecsub $v3 $off]

    lappend objs [graphics $mol triangle $vt1 $vt2 $vt3]
    lappend objs [graphics $mol triangle $vb1 $vb2 $vb3]

    lappend objs [graphics $mol triangle $vt1 $vt2 $vb2]
    lappend objs [graphics $mol triangle $vt1 $vb1 $vb2]

    lappend objs [graphics $mol triangle $vt1 $vt3 $vb3]
    lappend objs [graphics $mol triangle $vt1 $vb1 $vb3]

    lappend objs [graphics $mol triangle $vt2 $vt3 $vb3]
    lappend objs [graphics $mol triangle $vt2 $vb2 $vb3]

    return $objs
}

############################################################
# Local Variables:
# mode: tcl
# time-stamp-format: "%u %02d.%02m.%y %02H:%02M:%02S %s"
# End:
############################################################
