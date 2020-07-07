# box
pbc set {8.134292 9.818878 36.410077 90 90 90} -all
pbc box -center bb
pbc box -style lines
pbc box -width 6
pbc box -color black

# fix window size etc
display resize 600 600
display projection orthographic
display nearclip set 0.0000000001
axes location off

mol modstyle 0 0 lines 4

# VDW for non-waters
mol addrep 0
mol modselect 1 0 "index < 80 or index > 139"
mol modstyle 1 0 vdw 0.7 100
mol modmaterial 1 0 AOShiny

# Ca = silver
mol addrep 0
mol modselect 2 0 "(index < 80 or index > 139) and name Ca"
mol modstyle 2 0 vdw 0.7 100
mol modcolor 2 0 colorid 6
mol modmaterial 2 0 AOShiny

# Cl = green
mol addrep 0
mol modselect 3 0 "(index < 80 or index > 139) and name Cl"
mol modstyle 3 0 vdw 0.7 100
mol modcolor 3 0 colorid 7
mol modmaterial 3 0 AOShiny

# Mg = orange
mol addrep 0
mol modselect 4 0 "(index < 80 or index > 139) and name Mg"
mol modstyle 4 0 vdw 0.7 100
mol modcolor 4 0 colorid 3
mol modmaterial 4 0 AOShiny

# rotate for top-down pic
rotate y by 180
rotate z by 90
scale by 2.8
rotate x by 1
rotate y by 1
render snapshot ca_top.tga

# rotate for side pic
rotate x by -1
rotate y by -1
display resize 600 800
rotate x by -90
scale by 0.35714286
scale by 1.7
render snapshot ca_side.tga
