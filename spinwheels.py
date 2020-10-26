import numpy as np
import multiprocessing as mp

# hog some cpus 

N = 48

def spinboi(a):
    while True:
        x = np.random.random() * a

pool = mp.Pool(N)
result = pool.imap(spinboi, np.arange(N))
pool.close()
pool.join()
