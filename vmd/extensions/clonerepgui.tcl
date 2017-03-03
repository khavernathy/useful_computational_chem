# hello emacs this is -*- tcl -*-
#
# Small GUI control to clone a representation from one molecule to another.
# needs clone_reps.tcl installed.
# written 2004 by axel.kohlmeyer@theochem.ruhr-uni-bochum.de
# using concepts from other gui plugins distributed with VMD.
#
# updated versions may be available at:
# http://www.theochem.ruhr-uni-bochum.de/go/cpmd-vmd.html
#
# $Id: clonerepgui.tcl,v 1.1 2004/05/21 15:50:29 akohlmey Exp $
#
########################################################################
#
# create package and namespace and default all namespace global variables.
package provide clonerepgui 1.0

namespace eval ::CloneRep:: {
    namespace export clonerepgui

    variable w;                # handle to the base widget.

    variable fromid  "0";      # molid of the molecule to grab
    variable toid    "1";      # molid to clone the representations to
    
}

#################
# initialization.
# create main window layout
proc ::CloneRep::clonerepgui {} {
    variable w
    variable fromid 
    variable toid 

    # main window frame
    set w .clonerepgui
    catch {destroy $w}
    toplevel    $w
    wm title    $w "Clone Representations" 
    wm iconname $w "CloneRep" 
    wm minsize  $w 200 0

    # 
    frame $w.title
    frame $w.from
    frame $w.to
    frame $w.foot

    #
    label $w.title.l -text "Clone Representation:" -anchor w
    pack $w.title.l -side top

    # from selector
    frame $w.from.mol
    label $w.from.mol.l -text "From Molecule:" -anchor w
    menubutton $w.from.mol.m -relief raised -bd 2 -direction flush \
	-textvariable ::CloneRep::fromid \
	-menu $w.from.mol.m.menu
    menu $w.from.mol.m.menu 
    pack $w.from.mol.l -side left
    pack $w.from.mol.m -side right
    pack $w.from.mol -side top
    pack $w.from -side left

    # from selector
    frame $w.to.mol
    label $w.to.mol.l -text "To Molecule:" -anchor w
    menubutton $w.to.mol.m -relief raised -bd 2 -direction flush \
	-textvariable ::CloneRep::toid \
	-menu $w.to.mol.m.menu
    menu $w.to.mol.m.menu 

    pack $w.to.mol.l -side left
    pack $w.to.mol.m -side right
    pack $w.to.mol -side top
    pack $w.to -side left

    button $w.foot.c -text Clone  -command [namespace code CloneRepDoClone]
    button $w.foot.u -text Update -command [namespace code CloneRepUpdateMolecules]
    button $w.foot.d -text Dismiss -command "menu clonerepgui off"
    pack $w.foot.c -side left
    pack $w.foot.u -side left
    pack $w.foot.d -side left
    pack $w.foot -side bottom
    grid columnconfigure $w.foot 0 -weight 2 -minsize 10
    grid columnconfigure $w.foot 1 -weight 2 -minsize 10
    grid columnconfigure $w.foot 2 -weight 2 -minsize 10

    grid config $w.foot.c -column 0 -row 0 -columnspan 1 -rowspan 1 -sticky "snew"
    grid config $w.foot.u -column 1 -row 0 -columnspan 1 -rowspan 1 -sticky "snew"
    grid config $w.foot.d -column 2 -row 0 -columnspan 1 -rowspan 1 -sticky "snew"

    # layout main canvas
    grid config $w.title -column 0 -row 0  -columnspan 2 -rowspan 1 -sticky "snew"
    grid config $w.from  -column 0 -row 1  -columnspan 1 -rowspan 1 -sticky "snew"
    grid config $w.to    -column 1 -row 1  -columnspan 1 -rowspan 1 -sticky "snew"
    grid config $w.foot  -column 0 -row 2  -columnspan 2 -rowspan 1 -sticky "snew"
    grid columnconfigure $w 0 -weight 2 -minsize 150
    grid columnconfigure $w 1 -weight 1 -minsize 150

    CloneRepUpdateMolecules
}

 
# callback for VMD menu entry
proc clonerepgui_tk_cb {} {
  ::CloneRep::clonerepgui
  return $::CloneRep::w
}

# update molecule list
proc ::CloneRep::CloneRepUpdateMolecules { args } {
  variable w
  variable fromid
  variable toid

  set mollist [molinfo list]
  
  # Update the molecule browser
  $w.from.mol.m.menu delete 0 end
  $w.from.mol.m configure -state disabled
  $w.to.mol.m.menu delete 0 end
  $w.to.mol.m configure -state disabled

  if { [llength $mollist] != 0 } {
    foreach id $mollist {
      if {[molinfo $id get filetype] != "graphics"} {

        $w.from.mol.m configure -state normal 
        $w.from.mol.m.menu add radiobutton -value $id \
	  -label "$id [molinfo $id get name]" \
	  -variable ::CloneRep::fromid 

        $w.to.mol.m configure -state normal 
        $w.to.mol.m.menu add radiobutton -value $id \
	  -label "$id [molinfo $id get name]" \
	  -variable ::CloneRep::toid 
      }
    }
  }
}

proc ::CloneRep::CloneRepDoClone { args } {
    variable fromid
    variable toid

    clone_reps $fromid $toid
}
