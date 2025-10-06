#
#                    Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
#
# This example shows simple usage of a VST plugins 'routing'. This example
# is described in the manual in the chapter 'I/O-configuration of
# VST-plugins'
# NOTE: you will need a soundcard with four channels at least to run this
# example!
#
# SoundMexPro commands introduced in this example:
#   vstload


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
# NOTE: flag 0 will remove inputs, returned dictionary will hold driver and output only, 
# i.e. suitable for 'init' directly
smp_cfg = smp_get_cfg(0)
# init with first four outputs: may fail, if driver has not four channels!
smp_cfg['output'] = [0, 1, 2, 3]
soundmexpro('init', smp_cfg)    

# show visualization
soundmexpro('show')

# load four different sine signals to the four tracks
soundmexpro('loadfile',                         # command name
            {
            'filename' : '../waves/300Hz.wav',  # filename
            'track' : 0,                        # track 
            'loopcount' : 3                     # loop count
            }
)

soundmexpro('loadfile',                         # command name
            {
            'filename' : '../waves/400Hz.wav',  # filename
            'track' : 1,                        # track 
            'loopcount' : 3                     # loop count
            }
)

soundmexpro('loadfile',                         # command name
            {
            'filename' : '../waves/500Hz.wav',  # filename
            'track' : 2,                        # track 
            'loopcount' : 3                     # loop count
            }
)

soundmexpro('loadfile',                         # command name
            {
            'filename' : '../waves/600Hz.wav',  # filename
            'track' : 3,                        # track 
            'loopcount' : 3                     # loop count
            }
)

# switch on debug saving for all channels
soundmexpro('debugsave', {'value' : 1})

# load plugin (routed as in description of this example in the manual). 
# NOTE: this example is only intended to demonstrate the I/O-configuration
# (routing) of VST plugins. No gains are applied, the plugin here is
# 'abused' as some kind of audio mixer. See tutorial 't_09c_vst_gain.m' for
# using the gain parameters of this plugin!
soundmexpro('vstload',                              # command name
            {
            'filename' : '..\plugins\HtVSTGain.dll',# filename of plugin binary
            'type' : 'track',                       # plugin type, here: track plugin
            'input' : [0, 3],                       # tracks to read data from
            'output' : [1, 2]                       # tracks to write processed data to
            }
)

# This routing of inputs and outputs will lead to 
#  track 0: silence 
#  track 1: sum of 300Hz (through plugin from track 0) and a 400Hz (originally in track1)
#  track 2: sum of 600Hz (through plugin from track 3) and a 500Hz (originally in track2)
#  track 3: silence 
soundmexpro('start')

# and wait for it to be complete
soundmexpro('wait', {'mode' : 'stop'})
    
print('done. You may check the debug files out_0.wav ... out_3.wav to see what was played')

