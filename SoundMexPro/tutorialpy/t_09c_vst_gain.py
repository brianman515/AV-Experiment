#
#                    Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
#
# This example shows usage of a VST plugin with all corresponding commands
# in SoundMexPro. The used plugin is shipped with SoundMexPro. It is a 
# simple 'gain' plugin supporting up to 8 inputs and outputs.
#
# SoundMexPro commands introduced/used in this example:
#   vstquery
#   vstload
#   vstunload
#   vstprogram
#   vstprogramname
#   vstparam
#   vstset
#   vststore
#   vstedit

import sys
import time
import os
import os.path

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
# init with first two outputs
soundmexpro('init', smp_cfg)    

# -------------------------------------------------------------------------
# 1. vstquery: query a plugin by filename
# NOTE: you can query a loaded plugin as well by input and position. This
# is not shown here.
filename = '..\plugins\HtVSTGain.dll';
retvals = soundmexpro('vstquery', {'filename' : filename})
print(retvals)    
# plot retrieved info

print('Info about plugin {}'.format(filename))
print('Plugin contains effect "{}" ({}) manufactured by "{}"'.format(retvals['info'][0], retvals['info'][1], retvals['info'][2]))
print('It has {} inputs and {} outputs.'.format(retvals['input'], retvals['output']))
print('Plugin has {} programs, current program is "{}"'.format(len(retvals['programs']), retvals['program']))
print('Plugin has {} parameters. Names and values are:'.format(len(retvals['parameter'])))
for i in range(len(retvals['parameter'])):
    print('{}: {}'.format(retvals['parameter'][i], retvals['value'][i]))

# -------------------------------------------------------------------------
# 2. vstload and vstunload
# a. load it with command line arguments
# load plugin to outr two tracks by command line. NOTE: when loading with
# all arguments in command line, then the return values are not very
# interesting, since we have passed them. But they may be interesting when
# loading a plugin by configfile (see below)
soundmexpro('vstload',                              # command name
            {
            'filename' : '..\plugins\HtVSTGain.dll',# filename of plugin
            'type' : 'track',                       # plugin type ('master' is default)
            'input' : [0, 1],                       # inputs to use
            'output' : [0, 1],                      # outputs to use
            'position' : 0                          # vertical position (layer) where to load plugin to
            }
)
# b. unload it again
soundmexpro('vstunload',        # command name
            {
            'type' : 'track',   # plugin type ('master' is default)
            'input' : 0,        # one of the inputs where plugin is loaded to 
            'position' : 0      # vertical position (layer) where plugin is loaded to
            }
)

# c. load it by config file showing 'commandline supersedes config' as well
retvals = soundmexpro(  'vstload',                      # command name
                        {
                        'configfile' : 'vst_config.ini',# name of config file
                        'position' : 0                  # vertical position (layer) where to load plugin to: NOTE in config position is 1!
                        }
)

# verify correct position
if retvals['position'] != 0:
    raise ValueError('position is unexpectedly not 0 here...')
    
# -------------------------------------------------------------------------
# 3. vstprogram and vstprogramname
# NOTE the difference between 'vstprogram' and 'vstprogramname': 
#   the command 'vstprogram' selects one of the programs of the plugin (if the 
#   plugin itselft supports different programs at all)
#   the command 'vstprogramname' does not select a new program by name, it renames
#   the current program! The plugin itself has to support this renaming, otherwise 
#   the command will fail.
print('');
# - retrieve current program. NOTE: was set to 'log' by configfile above!
retvals = soundmexpro(  'vstprogram',       # command name
                        {
                        'type' : 'track',   # plugin type ('master' is default)
                        'input' : 0,        # one of the inputs where plugin is loaded to 
                        'position' : 0      # vertical position (layer) where plugin is loaded to
                        }
)
print('current program is {}. Now switching...'.format(retvals['program']))

# - set current program. 
retvals = soundmexpro(  'vstprogram',       # command name
                        {
                        'program' : 'lin',  # program name
                        'type' : 'track',   # plugin type ('master' is default)
                        'input' : 0,        # one of the inputs where plugin is loaded to 
                        'position' : 0      # vertical position (layer) where plugin is loaded to
                        }
)
print('current program is {}. '.format(retvals['program']))

# -------------------------------------------------------------------------
# 4. vstparam
print('');
# a. retrieve values of all parameters. NOTE: 'gain_0' was set to 0.8 by
# configfile above
retvals = soundmexpro(  'vstparam',         # command name
                        {
                        'type' : 'track',   # plugin type ('master' is default)
                        'input' : 0,        # one of the inputs where plugin is loaded to 
                        'position' : 0      # vertical position (layer) where plugin is loaded to
                        }
)
print('current parameter values:');
for i in range(len(retvals['parameter'])):
    print('{}: {}'.format(retvals['parameter'][i], retvals['value'][i]))

# b. set and retrieve multiple parameters (here 'gain_0' and 'gain_2')
retvals = soundmexpro(  'vstparam',                         # command name
                        {
                        'parameter' : ['gain_0', 'gain_2'], # parameters to set
                        'value' : [0.2, 0.5],               # values to set
                        'type' : 'track',                   # plugin type ('master' is default)
                        'input' : 0,                        # one of the inputs where plugin is loaded to 
                        'position' : 0                      # vertical position (layer) where plugin is loaded to
                        }
)
print('New parameter values after switching are:');
for i in range(len(retvals['parameter'])):
    print('{}: {}'.format(retvals['parameter'][i], retvals['value'][i]))

# -------------------------------------------------------------------------
# 5. vststore
# store these values in an inifile
# - delete it in case it exists
if os.path.isfile('vst_config_test.ini'):
    os.remove('vst_config_test.ini')

soundmexpro('vststore',                             # command name
            {
            'configfile' : 'vst_config_test.ini',   # name of config file
            'type' : 'track',                       # plugin type ('master' is default)
            'input' : 0,                            # one of the inputs where plugin is loaded to 
            'position' : 0                          # vertical position (layer) where plugin is loaded to
            }
)

# -------------------------------------------------------------------------
# 6. vstset
print('');
# load a second plugin, this time as master plugin at position 0 (both
# default)
soundmexpro('vstload',                              # command name
            {
            'filename' : '..\plugins\HtVSTGain.dll',# filename of plugin
            'input' : [0, 1],                       # inputs to use
            'output' : [0, 1]                       # outputs to use
            }
)


# show current values of parameters
retvals = soundmexpro(  'vstparam',         # command name
                        {
                        'input' : 0,        # one of the inputs where plugin is loaded to 
                        'position' : 0      # vertical position (layer) where plugin is loaded to
                        }
)
print('current parameter values for master plugin are:');
for i in range(len(retvals['parameter'])):
    print('{}: {}'.format(retvals['parameter'][i], retvals['value'][i]))

# now use config file created above in 'vststore' example to set values.
# To do this we must 'overload' the type ('track' was written to file, we
# want to set 'master' plugin!!)
soundmexpro('vstset',                               # command name
            {
            'configfile' : 'vst_config_test.ini',   # name of config file
            'type' : 'master'                       # plugin type ('master' is default)
            }
)

# show current values of parameters
retvals = soundmexpro(  'vstparam',         # command name
                        {
                        'input' : 0,        # one of the inputs where plugin is loaded to 
                        'position' : 0      # vertical position (layer) where plugin is loaded to
                        }
)
print('Parameter values after using "vstset" for master plugin are:');
for i in range(len(retvals['parameter'])):
    print('{}: {}'.format(retvals['parameter'][i], retvals['value'][i]))

# delete configfile again
if os.path.isfile('vst_config_test.ini'):
    os.remove('vst_config_test.ini')
    
# -------------------------------------------------------------------------
# 7. vstedit
# unload the track plugin again
soundmexpro('vstunload',        # command name
            {
            'type' : 'track',   # plugin type ('master' is default)
            'input' : 0,        # one of the inputs where plugin is loaded to 
            'position' : 0      # vertical position (layer) where plugin is loaded to
            }
)

# play some audio data
soundmexpro('loadfile',                             # command name
            {
            'filename' : '../waves/eurovision.wav', # filename
            'loopcount' : 0                         # loopcount
            }
)

print('Now the editor of the plugin is shown. You can change values by "moving"');
print('the blue value bars with the mouse. NOTE: only first two channels are used');
print('in this example! You can change the program with the menu to "log" to apply');
input('log gains (display will change accordingly). Hit a key to show the editor.'); 

# show VST-Editor
soundmexpro('vstedit',          # command name
            {
            'type' : 'master',  # plugin type ('master' is default)
            'input' : 0,        # one of the inputs where plugin is loaded to 
            'position' : 0      # vertical position (layer) where plugin is loaded to
            }
)

# show visualization
soundmexpro('show')

# start playback
soundmexpro('start')

input('Hit a key to quit example')

