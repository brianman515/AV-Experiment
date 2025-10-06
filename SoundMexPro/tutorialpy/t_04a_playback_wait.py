#           Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
#
# This example shows playback of files with different methods of waiting
# for playback to be complete and different parts of files/vectors to be
# played
#
# 
# SoundMexPro commands introduced in this example:
#   loadfile
#   start
#   started
#   wait
#   playing
#   stop
#   playposition                                                     
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
# NOTE: flag 0 will remove inputs, returned dictionary will hold driver and output only, 
# i.e. suitable for 'init' directly
smp_cfg = smp_get_cfg(0)
# init with two outputs
soundmexpro('init', smp_cfg)    

# show visualization
soundmexpro('show')
                   
# -------------------------------------------------------------------------
## 1. play a file two times and wait for it to be finished with command
# 'wait', which waits in 'blocking' mode (i.e. command returns after
# playback is complete). NOTE: the 'busy' flag in return value of 'loadfile' 
# is not checked here. See example t_04c_play_con_stim_gen.py
# for that task.
print('Example 1: waiting for playback done (blocking)')

# load file
args = {
    'filename' : '../waves/eurovision.wav',       # filename
    'loopcount' : 2
}
soundmexpro('loadfile', args)

# start playback with length '-1': stop, if not track has more data
soundmexpro('start', {'length' : -1})

# show usage of started, iven if not needed here...
retvals = soundmexpro('started')
print('started returned: {}'.format(retvals['value']))

# then wait
soundmexpro('wait', {'mode' : 'stop'})

# here we show usage of 'playing' command (even if not needed here)
retvals = soundmexpro('playing')
if max(retvals['value']) != 0:
    raise ValueError('device unexpectedly still playing')


input("Hit Enter to continue") 
    
# -------------------------------------------------------------------------
## 2. play a file two times and wait for it to be finished non-blocking.
# In a loop the 'playing' command checks, if the sound is still playing and
# does some calculation meanwhile.
print('Example 2: waiting for playback done (non-blocking, calculating during playback)')

# load file
args = {
    'filename' : '../waves/eurovision.wav',       
    'loopcount' : 2                               
}
soundmexpro('loadfile', args)

# start playback with length '-1': stop, if not track has more data
soundmexpro('start', {'length' : -1})

counter = 0
retvals = {'value' : [1]}
while max(retvals['value']) > 0:
    retvals = soundmexpro('playing')
    time.sleep(0.01)
    counter += 1
    
soundmexpro('stop')    

print('playback done, calculation loop called {} times.'.format(counter))
input("Hit Enter to continue") 

# -------------------------------------------------------------------------
## 3. play a file one times. Device is started with length 0, i.e. it does not
# stop after playback, but plays zeros. We wait a bit and load file one
# time again to immediate output with a random position and stop the device
# afterwards.
print('Example 3: waiting for playback, add more data wait again')

# load file
args = {
    'filename' : '../waves/eurovision.wav',       
    'loopcount' : 1
}
soundmexpro('loadfile', args)

# start playback with length 0, i.e. endless mode
soundmexpro('start', {'length' : 0})

# then wait
soundmexpro('wait')

print('playback 1 done')

# check, that device is still running
retvals = soundmexpro('started')
if retvals['value'] != 1:
    raise ValueError('device unexpectedly not running anymore')
    
# wait a bit
time.sleep(1)    

# play file again, this time from a random position to the end + one
# complete loop
args = {
    'filename' : '../waves/eurovision.wav',       # filename
    'loopcount' : 2,
    'startoffset' : -1                            # offset within file, here: -1 (random position)  
}
soundmexpro('loadfile', args)

# then wait
soundmexpro('wait')
soundmexpro('stop')

print('playback 2 done')
input("Hit Enter to continue") 

# -------------------------------------------------------------------------
## 4. load a file for playing multiple times. Device is started with length
# > 0, i.e.  it does stops after the corresponding number of samples is
# played.
print('Example 4: stop playback after particular number of samples')

args = {
    'filename' : '../waves/eurovision.wav',       
    'loopcount' : 5
}
soundmexpro('loadfile', args)

# start playback with paritcular length, here 44100: stop after one second
soundmexpro('start', {'length' : 44100})

soundmexpro('wait')

print('playback done')

retvals = soundmexpro('playing')
if max(retvals['value']) != 0:
    raise ValueError('device unexpectedly still playing')

input("Hit Enter to continue") 

# -------------------------------------------------------------------------
## 5. Show usage of parameters 'offset' 'startoffset', 'fileoffset' and 'length' 
# for command 'loadfile' and setting a play position in pause mode
print('Example 5: show usage of "loadfile" arguments and command "playposition"')

# load data to be played before the 'sophisticated' example file
args = {
    'filename' : '../waves/eurovision.wav',       
    'loopcount' : 1
}
soundmexpro('loadfile', args)

# The file ../waves/3sine_16bit.wav contains a sequence of three sine
# signals of one second length each: first second 440 Hz, then 900 Hz
# finally 600 Hz.
# In this example we want to play it with the following properties:
#  - start with one second silence (i.e. after the data loaded above): 
#    -> use parameter 'offset'
#  - use just a part of the file (snippet) not starting at the begining
#    of the file
#    -> use parameters 'fileoffset' and 'length' to define the snippet
#  - do not start at first sample of the snippet in first loop (useful e.g.
#    for pseude-running-noise)
#    -> use parameter 'startoffset'
args = {
    'filename' : '../waves/3sine_16bit.wav',    # filename   
    'offset' : 44100,                           # one second silence in the beginning
    'fileoffset' : 22050,                       # 0.5 seconds: we start with our snippet at the second half of the first 440 Hz sine
    'length' : 88200,                           # build a 2 seconds snippet: together with 'fileoffset' this leads to a snippet:
                                                # i.e.: 0.5 seconds 440Hz - 1 second 900 Hz - 0.5 seconds 600 Hz
    'loopcount' : 3,                            # loopcount of snippet
    'startoffset' : 22050                       # skip 0.5 secons in first, i.e. skip the 440 Hz in first loop
}
soundmexpro('loadfile', args)

# load more data after the 'sophisticated' example
args = {
    'filename' : '../waves/eurovision.wav',       
    'loopcount' : 5
}
soundmexpro('loadfile', args)

# -> total expected output is (combining all parameters/comments # above:
#
# eurovsion.wav -                               
# 1s silence - 
# 1s 900 Hz - 0.5s 600 Hz -                     # first loop with startoffset, i.e. 0.5s 440 Hz skipped
# 0.5s 440 Hz - 1s 900Hz - 0.5s 600 Hz -        # second full loop of snippet
# 0.5s 440 Hz - 1s 900Hz - 0.5s 600 Hz -        # third full loop of snippet
# eurovsion.wav multiple times
#
# NOTE: the vertical dooted loop lines in track view show the loop
# positions of the snippet, not the file!!

# initialize track view GUI
soundmexpro('showtracks')

# go
soundmexpro('start')

# no we wait until the last file plays
time.sleep(12);

# then pause
soundmexpro('pause', {'value' : 1})

# set play position: note cursor moves in track view
print('Moving playposition to 6 seconds')
soundmexpro('playposition', {'position' : 6*44100})

# wait a bit
time.sleep(2)
print('resume...')
soundmexpro('pause', {'value' : 0})

input("Hit Enter stop example") 