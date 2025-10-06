#
#                    Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
# This example shows playback of audio data, that are passed to the device
# 'on the fly' while it is running. It shows how to detect 'underruns'
# (i.e. the device rans out of data, before new data are passed to it), and
# 'overflows' (i.e. data segments are passed too fast to the device)
#
#
# SoundMexPro commands introduced in this example:
#   trackload
#   underrun
#   debugsave
#
# Required Python libraries that are not part of the standard library
#   - numpy
#   - soundfile
#   - matplotlib

import sys
import time
import os
import numpy
import soundfile 
import matplotlib.pyplot as plt 

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
                   
# create a dummy buffer: read a short signal with sines of different
# frequencies in two channels
signal, samplerate = soundfile.read('../waves/900l_450r.wav')
# IMPORTANT NOTE: reading waves to memory with python creates interleaved data in memory, bit_length
# soundmexpro needs non-interleaved data: so force rearranging in memory!!
signal = numpy.asfortranarray(signal)

# pre-load a few buffers (here: 10). NOTE: we can do this by preloading 
# 'one longer buffer' by loopcount!
args = {
    'data' : signal, 
    'loopcount' : 10
}
soundmexpro('loadmem', args)

# start device in 'play-zeros-if-no-data-in-tracks'-mode
soundmexpro('start', {'length' : 0})

# -------------------------------------------------------------------------
## 1: we pass new data quite too fast. So, we expect that the number of
# loaded data segments, ie. the 'trackload' raises. 
# 
print('First example: no underruns, adding new data "too fast"')
for i in range(20):
    soundmexpro('loadmem', {'data' : signal})
    # small pause. 
    time.sleep(0.02)


# check, if we had underruns (not expected!)
retvals = soundmexpro('underrun')
if max(retvals['value']) > 0:
    print('UNEXPECTEDLY THERE WAS A DATA UNDERRUN')
else:
    # now we expect that quite same data segments are 'accumulated'
    retvals = soundmexpro('trackload')
    print('no underrun occurred, currently {} data segments are pending for output'.format(retvals['value'][0]))


soundmexpro('stop')
time.sleep(0.5)

# -------------------------------------------------------------------------
## 2: the data adding loop is fast again, but we take care of the
# current trackload! This is the recommended way to do it!
# 
print('-------------------------------------------------------------------------')
print('Second example: no underruns, taking care of trackload')

# pre-load a few buffers (here: 10). NOTE: we can do this by preloading 
# 'one longer buffer' by loopcount!
args = {
    'data' : signal, 
    'loopcount' : 10
}
soundmexpro('loadmem', args)

# start device in 'play-zeros-if-no-data-in-tracks'-mode
soundmexpro('start', {'length' : 0})

busycounter     = 0
successcounter  = 0
while successcounter < 30:
    # retrieve current trackload
    retvals = soundmexpro('trackload')
    # more that 10 segments pending? do not load new data
    if retvals['value'][0] > 10:
        busycounter =  busycounter + 1
    else:
        soundmexpro('loadmem', {'data' : signal})
        successcounter = successcounter + 1
    
    # very small pause. 
    time.sleep(0.01)


# check, if we had underruns (not expected!)
retvals = soundmexpro('underrun')
if max(retvals['value']) > 0:
    print('UNEXPECTEDLY THERE WAS A DATA UNDERRUN')
else:
    # now we expect that quite same data segments are 'accumulated'
    retvals = soundmexpro('trackload')
    print('no underrun occurred, {} times data loading was skipped'.format(busycounter))

soundmexpro('stop')
time.sleep(0.5)

# -------------------------------------------------------------------------
## 3: we are too slow (in this example far too slow), so we hear
# dropouts and can detect the underrun afterwards!
print('-------------------------------------------------------------------------')
print('Third example: an underrun occurs')
time.sleep(0.2)

# in this example we show usage of 'debugsave' as well: we save the final
# output of the first channel and plot it afterwards

# switch on debug saving
args = {
    'value' : 1, 
    'channel' : 0
}
soundmexpro('debugsave', args)

# pre-load one buffer
soundmexpro('loadmem', {'data' : signal})
    
# start device in 'play-zeros-if-no-data-in-tracks'-mode
soundmexpro('start', {'length' : 0})

for i in range(10):
    soundmexpro('loadmem', {'data' : signal})
    # pause, that is quite too long
    time.sleep(0.2)


# check, if we had underruns: expected this time!
retvals = soundmexpro('underrun')
if max(retvals['value']) < 1:
    print('UNEXPECTEDLY THERE WAS NO DATA UNDERRUN')
soundmexpro('stop')

# read debug-save-file
signal, samplerate = soundfile.read('out_0.wav')
os.remove('out_0.wav')

# show a plot 
plt.plot(signal, linewidth = '0.5')
plt.show()

   

