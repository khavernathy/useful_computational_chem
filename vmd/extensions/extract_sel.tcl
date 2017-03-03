# vmd tcl procedure: write the contents of a selection 
#                    to a pdb file with the atom coordinates
#                    shifted to the origin and suitable box dimensions
#                    (=min/max coordinates plus 1 angstrom on each side).
#
#                    the script produces an orthorhombic supercell.
#
# $Id: extract_sel.tcl,v 1.1 2005/01/03 14:06:39 akohlmey Exp $
#
# Copyright (c) 2004 by <Axel.Kohlmeyer@theochem.ruhr-uni-bochum.de>
#

proc extract_sel { sel pdbfile {addbox {2.0 2.0 2.0}} } {

set molid [$sel molid]

# save original box dimensions and selection coordinates
set origbox [molinfo $molid get {a b c alpha beta gamma}]
set origxyz [$sel get {x y z}]

# retrieve number of atoms and get the min/max coordinates from the selection
set minmax [measure minmax $sel]

# subtract the coordinates of the lower left front corner.
$sel moveby [vecscale -1.0 [lindex $minmax 0]]
# and shift by half the addbox vector to the middle
$sel moveby [vecscale 0.5 $addbox]

# box is the size of the selection plus the addbox vector
set box [vecsub [lindex $minmax 1] [lindex $minmax 0]]
set box [vecadd $addbox $box]

# update the box size so the pdbfile has that info
molinfo $molid set {a b c alpha beta gamma} "$box 90.0 90.0 90.0"

# write out the result
$sel writepdb "$pdbfile"

# undo the coordinate shifts from above:
$sel set {x y z} $origxyz
# and set the box back to the old values
molinfo $molid set {a b c alpha beta gamma} $origbox

}
    
