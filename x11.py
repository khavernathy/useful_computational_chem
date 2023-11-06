"""
testing X11 Forwarding.
 
Author: twillia2
Date: Fri Aug 26 08:59:12 MDT 2022
"""
import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
 
 
print(f"FILE: {mpl.__file__}, version: {mpl.__version__}")
print(f"BACKEND: {mpl.get_backend()}")
print(F"CONFIG: {mpl.matplotlib_fname()}")
 
 
x = np.arange(-550, 550, 1)
y = x * (x + 2) * ((x - 3) ** 3)
 
plt.plot(x, y)
plt.plot(x, -y)
plt.plot(0.1 * x, -y)
plt.plot(-0.1 * x, -y)
 
plt.show()

