# vmd tcl procedure: source a (list of) file(s), but from a
#                    subroutine, so there is no output of return values.
#
# $Id: source_silent.tcl,v 1.1 2005/01/04 08:47:16 akohlmey Exp $
#
# Copyright (c) 2004-2005 by <Axel.Kohlmeyer@theochem.ruhr-uni-bochum.de>
#

proc source_silent {args} {
    foreach f $args {
        source $f
    }
}

# now read in your vmd script(s) with
# source_silent script1.tcl script2.tcl ...

############################################################
# Local Variables:
# mode: tcl
# time-stamp-format: "%u %02d.%02m.%y %02H:%02M:%02S %s"
# End:
############################################################
