#                    Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
#
# This example shows how to start SoundMexPro triggered by a threshold on 
# a recording channel
#
# NOTE: for this example it is mandatory to use a second soundcard, CD
# player or any other device to play some sound to exceed the threshold,
# i.e. you have to connect this additional device to the input channel used
# in the tutorial and start it at the time, where you like to exceed the
# threshold!!
#
# SoundMexPro commands introduced in this example:
#   startthreshold
# Required Python libraries that are not part of the standard library
#   - numpy


import sys
import time

# append path to SoundMexPro\bin
sys.path.append('..\\bin')
# import soundmexpro
from soundmexpro import soundmexpro

# NOTE: other than in MATLAB/Octave SoundMexPro raises an error if a command fails, thus
# no need to check a return value after each SoundMexPro command. If you want to change 
# this behaviour please edit ..\bin\soundmexpro.py (look for AssertionError)

# read settings for tutorial
from t_00b_init_tutorial import smp_get_cfg
# get config 
smp_cfg = smp_get_cfg(1)
# init with two outputs and wto inputs
soundmexpro('init', smp_cfg)    

# disable 'regular' recording to file. NOTE: the regular files rec_?.wav
# are created anyway, but stay empty
soundmexpro('recpause', {'value' : 1})

# show visualization
soundmexpro('show')

# load a playback file 
soundmexpro('loadfile', {'filename' : '../waves/eurovision.wav'})

# start device with 'starthreshold'
soundmexpro('startthreshold',   # command name
            {
            'value' : 0.2,      # threshold value (between 0 and 1)
            'mode' : 1,         # mode '1' (this is default): threshold to be exceeded in one channel 
            'channel' : 0       # channel to look at 
            }
)


# we wait, until device is started (with timeout)
t = time.time()
retvals = soundmexpro('started')

while retvals['value'] == 0:
    # check if device is started meanwhile (i.e. threshold exceeded)
    retvals = soundmexpro('started')    
    # check for timeout
    if time.time() - t > 10:
        raise ValueError('timeout occurred, example stopped (check cables)')
    
    time.sleep(0.1);

input('threshold exceeded! Hit a key to quit example')





