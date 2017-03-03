# hello emacs this is -*- tcl -*-
#
# clone the set of representations to another molecule.
#
# (optional) arguments are the molecule ids of the source the target molecule.
#
# written 2004 by axel.kohlmeyer@theochem.ruhr-uni-bochum.de,
# inspired by save_state.
#
# $Id: clone_reps.tcl,v 1.1 2004/05/21 15:50:29 akohlmey Exp $
#
########################################################################

proc clone_reps {{fromid 0} {toid 1}} {

    # check arguments
    if {$fromid == $toid} {
        puts "cannot clone a representation on itself"
        return
    }
    if { [lsearch -exact [molinfo list] $fromid] < 0} {
        puts "source molecule id $fromid does not exist"
        return
    }
    if { [lsearch -exact [molinfo list] $toid] < 0} {
        puts "target molecule id $toid does not exist"
        return
    }

    # clean reps on target
    for {set i 0} {$i < [molinfo $toid get numreps]} {incr i} {
        mol delrep $i $toid
    }

    # copy reps from source. store the current topmol first.
    set topmol [molinfo top]
    mol top $toid
    for {set i 0} {$i < [molinfo $fromid get numreps]} {incr i} {

        # gather info about the representation
        lassign [molinfo $fromid get "{rep $i}"] rep
        set sel    [molinfo $fromid get "{selection $i}"]
        set col    [molinfo $fromid get "{color $i}"]
        set mat    [molinfo $fromid get "{material $i}"]
        set pbc    [mol showperiodic $fromid $i]
        set numpbc [mol numperiodic $fromid $i]
        set on     [mol showrep $fromid $i]
        set selupd [mol selupdate $i $fromid]
        set colupd [mol colupdate $i $fromid]
        set colminmax [mol scaleminmax $fromid $i]
        set smooth [mol smoothrep $fromid $i]
        set framespec [mol drawframes $fromid $i]

        # clone representation
        mol representation $rep
        mol color $col
        mol selection "{$sel}"
        mol material $mat
        mol addrep top
        if {[string length $pbc]} {
            mol showperiodic top $i $pbc
            mol numperiodic  top $i $numpbc
        }
        mol selupdate $i top $selupd
        mol colupdate $i top $colupd
        mol scaleminmax top $i [lindex $colminmax 0] [lindex $colminmax 1]
        mol smoothrep top $i $smooth
        mol drawframes top $i "$framespec"
        if { !$on } {
            mol showrep top $i 0
        }

    }
    # restore old top molecule.
    mol top $topmol
}
