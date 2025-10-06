#
#                    Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
# This example shows how to use a VST plugin to generate a sine
# tone and change frequency on the fly
#

import sys
import time
import tkinter as tk
import tkinter.font as font

# append path to SoundMexPro\bin
sys.path.append('..\\..\\bin')
# import soundmexpro
from soundmexpro import soundmexpro


root = tk.Tk()

# --- define functions and callbacks for the buttons of GUI ---
# function to set frequency within VST plugin
def set_frequency(value):
    soundmexpro('vstparam',        
                {
                'type' : 'track', 
                'parameter' : 'frequency',
                'value' : float(value)/22050
                }
    )
# -------------------------------------------------------------


# NOTE: other than in MATLAB/Octave SoundMexPro raises an error if a command fails, thus
# no need to check a return value after each SoundMexPro command. If you want to change 
# this behaviour please edit ..\bin\soundmexpro.py (look for AssertionError)

# read settings from tutorial
sys.path.append('..\\..\\tutorialpy')
from t_00b_init_tutorial import smp_get_cfg
# get config 
# NOTE: flag 0 will remove inputs, returned dictionary will hold driver and output only, 
# i.e. suitable for 'init' directly
smp_cfg = smp_get_cfg(0)
# init with first two outputs
soundmexpro('init', smp_cfg)    


# load the plugin to first track only
soundmexpro('vstload',                   # command name
            {
            'filename' : '../../plugins/HtVSTSine.dll', # plugin name
            'type' : 'track',                           # type of plugin
            'input' : [0],                              # inputs to use
            'output' : [0]                              # outputs to use
            }
)

# lower volume 
soundmexpro('volume', {'value' : 0.1})

soundmexpro('show')
soundmexpro('start', {'length' : 0})     # play zeros endlessly, plugin will generated sine

# create the GUI
myFont = font.Font(family='Helvetica', size=16)
label1 = tk.Label(root, height=2, width=50, font=myFont, text='Move the slider to change the frequency')
label1.pack()
# slider with frequencies from 100 to 500 Hz
w = tk.Scale(root, from_=100, to=500, width=50, length=500, orient=tk.HORIZONTAL, font=myFont, command=set_frequency)
w.set(440)
w.pack()
btn1 = tk.Button(root, text="Quit", height=2, width=50, font=myFont, command=root.destroy)
btn1.pack()

root.mainloop()



