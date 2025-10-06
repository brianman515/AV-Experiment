#           Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
# The examples named t_04????? show usage of multiple commands related to
# playback of files and arrays with mixing (multiple tracks per channel),
# waiting, clipping ... They show similar playback situations with slightly
# different features to show different behaviour of SoundMexPro needed for
# different tasks.
#
# This example mainly shows the usage of the command 'loadfile' and
# especially usage of the paameters 'crossfadelen', 'ramplen',
# 'loopramplen' and 'loopcrossfade'. For this purpose only simple playback
# on two channels is done.
#
# 
# SoundMexPro commands introduced in this example:
#   loadfile
#   start
#   wait
#   tracklen
#   stop

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
# NOTE: flag 0 will remove inputs, returned dictionary will hold driver and output only, 
# i.e. suitable for 'init' directly
smp_cfg = smp_get_cfg(0)
# init with two outputs
soundmexpro('init', smp_cfg)    
                   
# -------------------------------------------------------------------------
# 1. show crossfade between different files

# load first file
args = {
    'filename': '../waves/eurovision.wav'       # filename
}
soundmexpro( 'loadfile', args)

# load second file with crossfade
args = {
    'filename': '../waves/3sine_16bit.wav',     # filename
    'crossfadelen' : 60000                      # do a crossfade of 60000 samples with object BEFORE this one
}
soundmexpro( 'loadfile', args)

# show visualization
soundmexpro('showtracks')
 
# start playback. length here -1: stop if no track has more data (this is default)
soundmexpro('start', {'length' : -1})

# wait for device to be stopped after playback is complete
soundmexpro('wait', {'mode' : 'stop'})

input("Hit Enter to continue") 

# -------------------------------------------------------------------------
# 2. ramps within a looped object

# load a file
args = {
    'filename': '../waves/3sine_16bit.wav',     # filename
    'ramplen':  44100,                          # initial and final ramp of 44100 samples length
    'loopcount' : 3,                            # play three loops
    'loopramplen' : 10000                       # ramp at end and beginning of each loop of 10000 samples length
}
soundmexpro( 'loadfile', args)

# update the track view with new data
soundmexpro('updatetracks')

# plot current length of track in samples and seconds
retvals = soundmexpro('tracklen');
print('track length of three full loops: {} samples ({:0.1f} seconds)'.format(retvals['value'][0], retvals['value'][0]/44100))

# start ... 
soundmexpro('start')
# ... and wait for device to be stopped after playback is complete
soundmexpro('wait', {'mode' : 'stop'})

input("Hit Enter to continue") 

# -------------------------------------------------------------------------
# 3. crossfade within a looped object

# load a file
args = {
    'filename': '../waves/3sine_16bit.wav',     # filename
    'ramplen':  44100,                          # initial and final ramp of 44100 samples length
    'loopcount' : 3,                            # play three loops
    'loopramplen' : 44100,                      # ramp at end and beginning of each loop of 44100 samples length
    'loopcrossfade' : 1                         # enable loop-crossfade
}
soundmexpro( 'loadfile', args)

# update the track view with new data
soundmexpro('updatetracks')

# plot current length of track in samples and seconds
retvals = soundmexpro('tracklen');
print('track length of three loops with crossfade: {} samples ({:0.1f} seconds)'.format(retvals['value'][0], retvals['value'][0]/44100))

# start ... 
soundmexpro('start')
# ... and wait for device to be stopped after playback is complete
soundmexpro('wait', {'mode' : 'stop'})
