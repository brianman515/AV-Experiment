#
#                    Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
# This example shows how play a noise and a sine in mixing mode and adjust
# the SNR online using a slider
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
# function to set frequency within VT plugin
def set_snr(value):
    soundmexpro('trackvolume',        
                {
                'track' : [2, 3], 
                'value' : 10**(float(value)/20)
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
smp_cfg["track"] = 4
# init with first two outputs, four tracks
soundmexpro('init', smp_cfg)    


# load noise with loadfile in endless loop to first two tracks
soundmexpro('loadfile',                   # command name
            {
            'filename' : '../../waves/noise_16bit.wav', # wavefile name
            'track' : [0, 1],                           # tracks were to play file
            'loopcount' : 0                             # endless loop
            }
)

# load signal 'mixing' file in endless loop to next tracks
soundmexpro('loadfile',                   # command name
            {
            'filename' : '../../waves/sine.wav',        # wavefile name
            'track' : [2, 3],                           # tracks were to play file
            'loopcount' : 0                             # endless loop
            }
)


# set 'master' volume to -10 dB to have headroom for raising trackvolumes below
soundmexpro('volume', {'value' : 10**(-10/20)})
        
# set noise tracks to -10 dB 
soundmexpro('trackvolume', {'track' : [0, 1], 'value' : 10**(-10/20)})

soundmexpro('show')
soundmexpro('start', {'length' : 0})     # play zeros endlessly

# create the GUI
myFont = font.Font(family='Helvetica', size=16)
label1 = tk.Label(root, height=2, width=50, font=myFont, text='Move the slider to change SNR')
label1['font'] = myFont
label1.pack()
# slider with SNR from -10 to +10 dB
w = tk.Scale(root, from_=-10, to=10, width=50, length=500, orient=tk.HORIZONTAL, font=myFont, command=set_snr)
w.set(0)
w.pack()
btn1 = tk.Button(root, text="Quit", height=2, width=50, font=myFont, command=root.destroy)

# btn1['font'] = myFont
btn1.pack()

root.mainloop()



