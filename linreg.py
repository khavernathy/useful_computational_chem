from math import *
import numpy as np
import sys
import os

# this will output the slope, intercept, and R^2 of a 2-column x|y data file

if (os.stat(sys.argv[1]).st_size == 0):
    print "empty file"
    sys.exit(0)

data = np.genfromtxt(sys.argv[1])  # 'qst_analysis/c2h6_lnP_invT_N_0.15')

if (data.size < 5):   # 4 size here means 2x2
    print "empty (less than 3 vals"
    sys.exit(0)

invT = data[:,0]
lnP = data[:,1]

xy = np.column_stack((invT,lnP))

avgx=0
avgy=0
intc=0
slope=0

sumx=0
sumy=0
cx=0
cy=0

topsum=0
botsum=0
othersum=0

regss=0
totss=0
r2=0

for i in xy:
    x=i[0]; y=i[1]
    sumx += x
    sumy += y
    cx += 1
    cy += 1

avgx = sumx/cx
avgy = sumy/cy

for i in xy:
    x=i[0]; y=i[1];
    topsum += (y-avgy)*(x-avgx)
    botsum += (x-avgx)*(x-avgx)
    othersum += (y-avgy)*(y-avgy)
    

slope = topsum/botsum
intc = avgy - slope*avgx

regss = topsum*topsum/botsum
totss = othersum
r2 = regss/totss

print slope,intc,r2



