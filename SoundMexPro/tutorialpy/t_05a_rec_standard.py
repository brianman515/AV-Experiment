#
#                    Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
# The examples named t_05????? show how to record wave data with SoundMexPro.
# Starting with a simple recording task the examples become
# more sophisticted using threshold recording and online 'grabbing' of
# recorded data into the Python workspace.
# NOTE: It is recommended to connect the first two output channels with the
# first two input channels with a shortcut cable to run these examples.
# You may also use other channels by setting global variables (see below)
#
# This example shows recording on two channels with user defined filename
# and pausing one of the channels durcing recording.
#
# SoundMexPro commands introduced in this example:
#   recording
#   recposition
#   recfilename
#   recpause
#   clipcount (for recorded data)
#
# Required Python libraries that are not part of the standard library
#   - numpy
#   - soundfile
#   - matplotlib

import sys
import os
import time
import numpy
import soundfile
import matplotlib.pyplot as plt 

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
# init with two outputs and two inputs, 4 tracks
smp_cfg['track'] = 4
soundmexpro('init', smp_cfg)    

soundmexpro('show')    

# set filename of recording of first channel to other than default and
# print both resulting filenames
retvals = soundmexpro(  'recfilename',               # command name
                        {
                        'filename' : 'myrecfile.wav', # new filename 
                        'channel' : 0                 # channel to set filename
                        }
)
print('The recording filenames are:')
for filename in retvals['value']:
    print(filename)

# lower volume to avoid clipping when adding waves
soundmexpro('volume', {'value' : 0.1})    

# load a noise file. 
soundmexpro('loadfile',                             # command name
            {
            'filename' : '../waves/noise_16bit.wav',# name of wavefile
            'track' : [0, 1],                       # play on first two tracks (both channels)
            'loopcount' : 0                         # endless loop
            }
)
# load a 'stimulus' with an offset of 2 sec. to next two tracks
soundmexpro('loadfile',                             # command name
            {
            'filename' : '../waves/3sine_16bit.wav',# name of wavefile
            'track' : [2, 3],                       # play on last two tracks (both channels)
            'offset' : 88200                        # offset in samples
            }
)

# start device
soundmexpro('start')

# now show, that both channels are recording at the moment
retvals = soundmexpro('recording')
print('First channel does record to file: {}, second channel does record to file: {}'.format(retvals['value'][0], retvals['value'][1]))


# wait until 'mixing' has ended (playback on tracks 2 and 3)
while 1:
    retvals = soundmexpro('playing')
    # then check the last two tracks (NOTE: vector is 1-based!)
    if (max(retvals['value'][2:3]) == 0):
        break    
    time.sleep(0.05)
    
# show identical recpositions (recorded lengths) of the two channels
retvals = soundmexpro('recposition')
print('samples recorded on first channel: {}, second channel: {}'.format(retvals['value'][0], retvals['value'][1]))

# after mixing, we disable recording of first channel again
soundmexpro('recpause',     # command name
            {
            'value' : 1,    # value to set (1 is pause, 0 is resume)
            'channel' : 0   # channel to apply value to
            }
)

# wait again
time.sleep(1)

# now show, that only second channels is recording at the moment
retvals = soundmexpro('recording')
print('First channel does record to file: {}, second channel does record to file: {}'.format(retvals['value'][0], retvals['value'][1]))

# show now different recpositions (recorded lengths) of the two channels
retvals = soundmexpro('recposition')
print('samples recorded on first channel: {}, second channel: {}'.format(retvals['value'][0], retvals['value'][1]))


# check, if we had clippings on input (depends on your hardware: change
# your input sensitivity to force clipping). NOTE: SoundMexPro defines
# 'clipping' on the input as two subsequent samples that contain 1 (or -1
# respectively).
retvals = soundmexpro('clipcount')
print('Clipped input buffers on first channel: {}, on second channel: {}'.format(retvals['input'][0], retvals['input'][1]))

input('Hit a key to continue')
soundmexpro('exit')

x, samplerate = soundfile.read('myrecfile.wav')
y, samplerate = soundfile.read('rec_1.wav')

os.remove('myrecfile.wav')
os.remove('rec_1.wav')

# show a plot 
plt.plot(x, color = 'b', linewidth = '0.5')
plt.plot(y, color = 'r', linewidth = '0.5')
plt.show()





