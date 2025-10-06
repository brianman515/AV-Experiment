# 
#                    Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
# 
# This example shows how to retrieve information about the devices, their
# available channels and other device properties
# NOTE: this example shows as well some paramaters of 'init' command. Most
# other examples use default parameters only!
#
# SoundMexPro commands introduced in this example:
#   getdrivers
#   getdriverstatus
#   getchannels
#   getproperties
#   getactivedriver
#   getactivechannels
#   trackname
#   controlpanel
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

# A. start with commands, that do _not_ need an initialized SoundMexPro
## 1. getdrivers
retvals = soundmexpro('getdrivers');
if len(retvals['driver']) == 0:
    raise ValueError('there are no ASIO drivers present in your system')

print('{} ASIO drivers where found on the system:'.format(len(retvals['driver'])))
for driver in retvals['driver']:
    print(driver)
print('')

## 2. getdriverstatus
retvals = soundmexpro('getdriverstatus');

print('The ASIO drivers have the following status (1=ok, 0=error):')
for status in retvals['value']:
    print(status)
print('')

## 3. getchannels of a driver 
retvals = soundmexpro('getchannels', {'driver' : smp_cfg['driver']});
#print(retvals)

print('The ASIO driver {} has the following output channels:'.format(smp_cfg['driver']))
for channel in retvals['output']:
    print(channel)
print('The ASIO driver {} has the following input channels:'.format(smp_cfg['driver']))
for channel in retvals['input']:
    print(channel)

input("Hit Enter to continue")


## B. Properties that need an initialized SoundMexPro. We only use two input and 
# output channels to get different return values for 'getchannels' and
# 'getactivechannels' 
if (len(smp_cfg['output']) < 2):
    raise ValueError('at least two output channels needed for proceeding')

## 1. initialize SoundMexPro 
# here we set up complete init dictionary by hand
init_cfg = {
    'driver' :      smp_cfg['driver'],          # enter a name here to load a driver by it's name
    'output' :      smp_cfg['output'],          # list of output channels to use 
    'input' :       smp_cfg['input'],           # list of input channels to use
    'track':        4                           # number of virtual tracks, here: four tracks
}
retvals = soundmexpro('init', init_cfg)    

## 2. retrieve current driver
driver = soundmexpro('getactivedriver');

## 3. retrieve properties 
properties = soundmexpro('getproperties');
print(properties)
# show properties. NOTE: drivername is a cell array! All strings returned
# by SoundMexPro commands are cell arrays, except for command 'getlasterror'!
print('Device {} initialized with samplerate {} Hz and buffer size is set to {} samples'.format(driver['driver'], properties['samplerate'], properties['bufsize']))
print('Device will use this format for playback: {}'.format(properties['soundformat']))
print('It supports at least the following samplerates:')
for samplerate in properties['samplerates']:
    print(samplerate)

## 4. retrieve active channel names
retvals = soundmexpro('getactivechannels');

print('The following output and input channels are initialized:')
for channel in retvals['output']:
    print(channel)
print('The ASIO driver {} has the following input channels:'.format(smp_cfg['driver']))
for channel in retvals['input']:
    print(channel)

## 5. show usage of 'trackname'. The commands 'channelname' and 'recname' are
# used in the same way, but for ouput channels and input channels
# respectively.
retvals = soundmexpro('trackname');

print('The default track names are:');
for name in retvals['name']:
    print(name)
    
# change output names 
soundmexpro('channelname', {'name' : ['myout1', 'out 2']});

# change tracknames 
# NOTE: track names must NEVER contain comma or semicolon!!
soundmexpro('trackname', {'name' : ['Noise left', 'Noise right', 'Signal front', 'other name']});

retvals = soundmexpro('trackname');
print('The user defined track names are:');
for name in retvals['name']:
    print(name)
    
# now show the mixer to show, that tracknames are shown
soundmexpro('showmixer');

# set volume of second track by using it's index
soundmexpro('trackvolume', {'track' : 1, 'value' : 0.2});

input("Hit Enter to continue")


# set volume of second track by using it's name
soundmexpro('trackvolume', {'track' : '"Noise right"', 'value' : 1});

input("Hit Enter to continue")

## 6. show/starts drivers own control panel
soundmexpro('controlpanel');
