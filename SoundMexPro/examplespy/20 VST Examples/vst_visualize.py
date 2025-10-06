
#                    Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
# This example shows the usage of the VST visualization plugin HtVSTVisualize.dll

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

# load visualization plugin to first channel with setting programname
# immediately (i.e. the inifile name to use)
soundmexpro('vstload',                   # command name
            {
            'filename' : '../../plugins/htvstvisualize.dll', # plugin name
            'input' : 0,                           # inputs to use
            'output' : 0,                          # outputs to use
            'type' : 'master',                          # plugin type
            'position' : 0,                             # plugin position
            'programname' : 'visualize.ini'                   # program name, which sets inifile name here
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

# hide visualization
soundmexpro('vstparam',             # command name
        {
        'parameter' :'visible',     # parameter names
        'value' : 0                 # parameter values
        }
)

time.sleep(2)



