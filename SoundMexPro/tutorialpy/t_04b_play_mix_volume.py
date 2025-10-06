#
#                    Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
# This example shows playback of multiple files, vectors, on multiple
# tracks including muliple tracks per channel (mixing), setting of
# (channel) volume and track volume respectively.
#
# SoundMexPro commands introduced in this example:
#   loadmem playposition volume trackvolume trackmode clipcount
# 
# NOTE: this example is the first that really uses multiple virtual tracks,
# so it is essential to know the basic concept of virtual tracks and to
# realize the difference between channels and virtual tracks. Please refer 
# to the SoundMexPro manual for an introduction on this topic.
#
# NOTE: the second return value of the commands 'loadfile' and 'loadmem' 
# (the 'busy' flag) is not checked here. See example
# t_04c_play_con_stim_gen.m for that task.
# 
# SoundMexPro commands introduced in this example:
#   showtracks
#   hidetracks
#   updatetracks
#   showmixer
#   hidemixer
#   clipcount
#   resetclipcount
#
# Required Python libraries that are not part of the standard library
#   - numpy
#   - soundfile

import sys
import time
import numpy
import math
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
# NOTE: flag 0 will remove inputs, returned dictionary will hold driver and output only, 
# i.e. suitable for 'init' directly
smp_cfg = smp_get_cfg(0)
smp_cfg['track'] = 4    # number of virtual tracks, here 4 (i.e. 2 tracks per channel)
# init with two outputs
soundmexpro('init', smp_cfg)    

# show visualization
soundmexpro('show')
                   
# -------------------------------------------------------------------------
## 1. Mixed playback.
# We setup a mixture of files, vectors, mixing files and mixing vectors for
# playback.
print('Example 1: mixed playback of files, memory ...')

# Start with a stereo file to be played on both channels 
args = {
    'filename' : '../waves/noise_16bit.wav',        # filename
    'ramplen' : 10000,                              # apply a ramp in the beginning and the end 
    'track' : [0, 1],                               # tracks, here 0 and 1 (one track on each channel)
    'loopcount' : 1
}
soundmexpro('loadfile', args)

# then append a sweep to same tracks, (for demonstration purposes loaded from to an array)
sweep, samplerate = soundfile.read('../waves/sweep.wav')
# IMPORTANT NOTE: reading waves to memory with python creates interleaved data in memory, bit_length
# soundmexpro needs non-interleaved data: so force rearranging in memory!!
sweep = numpy.asfortranarray(sweep/4)
args = {
    'data' : sweep,        # filename
    'name' : 'sweep', 
    'ramplen' : 20000,                              # apply a ramp in the beginning and the end 
    'loopramplen' : 5000,                              # apply a ramp in the beginning and the end 
    'track' : [0, 1],                               # tracks, here 0 and 1 (one track on each channel)
    'loopcount' : 3
}
soundmexpro('loadmem', args)

# Create a modulation sine 
t = numpy.linspace(0, 1, 44100)  
modsin = 0.5 + 0.5 * numpy.sin(8 * numpy.pi * t)  

# Multiply first track with this sine. For this purpose we set the track
# mode of the third track of output channel 0 to multiply mode
soundmexpro('trackmode', {'track' : 2, 'mode' : 1})

# then load modulation sine to that track
args = {
    'data' : modsin,        # filename
    'name' : 'modulator', 
    'track' : 2,                               # tracks, here 0 and 1 (one track on each channel)
    'loopcount' : 2
}
soundmexpro('loadmem', args)


# on the other channel add some other audio data for additive mixing 
args = {
    'filename' : '../waves/eurovision.wav',     # filename
    'track' : [-1, 3],                          # ignore first file channel, play second on track 3 (second track of channel 1)
    'ramplen' : 10000,                          # apply a ramp in the beginning and the end 
    'offset' : 44100,                           # add 1 second of silence to the beginning
    'loopramplen' : 10000,                   # apply a ramp for loops ...
    'loopcrossfade' : 1,                      # ... and use this ramp for a crossfade
    'loopcount' : 2                           # loopcount
}
soundmexpro('loadfile', args)

# show trackview ...
soundmexpro('showtracks')
# ... and start!
soundmexpro('start')


retvals = soundmexpro('playing')

# check if at least one of the tracks 2 and 3 
# is still playing
while 1:
    # query device
    retvals = soundmexpro('playing')
    # then check the last two tracks (NOTE: array is 0-based!)
    if max(retvals['value'][2:4]) == 0:
        break
        
    # NOTE: no while loops without a pause!
    time.sleep(0.1)
    # show current playback position
    retvals = soundmexpro('playposition')
    print('played {} samples'.format(retvals['value']))

print('mixing done')

soundmexpro('wait', {'mode' : 'stop'})

# reset all tracks to standard adding mode!
soundmexpro('trackmode', {'mode' : 0})

input("playing done. Hit a key to proceed with next example.") 


# -------------------------------------------------------------------------
## 2. Demonstration of how multichannel data are 'aligned' if loaded to
# tracks with different amount of data loaded earlier
print('Example 2: demonstration of "alignment"')

# Start with a stereo file, where we only use first channel on first track,
# therefore second track stays empty!
args = {
    'filename' :  '../waves/sweep.wav',     # filename
    'track' :  [0, -1],                     # tracks, here 0 and -1 (ignore second file channel)
    'loopcount' : 2                          # loopcount
}
soundmexpro('loadfile', args)

# Then a stereo file to be played on both channels: this must result in
# prepended zeros for second channel, so that you first should hear the sweep on
# the first channel only, and afterwards 'eurovision.wav' on both channels
# 'synchronized'
args = {
    'filename' :  '../waves/eurovision.wav',     # filename
    'offset' : 22050,
    'track' :  [0, 1],                     # tracks, here 0 and -1 (ignore second file channel)
    'loopcount' : 1                          # loopcount
}
soundmexpro('loadfile', args)

# show trackview, start, wait
soundmexpro('showtracks')
soundmexpro('start')
soundmexpro('wait')

input("playing done. Hit a key to proceed with next example.") 

# hide track view visualization
soundmexpro('hidetracks')


# -------------------------------------------------------------------------
## 3. Using volume and trackvolume and checking clipcount
# Play some noise and start mixing a sweep later
print('Example 3: volume, trackvolume, clipcount ...')

# In the beginning set (channel) volume of all channels to avoid clipping
retvals = soundmexpro('volume', {'value' : 0.5})

# show current volumes in dB fullscale
print('set total attenuation to  {:0.2f} dB'.format(20*math.log10(retvals['value'][0])))

# load noise

args = {
    'filename' :  '../waves/noise_16bit.wav',   # filename
    'track' :  [0, 1],                          # tracks, here 0 and 1 (one track on each channel)
    'loopcount' : 0                             # loopcount (endless loop
}
soundmexpro('loadfile', args)

soundmexpro('show')

# start playback
soundmexpro('start')

# wait a bit 
time.sleep(1)

# start mixing data on both channels using the next virtual tracks
args = {
    'filename' :  '../waves/sweep.wav',         # filename
    'track' :  [2, 3],                          # tracks, here 2 and 3 (sweep)
    'loopcount' : 0                             # loopcount (endless loop
}
soundmexpro('loadfile', args)


# now change volumes of tracks '0 and 1' or '2 and 3' respectively to
# change 'SNR'. NOTE: we define an SNR of 0 dB here as same volume of the
# noise and the sweep!
input("playing sweep in noise at 0 dB SNR on both channels. Hit a key to continue")

# now change volume sweep only and calculate new SNR
args = {
    'track' :  [2, 3],                          # tracks, here 2 and 3 (sweep)
    'value' :  [0.1, 0.5]                       # volume values for sweep
}
retvals = soundmexpro('trackvolume', args)


# calculate new SNR
snr1 = 20*math.log10(retvals['value'][2]/retvals['value'][0])
snr2 = 20*math.log10(retvals['value'][3]/retvals['value'][1])

print('First channel: {:0.2f} dB SNR, second channel: {:0.2f} dB SNR'.format(snr1, snr2))
input(" Hit a key to proceed") 


# now change volume of noise and sweep part simultaneously and calculate new SNR
# Here we additionally do volume setting with a ramp
args = {
    'track' :  [0,1, 2, 3],                    # tracks, here all tracks
    'value' :  [0.5, 0.4, 0.9, 0.9],           # volume values for all tracks
    'ramplen' : 22050                          # use a ramp of half a second
}
retvals = soundmexpro('trackvolume', args)

snr1 = 20*math.log10(retvals['value'][2]/retvals['value'][0])
snr2 = 20*math.log10(retvals['value'][3]/retvals['value'][1])

print('First channel: {:0.2f} dB SNR, second channel: {:0.2f} dB SNR'.format(snr1, snr2))

# check, if we had clippings up to now (not expected).
retvals = soundmexpro('clipcount')
input('Clipped buffers on first channel: {}, on second channel: {}. Hit a key to continue'.format(retvals['output'][0], retvals['output'][1]))

# show mixer visualization with 'topmost' flag
soundmexpro('showmixer', {'topmost' : 1})

# now raise master volume on first channel to force clipping. Here we show
# as well the argument 'channel' for 'volume': we specify one channel and
# one volume to keep volume on other chanel unchanged!
args = {
    'value' :   3,           
    'channel' : 0            
}
retvals = soundmexpro('volume', args)

# wait a bit
time.sleep(1.5)

# check clipping again: now be should have had clipping on the first
# channel!
retvals = soundmexpro('clipcount')
print('Clipped buffers on first channel: {}, on second channel: {}. Hit a key to continue'.format(retvals['output'][0], retvals['output'][1]))
input('Note overdrive LED''s on mixer. Hit a key to continue')

soundmexpro('stop')

# reset clipcount
soundmexpro('resetclipcount')

# retrieve clipcoutn again: should be zero again
retvals = soundmexpro('clipcount')
print('Clipped buffers on first channel: {}, on second channel: {}. Hit a key to continue'.format(retvals['output'][0], retvals['output'][1]))

input('Hit a key to quit example')
