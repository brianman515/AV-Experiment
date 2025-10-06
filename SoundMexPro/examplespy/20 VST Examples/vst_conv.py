#
#                    Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
# This example shows the usage of the convolution plugin HtVSTConv.dll

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
# with numbufs = 0 (minium delay!)
smp_cfg['numbufs'] = 0
# init with first two outputs
soundmexpro('init', smp_cfg)    

# show visualization
soundmexpro('show')


# load aufio file
soundmexpro('loadfile',                 # command name
            {
            'filename' : '../../waves/eurovision.wav',  # filename
            'loopcount' : 0                             # endless loop 
            }
)

# lower volume to avoid clipping
soundmexpro('volume', {'value' : 0.1})
    

# load the plugin
soundmexpro('vstload',                   # command name
            {
            'filename' : '../../plugins/HtVSTConv.dll', # plugin name
            'input' : [0, 1],                           # inputs to use
            'output' : [0, 1]                           # outputs to use
            }
)

# load an impulse response
soundmexpro('vstprogramname', {'programname' : '..\..\plugins\ir.wav'})

# call plugin's editor (you may change gain and enable/disable plugin
soundmexpro('vstedit')

# go!
soundmexpro('start')

input('hit Enter to quit example')


