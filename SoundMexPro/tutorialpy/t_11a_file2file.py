#
#                    Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
#
# This example shows how to run file-to-file operation rather than using a
# real sound device. Using file-to-file operation is useful (only), if you
# want to evaluate own plugins (VST or MATLAB-script-plugins) that are too
# slow for real-time operation. If such 'slow' plugins are used with regular
# soundcard operation, then xruns (dropouts) would occur, because regular 
# operation is hardware driven (i.e. the soundcard driver calls SoundMexPro
# when it needs data).
# If you (only) want to store the output data (i.e. the audio data passed
# to the output channels) without evaluating such 'slow' plugins, then you 
# may use the command 'debugsave' rather than using file-to-file operation!
#
# SoundMexPro commands introduced in this example:
#   parameters 'file2file' and 'f2fbufsize' for command 'init'
#   f2ffilename

import sys
import os
import time
import numpy
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



# initialize SoundMexPro in file2file-mode using 2 channels and 4 tracks
# NOTE: here you may specify your MATLAB script-plugins, see tutorials
# t_07*
soundmexpro('init',                 # command name
            {
            'file2file' : 1,        # switch on file2file-mode
            'f2fbufsize' : 1024,    # buffersize to use for file2file-mode (1024 is default)
            'samplerate' : 44100,   # samplerate to use for file2file-mode (44100 is default)
            'output' : 2,           # number of output channels to use
            'track' : 4             # number of tracks to use  with standards mapping
            }
)

# set the filenames for the output files other than default
soundmexpro('f2ffilename',                              # command name
            {
            'channel' : [0, 1],                         # channels to set filename for
            'filename' : ['myfile1.wav', 'myfile2.wav'] #  array with filenames
            }
)


# now you may load your VST-plugin(s), see tutorial t_09b_vst_gain and
# advanced examples in directory 'examples'

# load audio data to first two tracks (one track on each output channel
soundmexpro('loadfile',                  # command name
            {
            'filename' : '../waves/eurovision.wav',   # filename
            'track' : [0, 1],                         # load it to first two tracks
            'loopcount' : 2                           # loopcount
            }
)

# load a noise to 3rd track (to be added to output channel 0)
soundmexpro('loadfile',                  # command name
            {
            'filename' : '../waves/noise_16bit.wav',    # filename
            'track' : [-1, 2],                          # tracks, here 2 (other channel of file discarded by -1)
            'loopcount' : 1                             # loopcount
            }
)


# create and load a modulation sine to track 3
# Create a modulation sine 
t = numpy.linspace(0, 1, 44100)  
modsin = 1.0 + 0.8 * numpy.sin(16 * numpy.pi * t)  

# set track mode of corresponding track to 'multiply'
soundmexpro('trackmode', {'track' : 3, 'mode' : 1})

# then load modulation sine to that track
soundmexpro('loadmem',      # command name
            {
            'data' : modsin,        # data vector
            'name' : 'modulator',   # name used in track view for this vector
            'loopcount' : 4,        # loopcount
            'track' : 3             # track to load data to
            }
)

# go!
soundmexpro('start')
    
print('file2file-operation done');

# ---- now file2file-operation is complete --------------------------------

# now load the created files in 'regular' mode, show and play them
soundmexpro('exit')

# init with two outputs
soundmexpro('init', smp_cfg)    

# load the files
soundmexpro('loadfile',      # command name
            {
            'filename' : 'myfile1.wav', # first file (noise + music)
            'track' : 0                 # first track
            }
)
soundmexpro('loadfile',      # command name
            {
            'filename' : 'myfile2.wav', # second file (modulated music)
            'track' : 1                 # second track
            }
)


# show tracks 
soundmexpro('showtracks')
    
# start ...
soundmexpro('start')
    
# ... and wait for playback to be finished
soundmexpro('wait')

# cleanup
soundmexpro('exit')
    
os.remove('myfile1.wav');
os.remove('myfile2.wav');
