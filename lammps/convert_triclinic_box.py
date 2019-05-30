import sys
from math import *

print "This program takes a, b, c, alpha, beta, gamma in that order"
print "And gives LAMMPS .data file style box definition"
print "This is the name of the script: ", sys.argv[0]
#print "Number of arguments: ", len(sys.argv)
#print "The arguments are: " , str(sys.argv)

pi = 3.1415927

a = float(sys.argv[1])
b = float(sys.argv[2])
c = float(sys.argv[3])
alpha = float(sys.argv[4])*pi/180.
beta = float(sys.argv[5])*pi/180.
gamma = float(sys.argv[6])*pi/180.

lx = a
xy = b*cos(gamma)
xz = c*cos(beta)
ly = sqrt(b*b - xy*xy)
yz = (b*c*cos(alpha) - xy*xz)/ly
lz = sqrt(c*c - xz*xz - yz*yz)

print "lx, ly, lz: ", lx,ly,lz

##### close-to-zero as zero
if (abs(xy) < 1e-6):
    xy = 0
if (abs(xz) < 1e-6):
    xz = 0
if (abs(yz) < 1e-6):
    yz = 0

# abcalphabetagamma -> box vectors
A0 = a
A1 = b*cos(gamma)
A2 = c*cos(beta)

B0 = 0
B1 = b*sin(gamma)
B2 = ( (b*c*cos(alpha) ) - (A1*A2) )/B1

C0 = 0
C1 = 0
C2 = sqrt(c*c - A2*A2 - B2*B2)

##  transpose
t = [ [A0,B0,C0], [A1,B1,C1], [A2,B2,C2] ]
#t = [ [A0,A1,A2], [B0,B1,B2], [C0,C1,C2]  ]

# box vertices
count=0
box_occupancy = [0,0,0]
box_pos = [0,0,0]
box_vertices = [ [0,0,0], [0,0,0], [0,0,0], [0,0,0], [0,0,0], [0,0,0], [0,0,0], [0,0,0] ]
for i in range(2): 
    for j in range(2):
        for k in range(2):
            box_occupancy[0] = float(i) - 0.5
            box_occupancy[1] = float(j) - 0.5
            box_occupancy[2] = float(k) - 0.5

            for p in range(3):
                box_pos[p] = 0
                for q in range(3):
                    box_pos[p] += t[q][p] * box_occupancy[q]

            for n in range(3):
                box_vertices[count][n] = box_pos[n]

            count += 1

#print "box vertices"
#for i in range(8):
#        print box_vertices[i][0], box_vertices[i][1], box_vertices[i][2]

x_length = box_vertices[5][0] - box_vertices[1][0]
y_length = box_vertices[3][1] - box_vertices[1][1]
z_length = box_vertices[1][2] - box_vertices[0][2]

xlo = -x_length/2.
xhi = x_length/2.
ylo = -y_length/2.
yhi = y_length/2.
zlo = -z_length/2.
zhi = z_length/2.

print ""; print ""
print xlo, xhi, "xlo xhi"
print ylo, yhi, "ylo yhi"
print zlo, zhi, "zlo zhi"
print xy,xz,yz, "xy xz yz"

