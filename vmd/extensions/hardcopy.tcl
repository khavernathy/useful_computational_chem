# vmd tcl procedure: implement a high quality screen hardcopy 
# by rendering to a temporary file using internal tachyon, converting to
# postscript and sending the result to the printer.
#
# Copyright (c) 2004 by <Axel.Kohlmeyer@theochem.ruhr-uni-bochum.de>
# $Id: hardcopy.tcl,v 1.1 2004/05/16 17:54:14 akohlmey Exp $
 
proc hardcopy { {printer "ps"} {renderer "TachyonInternal"}} {

    # set the background temporarily to white to save ink and money.
    set oldbg [colorinfo category Display Background]
    color Display Background white

    set tga {/tmp/.hardcopy.tga}
    set ps  {/tmp/.hardcopy.ps}
    render $renderer $tga
    exec convert $tga $ps
    exec lpr -P$printer $ps
    exec rm -f $tga $ps
    color Display Background $oldbg
}

