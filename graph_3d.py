from mpl_toolkits import mplot3d
import numpy as np
import matplotlib.pyplot as plt

fig = plt.figure()
ax = plt.axes(projection='3d')

data = np.loadtxt('graph.dat')

rho= data[:,0]
t = data[:,1]
p = data[:,2]

#ax.plot3D(t,p,rho, 'grey')
#ax.plot_wireframe(t,p,rho,color='black')
#ax.plot_surface(t,p,rho, rstride=1, cstride=1, cmap='viridis', edgecolor='none')
#ax.scatter(t,p,rho, c=rho,cmap='viridis', linewidth=0.5)
ax.plot_trisurf(t,p,rho, cmap='viridis', edgecolor='none')


ax.set_title('Density of benzene')
ax.set_xlabel('temp (K)')
ax.set_ylabel('press (atm)')
ax.set_zlabel('dens (g/L)?')

plt.show()

