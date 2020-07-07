# python script to convert UFF (Rappe et al.) LJ epsilon and sigma values to MPMC units
from math import *
import numpy

def calcu(eps,sig):
	print "Epsilon: ",eps," --> ",(eps * (1.0/0.0019872041))
	print "Sigma: ",sig," --> ",(sig / (2.0**(1.0/6.0)))
	return "bye"

calcu(0.08,2.754)
