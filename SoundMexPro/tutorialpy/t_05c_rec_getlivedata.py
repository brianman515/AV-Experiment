#
#                    Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
#
# This example shows how to retrieve live data bufferwise from the device
# and 'collect' them to have all recorded data on available on the fly
# NOTE: It is recommended to connect the first two output channels with the
# first two input channels with a a shortcut cable to run these examples.
# You may also use other channels by setting global variables (see below)
#
# NOTE: the commands 'recbufsize' and 'recgetdata' are only available in
# demo version and with a DSP license!
#
# SoundMexPro commands introduced in this example:
#   recbufsize
#   recgetdata
#
# Required Python libraries that are not part of the standard library
#   - numpy
#   - soundfile
#   - matplotlib

import sys
import os
import time
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
smp_cfg = smp_get_cfg(1)
# init with two outputs and two inputs
soundmexpro('init', smp_cfg)    

soundmexpro('show')    

# set record buffer size to 20000 samples
soundmexpro('recbufsize', {'value' : 20000})

# disable 'regular' recording to file. NOTE: the regular files rec_?.wav
# are created anyway, but stay empty
soundmexpro('recpause', {'value' : 1})

# load three example wave files
soundmexpro('loadfile', {'filename' : '../waves/eurovision.wav'})
#soundmexpro('loadfile', {'filename' : '../waves/3sine_16bit.wav'})
# third with a linear gain
#soundmexpro('loadfile', {'filename' : '../waves/sweep.wav', 'gain' : 0.5})
# ... and append a few zeros
soundmexpro('loadmem', {'data' : numpy.zeros((10000, 2))})
  

# start playback and record
soundmexpro('start')

recdata = numpy.array([])
recpos = 0
while 1:
    # query recorded data: NOTE after each call to recgetdata 'recbuf' will
    # contain the last n recorded samples, where n is the recbufsize set
    # above. 'pos' is set to the absolute position of the first sample in
    # time (since the device is running). In subsequent calls to 'recgetdata'
    # you may retrieve overlapping data (if you are calling fast!), and
    # thus the number of 'new' samples n (i.e. samples, that were not already
    # retrieved in last call) can be calculated by the difference of the
    # two retrieved positions p1 and p2:
    #       n = (p2 - p1)
    # If this number is larger than your recbufsize, than you have missed
    # data! Otherwise you can copy the new data with respect to the
    # overlap: the last (recbufsize - n) samples in the first buffer are
    # identical to the first (recbufsize - n) samples in the second buffer
    # and you may skip them
    retvals = soundmexpro('recgetdata')
    # get  position of first sample within received data
    pos = retvals['position']
    
    # NOTE: if you don't want to wave 'dummy-zeros' in the beginning, then
    # throw away all value retrieved with 'recgetdata' with negative
    # indices, i.e. start storing values in recdata from (pos + recbuf(i)
    # >= 0)


    # NOTE: after first call (i.e recpos still 0) we might not have caught
    # the very first buffer, so we have to adjust the position here
    if recpos == 0:
        recpos = pos
    
    # append data with respect to current record position!
    # - check, if we have 'missed' data
    if pos > recpos:
        raise ValueError('stopping example: we missed record data!')
    
    # - calculate position, where the first sample is located, that we did
    # not already retrieve in last call
    readstart = recpos - pos

    # - append read new data. NOTE: if you do this in loooooooong recording
    # loops you may produce heavy memory and processor load, because the
    # matrix has to be resized in every call!
    if recdata.size == 0:    
        recdata = retvals['data']        
    else:
        recdata = numpy.vstack((recdata, retvals['data'][readstart:len(retvals['data']),:]))
    
    # - increment absolute recording position
    recpos = recpos + (len(retvals['data']) - readstart) 
    
    # check if device is still running. NOTE: it was started in default mode
    # 0, i.e. it stops automatically after playback is complete!
    retvals = soundmexpro('started')
    # if not, we're done
    if retvals['value'] != 1:
        break
    
    # wait a bit before retrieving next data. Increase this value to get
    # the 'missing data' scenario tested above.
    time.sleep(0.05)
    

soundmexpro('exit')
    

# remove dummy recorded empty files
os.remove('rec_0.wav')
os.remove('rec_1.wav')

# show a plot 
plt.plot(recdata, linewidth = '0.5')
plt.show()

