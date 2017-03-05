WIDTH, HEIGHT = 1200, 1600
import sys
import os
sys.path.insert(1, os.path.join(sys.path[0], '/home/d/dfranz/pythonxlib/python-xlib-0.15rc1')) # wherever python Xlib is installed. This is my CIRCE path. Install from: https://sourceforge.net/projects/python-xlib/?source=typ_redirect
from Xlib import *
import Xlib.display

display = Xlib.display.Display()  # triggers a print but honey badger don't care
root = display.screen().root


# TO CHANGE THE CURRENT WINDOW SIZE (i.e. the terminal window)
def resize_all():
    windowID = root.get_full_property(display.intern_atom('_NET_ACTIVE_WINDOW'), Xlib.X.AnyPropertyType).value[0]
    window = display.create_resource_object('window', windowID)
    window.configure(width = WIDTH, height = HEIGHT)
    display.sync()

# TO CHANGE OTHER WINDOWS
def resize_grace( ):
    windowIDs = root.get_full_property(display.intern_atom('_NET_CLIENT_LIST'), Xlib.X.AnyPropertyType).value
    for windowID in windowIDs:
        window = display.create_resource_object('window', windowID)
        name = window.get_wm_name() # Title
        pid = window.get_full_property(display.intern_atom('_NET_WM_PID'), Xlib.X.AnyPropertyType) # PID
        #print pid
        #print windowID
        if "Grace" in name:
            #print name
            window.configure(width = WIDTH, height = HEIGHT) # for whatever reason, width and height are backwards but i don't care
            display.sync()


resize_grace()
