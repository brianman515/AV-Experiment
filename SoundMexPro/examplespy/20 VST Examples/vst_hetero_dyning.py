#
#                    Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
# This example shows the usage of the VST hetero-dyning plugin HtVSTHeteroDyning.dll

import sys
import time

# append path to SoundMexPro\bin
sys.path.append('..\\..\\bin')
# import soundmexpro
from soundmexpro import soundmexpro

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

# set hetero-dyning frequencies of first two channels and disable filter
# within one command
# NOTE: frequencies are fractions of samplerate. We set first channel to 4
# Hz (more a modulation) and second to 400 Hz
soundmexpro('vstload',                   # command name
            {
            'filename' : '../../plugins/HtVSTHeteroDyning.dll', # plugin name
            'input' : [0, 1],                           # inputs to use
            'output' : [0, 1],                          # outputs to use
            'type' : 'master',                          # plugin type
            'position' : 0                             # plugin position
            }
)

# set hetero-dyning frequencies of first two channels and disable filter
# within one command
# NOTE: frequencies are fractions of samplerate. We set first channel to 4
# Hz (more a modulation) and second to 400 Hz
soundmexpro('vstparam',                                  # command name
            {
            'parameter' : ['enabled', 'frequency_0', 'frequency_1'],# parameter names
            'value' : [0, 4/44100, 400/44100]                         # parameter values
            }
)

# load audio file
soundmexpro('loadfile',                 # command name
            {
            'filename' : '../../waves/eurovision.wav',  # filename
            'loopcount' : 0                             # endless loop 
            }
)

# go
soundmexpro('start')

# wait a bit
time.sleep(4)

# enable filter
soundmexpro('vstparam',             # command name
        {
        'parameter' :'enabled',     # parameter names
        'value' : 1                 # parameter values
        }
)

time.sleep(4)