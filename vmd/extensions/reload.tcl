# vmd tcl procedure: reload the last trajectory data set 
#                    for the current top molecule. 
#
# $Id: reload.tcl,v 1.2 2005/01/03 14:06:39 akohlmey Exp $
#
# Copyright (c) 2004-2005 by <Axel.Kohlmeyer@theochem.ruhr-uni-bochum.de>
#
# TODO: - add some flags to handle more than one molecule
#       - store the last data set index somewhere globally,
#         so that this would also work for multple files
#       - support arguments for selecting molecules and
#         trajectory data files.

proc reload {args} {
    lassign $args arg1 arg2

    set viewpoints {}
    set mol [molinfo top]

    # save orientation and zoom parameters
    set viewpoints [molinfo $mol get { 
        center_matrix rotate_matrix scale_matrix global_matrix}]
    
    # delete all coordinates and (re)load the latest data set.
    animate delete all
    set files [lindex [molinfo $mol get filename] 0]
    set lf [expr [llength $files] - 1]

    if {$arg1 == "waitfor"} {
        mol addfile [lindex $files $lf] \
            type [lindex [lindex [molinfo $mol get filetype] 0] $lf] $arg1 $arg2
    } else {
        mol addfile [lindex $files $lf] \
            type [lindex [lindex [molinfo $mol get filetype] 0] $lf]
    }

    # restore orientation and zoom
    molinfo $mol set {center_matrix rotate_matrix scale_matrix global_matrix} $viewpoints
}

############################################################
# Local Variables:
# mode: tcl
# time-stamp-format: "%u %02d.%02m.%y %02H:%02M:%02S %s"
# End:
############################################################
