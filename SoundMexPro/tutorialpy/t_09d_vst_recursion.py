#
#                    Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
#
# This example shows usage of a VST plugin with recurse wiring in SoundMexPro. 
# The gain plugin shipped with SoundMexPro is used for this example.
#
# SoundMexPro commands introduced/used in this example:
#   vstload with parameters 'recursechannel' and 'recursepos'

# This example for the configuration of a recursion in the VST plugin
# host is a very simple (dummy) example: it simply loads the gain plugin
# shipped with SoundMexPro using for channels of it. Two tracks playing a 
# each playing a sine signal will be mapped to the first two inputs
# (indices  0 and 1) of the plugin. The corresponding outputs of the plugin 
# are connected to the SoundMexPro connected to the output channels  0 and 1
# (standard). The 3rd and 4th plugin inputs (indices 2 and 3) are configured 
# for recursion (value -1 in 'input' vector in 'vstload'-command. With the
# parameters 'recursechannel' and 'recursepos' they are configured to use
# the first two outputs (!) of the plugin as input: imagine as if 'wires'
# connect the first two plugins outputs to the 3rd and 4th input of the
# same plugin:


#                   INPUTS
#
#           0      1      2      3   
#           |      |      
#           |      |      ----------------------       
#           |      |      |                    |
#           |      |      |      ----------    |
#           |      |      |      |        |    |
#         --------------------------      |    |
#        |                          |     |    |
#        |                          |     |    |
#        |                          |     |    |
#        |          PLUGIN          |     |    |
#        |                          |     |    |
#        |                          |     |    |
#        |                          |     |    |
#         --------------------------      |    |
#           |      |      |      |        |    |
#           |      |      |      |        |    |
#           |      |      2      3        |    |
#           |      |                      |    |
#           |      |-----------------------    |   
#           |      |      recursion 'wire'     |
#           |      1                           |      
#           |                                  |     
#           |-----------------------------------
#           |          recursion 'wire' 
#           0            
#
#                   OUTPUTS 
#
# With this wiring the outputs 0 and 1 are 'copied' to the inputs 2 and 3
# (with one buffer delay, soee SoundMexPro manual). The effect is
# demonstrated below by changinge the gains of the four plugin channels:
# changing the gain of channels 0 (or 1) 1 will affect the total output gains
# of output tracks 0 AND 2 (or 1 and 3) because the outputs (!) are copied,
# thus lowering the gain in plugin channel 0 will lower the input (i.e. the
# gain of the data copied to input 2) in plugin channel 2. Changing the
# gain in channel 2 (or 3) will only affect that channel itself.

# This example is some kind of 'artificial' to demonstrate recursive
# wiring. To make 'real' use of recursion you will need VST plugins that
# expect recursive inputs e.g. adaptive filter plugins.



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
# init with first four outputs: may fail, if driver has not four channels!
smp_cfg['output'] = [0, 1, 2, 3]
soundmexpro('init', smp_cfg)    

# show visualization
soundmexpro('show')

# load signal with two sine tones to first two tracks
soundmexpro('loadfile',                             # command name
            {
            'filename' : '../waves/900l_450r.wav',  # filename
            'track' : [0, 1],                       # tracks
            'loopcount' : 0                         # endless loop 
            }
)

# load the plugin
soundmexpro('vstload',                                  # command name
            {
            'filename' : '../plugins/HtVSTGain.dll',    # plugin filename
            'type' : 'track',                           # plug it into tracks
            'input' : [0, 1, -1, -1],                   # input configuration: first two channels use first two tracks, 3rd and fourth do recursion
            'recursechannel' : [0, 1],                  # recursion: first recursion channel (i.e. first plugin input with '-1' in 'input' vector: 
                                                        # index 2) reads from channel 0, second from channel 1
            'recursepos' : [0, 0],                      # both recursion channels read AFTER plugin 0 (this plugin itself)
            'output' : [0, 1, 2, 3]                     # output configuration: 'straight' wiring of the four tracks
            }
)

# start
soundmexpro('start')

# ... and show VST editor
soundmexpro('vstedit', {'type' : 'track'})

# print info ...
print('The VST editor is shown next: change the gains of the first four channels and');
print('watch the effects in the output visualization (see comment in script above)');
input('Press a key to quit example.');

