#
#                    Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
# The examples named t_04????? show usage of multiple commands related to
# playback of files and vectors with mixing (multiple tracks per channel),
# waiting, clipping ... They show similar playback situations with slightly
# different features to show different behaviour of SoundMexPro needed for
# different tasks.
#
# This example shows muting, 'solo-ing', and clearing data
#
# 
# SoundMexPro commands introduced in this example:
#   pause
#   mute
#   trackmute
#   tracksolo
#   cleardata


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
# init with two outputs
soundmexpro('init', smp_cfg)    

# show visualization
soundmexpro('show')

# -------------------------------------------------------------------------
## 1. show difference between 'mute' and 'pause'
print('Example 1: playback muting and pausing');
soundmexpro('loadfile',                                 # command name
            {
            'filename' : '../waves/eurovision.wav',     # filename
            'loopcount' : 0                             # loop count, here: endless loop
            }
)

# start playback
soundmexpro('start')

input('Hit a key to pause playback')

# set to paused mode
soundmexpro('pause', {'value' : 1})
    
print('Now playback is paused for 2 seconds. Afterwards playback proceeds at the same position')
time.sleep(2);

# set to unpaused mode
soundmexpro('pause', {'value' : 0})
    
input('Hit a key to mute playback')


# set to muted mode
soundmexpro('mute', {'value' : 1})

print('Now playback is muted for 2 seconds. Playback continues meanwhile, so position advanced during muting!')
time.sleep(2);


# set to unmuted mode
soundmexpro('mute', {'value' : 0})
    
time.sleep(2);
print('Now playback is on first track only for 2 seconds.')

# mute first 
soundmexpro('trackmute', {'track' : 0, 'value' : 1})
    
time.sleep(2);
# set to unmuted mode
soundmexpro('trackmute', {'value' : 0}) # here we specify no particular track, i.e. unmute all tracks!

time.sleep(2);
print('Now "solo" shown: superseeds "mute"');
# mute first track
soundmexpro('trackmute', {'track' : 0, 'value' : 1})
    
print('Only second channel audible: first is muted')
time.sleep(2);

# now set first to solo
soundmexpro('tracksolo', {'track' : 0, 'value' : 1})
print('Only first channel audible: is set to "solo"')
time.sleep(2);


input('Hit a key to continue')

soundmexpro('stop')

# -------------------------------------------------------------------------
## 2. show usage of command 'cleardata' in pause mode
print('Example 2: clearing data in pause mode')
soundmexpro('loadfile',                                 # command name
            {
            'filename' : '../waves/eurovision.wav',     # filename
            'loopcount' : 0                             # loop count, here: endless loop
            }
)

# start playback
soundmexpro('start')

# wait a bit
time.sleep(1);

# pause playback
soundmexpro('pause', {'value' : 1})
    
print('device is paused');

# clear data in pause mode
soundmexpro('cleardata')

# load other file
soundmexpro('loadfile',                                 # command name
            {
            'filename' : '../waves/3sine_16bit.wav',    # filename
            'loopcount' : 0                             # loop count, here: endless loop
            }
)


# resume playback with new data
soundmexpro('pause', {'value' : 0})

print('device resumes after clearing and loading different data')

input('Hit a key to stop example')
