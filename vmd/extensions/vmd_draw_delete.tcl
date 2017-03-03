# vmd extension procedure
#
# $Id: vmd_draw_delete.tcl,v 1.1 2005/01/03 14:06:39 akohlmey Exp $

# replace the default 'draw delete' with a multibple argument
# (which may even be lists) aware version
proc vmd_draw_delete {args} {
    set i 0
    foreach list $args {
        if {$i == 0} {
	    lassign $list mol
            incr i
        }
        if {$list == "all"} {
            graphics $mol delete all
	    return
        }
        foreach id $list {
            graphics $mol delete $id
        }
    }
    return
}

############################################################
# Local Variables:
# mode: tcl
# time-stamp-format: "%u %02d.%02m.%y %02H:%02M:%02S %s"
# End:
############################################################
