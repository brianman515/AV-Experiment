#
#                    Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
#
# This example shows how to start recording threshold driven and stop
# it automatically after x samples.
#
# NOTE: for this example it is mandatory to connect the first two output 
# channels with the first two input channels with a a shortcut cable.
# Otherwise no data will be present on A/D converter and the requested
# threshold is never exceeded. Furthermore you may have to adjust your
# analog input and output values accordingly, if the recorded values are
# not appropriate!
# You may also use other channels by setting global variables (see below)
#
# SoundMexPro commands introduced in this example:
#   recthreshold
#   reclength
#   recstarted
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
# init with two outputs and two inputs
soundmexpro('init', smp_cfg)    

soundmexpro('show')    

# load a file containing a sine with ascending amplitude on first channel. 
soundmexpro('loadfile', {'filename' : '../waves/envelope.wav'})

# set record length to 1 second 
soundmexpro('reclength', {'value' : 44100})
         

# set record threshold to 0.2
soundmexpro('recthreshold', # command name
            {
            'value' : 0.2,  # threshold value to be exceeded (between 0 and 1)
            'mode' : 1,     # mode '1' (this is default): threshold to be exceeded in one channel 
            'channel' : 0   # channel to look at 
            }
)

# start device
soundmexpro('start')
    
# we wait, until recording is started at all (with timeout)
t = time.time()
retvals = soundmexpro('recstarted')
while max(retvals['value']) == 0:
    # check if record is started now
    retvals = soundmexpro('recstarted')
    # check for timeout
    # check for timeout
    if time.time() - t > 10:
        raise ValueError('timeout occurred, example stopped (check cables)')
    time.sleep(0.1)

print('threshold exceeded!')

# now wait for recording (!) to be complete
value = 1;
while max(retvals['value']) == 0:
    # reaching this point, recording was started. 
    retvals = soundmexpro('recording')
    time.sleep(0.1)

print('recording done');

soundmexpro('exit')

# read and plot recorded data
x, samplerate = soundfile.read('rec_0.wav')
y, samplerate = soundfile.read('rec_1.wav')

os.remove('rec_0.wav')
os.remove('rec_1.wav')

plt.plot(x, color = 'b', linewidth = '0.5')
plt.plot(y, color = 'r', linewidth = '0.5')
plt.show()


