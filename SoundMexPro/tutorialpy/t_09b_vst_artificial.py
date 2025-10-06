#
#                    Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
#
# This example shows how to do complex 'wiring' with multiple VST plugins
# and what this means for the data flow. It is a pure 'artificial' example
# using a simple 'gain' plugin supporting uo to 8 inputs and outputs and
# using articficial audio data (a diagonal matrix) to 'see' after
# processing, which channels were mixed and what gains were applied
# NOTE: you will need a soundcard with four channels at least to run this
# example!
#
# SoundMexPro commands introduced in this example:
#   vstload
#   vstparam
#
# Required Python libraries that are not part of the standard library
#   - numpy
#   - soundfile

import sys
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
# init with first four outputs: may fail, if driver has not four channels!
smp_cfg['output'] = [0, 1, 2, 3]
soundmexpro('init', smp_cfg)    


# Create diagonal dummy data and load them
audiodata = numpy.zeros((4, 4))
numpy.fill_diagonal(audiodata, 1)

soundmexpro('loadmem',
            {
            'data' : audiodata,
            'loopcount' : 1024
            }
)

# switch on debug saving for all channels
soundmexpro('debugsave', {'value' : 1})
            
# NOTE: in the following all values, parameters and programs are set
# 'manually' (without using config file) to 'see' directly what is done
# here. 

# Load five plugins. The wiring is shown on the left side of the scheme
# below: the lines symbolize the audio data flow. Data are flowing
# from top to bottom. The p? are plugins. For example at position (layer) 1
# only one plugin is loaded (p3) using channels 1 and 2 as inputs and
# channels 1 and 3 as output. On the right hand the audio data between the 
# different layers are shown assuming 'pure' data as the channel numbers
# from 0 to 3 at the top. Processed data are symbolized by the plugin name
# as function, e.g. data 1 proccessed by plugin p4 are symbolized by p4(1).
#
#          Wiring                           Channel data 
#          ------                           ------------
#
#                 |   |   |   |             0           1           2           3                   
#                 |   |   |   |
# Position 0      p1  p1  p2  |
#                 |   |   |   |
#                 |   |   |   |             p1(0)       p1(1)       p2(2)       3
#                 |   |   |   |
# Position 1      |   p3  p3  |
#                 |   |    \  |
#                 |   |     \_|             p1(0)       p3(p1(1))   empty       p3(p2(2)) + 3
#                 |   |       |
# Position 2      p4  |       p5
#                  \  |       |
#                   \_|       |             empty       p4(p1(0))   empty       p5(p3(p2(2)) + 3)
#                     |       |                         +p3(p1(1))


# load plugin p1
soundmexpro('vstload',                                  # command name
            {
            'filename' : '..\plugins\HtVSTGain.dll',    # filename of plugin
            'type' : 'master',                          # plugin type ('master' is default)
            'input' : [0, 1],                           # inputs to use
            'output' : [0, 1],                          # outputs to use
            'position' : 0                              # vertical position (layer) where to load plugin to
            }
)
# load plugin p2
soundmexpro('vstload',                                  # command name
            {
            'filename' : '..\plugins\HtVSTGain.dll',    # filename of plugin
            'type' : 'master',                          # plugin type ('master' is default)
            'input' : 2,                                # inputs to use
            'output' : 2,                               # outputs to use
            'position' : 0                              # vertical position (layer) where to load plugin to
            }
)
# load plugin p3
soundmexpro('vstload',                                  # command name
            {
            'filename' : '..\plugins\HtVSTGain.dll',    # filename of plugin
            'type' : 'master',                          # plugin type ('master' is default)
            'input' : [1, 2],                           # inputs to use
            'output' : [1, 3],                          # outputs to use
            'position' : 1                              # vertical position (layer) where to load plugin to
            }
)
# load plugin p4
soundmexpro('vstload',                                  # command name
            {
            'filename' : '..\plugins\HtVSTGain.dll',    # filename of plugin
            'type' : 'master',                          # plugin type ('master' is default)
            'input' : 0,                                # inputs to use
            'output' : 1,                               # outputs to use
            'position' : 2                              # vertical position (layer) where to load plugin to
            }
)
# load plugin p5
soundmexpro('vstload',                                  # command name
            {
            'filename' : '..\plugins\HtVSTGain.dll',    # filename of plugin
            'type' : 'master',                          # plugin type ('master' is default)
            'input' : 3,                                # inputs to use
            'output' : 3,                               # outputs to use
            'position' : 2                              # vertical position (layer) where to load plugin to
            }
)


# set different linear gains for all five plugins
soundmexpro('vstparam',                          # command name
            {
            'input' : 0,                        # one of the inputs, where plugin is plugged to
            'position' : 0,                     # vertical position (layer) where plugin is loaded
            'parameter' : ['gain_0', 'gain_1'], # array with parameter names to set
            'value' : [0.2, 0.2]                # vector with values to set
            }
)
soundmexpro('vstparam',                         # command name
            {
            'input' : 2,                        # one of the inputs, where plugin is plugged to
            'position' : 0,                     # vertical position (layer) where plugin is loaded
            'parameter' : 'gain_0',             #  array with parameter names to set
            'value' : 0.3                       # vector with values to set
            }
)
soundmexpro('vstparam',                         # command name
            {
            'input' : 1,                        # one of the inputs, where plugin is plugged to
            'position' : 1,                     # vertical position (layer) where plugin is loaded
            'parameter' : ['gain_0', 'gain_1'], # array with parameter names to set
            'value' : [0.4, 0.4]                # vector with values to set
            }
)
soundmexpro('vstparam',                         # command name
            {
            'input' : 0,                        # one of the inputs, where plugin is plugged to
            'position' : 2,                     # vertical position (layer) where plugin is loaded
            'parameter' : 'gain_0',             # array with parameter names to set
            'value' : 0.5                       # vector with values to set
            }
)
soundmexpro('vstparam',                         # command name
            {
            'input' : 3,                        # one of the inputs, where plugin is plugged to
            'position' : 2,                     # vertical position (layer) where plugin is loaded
            'parameter' : 'gain_0',             # array with parameter names to set
            'value' : 0.6                       # vector with values to set
            }
)


# start and wait
soundmexpro('start')
soundmexpro('wait', {'mode' : 'stop'})

time.sleep(0.5)

# read 4 samples out of the middle of the four debugfiles (when ramps are done) 
# and 'rebuild' data matrix
wavdata = numpy.array([])
for i in range(4):
    filename = 'out_%d.wav' % (i)
    x, samplerate = soundfile.read(filename)
    if wavdata.size == 0: 
        wavdata  = x[1001:1005]
    else:
        wavdata = numpy.vstack((wavdata, x[1001:1005]))

# plot the samples
numpy.set_printoptions(precision=3, floatmode='fixed')
print(wavdata.T)

# compare with upper scheme:
# - input data are ones
# - gains (fatcors) are 0.2 ... 0.6

# -     first column should contain zeros only
# -     second column should contain:
#          first line: p4(p1(0)), i.e. 0.5*0.2*1 = 0.1
#          second line: p3(p1((1)), i.e. 0.4*0.2*1 = 0.08
#          others: zero 
# -     third column should contain zeros only
# -     fourth column should contain 
#          first two lines zero
#          third line: p5(p3(p2(2)), i.e. 0.6*0.4*0.3*1 = 0.072
#          fourth line: p5(3), i.e. 0.6*1 = 0.6
# thus should look like :
#  [[0.000 0.100 0.000 0.000]
#   [0.000 0.080 0.000 0.000]
#   [0.000 0.000 0.000 0.072]
#   [0.000 0.000 0.000 0.600]]



