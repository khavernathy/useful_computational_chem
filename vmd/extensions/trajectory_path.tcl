proc trajectory_path {selection {color blue} {update 0} {linewidth 1}} {

    # save the current selection frame number
    set sel_frame [$selection frame]
    # molecule to draw graphics into
    set gr_mol [$selection molindex]
    # make the list of coordinates
    set num_frames [molinfo $gr_mol get numframes]
    set coords {}
    for {set i 0} {$i < $num_frames} {incr i} {
        $selection frame $i
        if {$update} { $selection update }
        # compute the center of mass and save it on the list
        lappend coords [measure center $selection weight mass]
    }

    ##### now make the graphics
    set gr_list {}
    set coords [lassign $coords prev]

    # use the color scale?
    if {$color == "scale"} {
        set count 0
        incr num_frames
        foreach coord $coords {
            set color [expr 17 + int(1024 * ($count + 0.0) / ($num_frames + 0.0))]
            graphics $gr_mol color $color
            lappend gr_list [graphics $gr_mol line $prev $coord width $linewidth]
            set prev $coord
            incr count
        }
    } else {
        # constant color
        graphics $gr_mol color $color
        foreach coord $coords {
            lappend gr_list [graphics $gr_mol line $prev $coord width $linewidth]
            set prev $coord
        }
    }

    # return the selection to its original state
    $selection frame $sel_frame
    return $gr_list
}

