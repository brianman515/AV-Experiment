#
#                    Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
#
# This example usage of the command 'adm' for ASIO Direct Monitoring (ADM).
# NOTE: This example will only run properly if the soundcard/driver that is
# used supports ADM
#
# SoundMexPro commands introduced in this example:
#   adm

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

print('Mapping input channel 0 to output channel 0, pan "middle" (may be played on channels 0 and 1)')
# set input 0 to gain 0dB, pan in the middle and monitored by output
# channel 0
soundmexpro('adm',              # command name
            {
            'input' : 0,        # input channel to map
            'output' : 0,       # utput channel use for monitoring input channel
            'gain' : 536870912, # gain (hex 0x20000000)
            'pan' : 1073741823, # pan (hex 0x7fffffff/2, i.e. middle position)
            'mode' : 1          # switch mapping 'on', i.e. connect input 0 to output 2
            }
)

# if any input is connected now, you should 'see' that it is played as well
# on the visualization 
input('Hit a key to quit example')


