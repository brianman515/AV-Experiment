#
#                    Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
# This example shows how do a pair comparison for two audio files. The files
# contain the same sound, one of them bandpass filtered. On switching between
# the two alternatives a cross fade between the two files is done while
# playback continues.
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
# function to switch between tracks [0,1] and [2,3] with a ramp
def play_alternative(value):
    global root
    # disable all buttons for the time the ramp is applied
    for child in root.winfo_children():
        child.configure(state="disabled")
    # force gui update
    root.update()
    # set all four track volumes to 'mute' one of the alternatives
    # and unmute the other with a ramp of 1 second (crossfade)
    soundmexpro('trackvolume',        
                {
                'track' : [0, 1, 2, 3], 
                'value' : [abs(value-1), abs(value-1), value, value], 
                'ramplen' : 44100 
                }
    )
    # enable all buttons again
    for child in root.winfo_children():
        child.configure(state="normal")

# function to switch to tracks [0,1]
def play_alternative_0():
    play_alternative(0)
# function to switch to tracks [2,3]
def play_alternative_1():
    play_alternative(1)
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
# use 4 tracks
smp_cfg['track'] = 4
# init with first two outputs
soundmexpro('init', smp_cfg)    


# load first wave with loadfile in endless loop to first two tracks
soundmexpro('loadfile',                 # command name
            {
            'filename' : '../../waves/eurovision.wav',  # filename
            'track' : [0, 1],                           # tracks to load wave to
            'loopcount' : 0                             # endless loop 
            }
)

# then load second wave with mixfile in endless loop to next tracks
soundmexpro('loadfile',                 # command name
            {
            'filename' : '../../waves/euro_tel.wav',  # filename
            'track' : [2, 3],                           # tracks to load wave to
            'loopcount' : 0                             # endless loop 
            }
)

# set initial track volumes of tracks 2 and 3 to 0 (only first altenative audible)
soundmexpro('trackvolume',        
            {
            'track' : [2, 3], 
            'value' : 0
            }
)            

soundmexpro('show')
soundmexpro('start')

# create the GUI
myFont = font.Font(family='Helvetica', size=16)
label1 = tk.Label(root, width=50, font=myFont, text='Press "Play 1" and "Play2" to switch, "Done" to quit')
btn1 = tk.Button(root, text="Play 1", height=4, width=20, font=myFont, command=play_alternative_0)
btn2 = tk.Button(root, text="Play 2", height=4, width=20, font=myFont, command=play_alternative_1)
btn3 = tk.Button(root, text="Done", height=2, width=50, font=myFont, command=root.destroy)

# put them in a grid
label1.grid(row=0, column=0, columnspan=2, pady=10, )
btn1.grid(row=1, column=0)
btn2.grid(row=1, column=1)
btn3.grid(row=2, column=0, columnspan=2, pady=10, padx=10)

root.mainloop()

# after we are done check which alternative had volume 'up' on 'done': 
# this was the selected one when pressing "done"
retvals = soundmexpro('trackvolume')

# check if track volume of first track is '1'
if retvals['value'][0]  == 1:
    print('alternative 1 was playing when pressing "done"')
else:
    print('alternative 2 was playing when pressing "done"')






