#           Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
# This is the first example of the SoundMexPro tutorial. The tutorial shows
# examples for all commands of SoundMexPro. It starts with basic commands
# and simple tasks becoming more complex in later examples. It is
# recommended to go through all examples in order to find out about the
# extremely flexible commands and their options and get used to the best
# way to solve your task with SoundMexPro. The tutorial does not contain
# very sophisticated examples with 'mixed' tasks, so you may not find a
# complete solution to your problem here. But after going through the
# tutorial you may have a look at the 'advanced' examples that use a
# variety of SoundMexPro features within one task.
#
# This first example shows the very basic commands.
# NOTE: this example shows some paramaters of 'init' command. Most
# other examples use default parameters only! 
#
# SoundMexPro commands introduced in this example:
#   help
#   license
#   init
#   trackmap
#   initialized
#   exit
#   version
#   show
#   hide
#
# Required Python libraries that are not part of the standard library
#   - numpy

import sys
import time
import numpy

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
# NOTE: flag 1 will keep inputs, returned dictionary will hold driver, inputs and output output, 
# i.e. suitable for 'init' directly
smp_cfg = smp_get_cfg(1)

# 1. helpa 
soundmexpro('helpa')
input("Above a command list is shown in alphabetical order. Hit Enter to continue")

# 2. help on specific command
soundmexpro('help', {'help' : 'volume'})
input("Above the online help for command 'volume' is shown. Hit Enter to continue")

# 3a. license (can be called before init)
retvals = soundmexpro('license')
print('')
print('You are running SoundMexPro major version {} with licence type: {} '.format(retvals['Version'], retvals['Ed']))

# 3b. init
print('')
print('initializing SoundMexPro')
# here we set up complete init dictionary by hand
init_cfg = {
    'driver' :      smp_cfg['driver'],          # enter a name here to load a driver by it's name
    'samplerate' :  44100,                      # samplerate to use (default is 44100)
    'numbufs' :     10,                         # number of software buffers used to avoid xruns (dropouts, default is 10)
    'output' :      smp_cfg['output'],          # list of output channels to use 
    'input' :       smp_cfg['input'],           # list of input channels to use
    'track':        4                           # number of virtual tracks, here: four tracks
}
retvals = soundmexpro('init', init_cfg)    
print('You are running SoundMexPro licence type: {} '.format(retvals['Type']))

# 4. trackmap
print('')
# retrieve the current track mapping (i.e. default)
retvals = soundmexpro('trackmap')
# show mapping
print('Default track mapping:')
for track, channel in enumerate(retvals['track'], start = 0):
    print("Virtual track no. {} is currently mapped to output channel no. {}".format(track, channel))
print('')
    

# change mapping to map three virtual tracks (0, 1 and 3) to output channel
# 0 and the remaining track No. 2 to output channel 1
retvals = soundmexpro('trackmap', {'track' : [0, 0, 1, 0]})
print('New track mapping:')
for track, channel in enumerate(retvals['track'], start = 0):
    print("Virtual track no. {} is currently mapped to output channel no. {}".format(track, channel))
input("Hit Enter to continue")

# 5. initialized, exit
print('')
retvals = soundmexpro('initialized')
if retvals['initialized'] != 1:
    raise ValueError('soundmexpro is unexpectedly not initialized!')

print('exiting soundmexpro')
soundmexpro('exit')
retvals = soundmexpro('initialized')
if retvals['initialized'] != 0:
    raise ValueError('soundmexpro is unexpectedly still initialized')
print('soundmexpro is NOT initialized')

# finally call init again with simple config
soundmexpro('init', smp_cfg)

# 6. Version
print('')
retvals = soundmexpro('version')
print('You are running SoundMexPro version: {} '.format(retvals['Version']))

# 7. show, hide
print('')
soundmexpro('show')
input("Mixer/visualization now is visible. Hit any key to hide it again")

soundmexpro('hide')
print("Mixer/visualization now is hidden again")

