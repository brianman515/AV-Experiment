#
#                    Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
#
# This example shows how to do direct 'io', i.e. recording audio from the
# soundcard and do direct playback of these recorded data. This is
# especially interesting when processing the data between recording and
# playback e.g. with the MATLAB script based DSP interface of SoundMexPro
# (not done here, see DSP examples). 
# NOTE: to get this example running you have to connect any audio input to
# the first two input channels of your soundcard (to have a recording
# source). The recorded data then are added to the first two tracks
# (connnected to the first two output channels) in switched order.
# Additional data are played on first track to show the feature of 'adding'
# the reorded input to 'regular' output data.
#
# SoundMexPro commands introduced in this example:
#   iostatus
#
# Required Python libraries that are not part of the standard library
#   - numpy
#   - soundfile

import sys
import os
import time
import numpy
import soundfile

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

# set IO-mapping: connect input channel 0 with output channel 1 
# and vice versa
soundmexpro('iostatus',     # command name
            {
            'track' : 1,    # tracks to map input to
            'input' : 0     # input channel to map
            }
)
soundmexpro('iostatus',     # command name
            {
            'track' : 0,    # tracks to map input to
            'input' : 1     # input channel to map
            }
)


# disable 'regular' recording to file. NOTE: the regular files rec_?.wav
# are created anyway, but stay empty
soundmexpro('recpause', {'value' : 1})

# lower channel volumes to avoid clipping
soundmexpro('volume', {'value' : 0.5})
        

# read additional data to play and scale them down
wavdata, samplerate = soundfile.read('../waves/eurovision.wav')
# IMPORTANT NOTE: reading waves to memory with python creates interleaved data in memory, bit_length
# soundmexpro needs non-interleaved data: so force rearranging in memory!!
wavdata = numpy.asfortranarray(wavdata) * 0.1

# play mem on first track
soundmexpro('loadmem',          # command name
            {
            'data' : wavdata[:,0],    # data (here: only first channel)
            'track' : 0,              # tracks, here 0 
            'loopcount' : 2           # loopcount
            }
)


# start playback and I/O in mode 'play-zeros-if-empty'
soundmexpro('start', {'length' : 0}) # length, here 0: play zeros

# if any input is connected now, you should 'see' that it is played as well
# on the visualization 
input('Hit a key to quit example')
soundmexpro('exit')
os.remove('rec_0.wav')
os.remove('rec_1.wav')



