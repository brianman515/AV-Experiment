#
# Example script for accessing RME FireFace UC TotalMix via MIDI commands
# from SoundMexPro. 
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
# Prerequisites:
# - A virtual MIDI driver (virtual loopback cable) e.g. LoopBe1 has to be
#   installed on te computer (http://nerds.de/en/loopbe1.html)
#   NOTE: LoopBe1 is only free for private use. For commercial purposes
#   it has to be purchased!
# - TotalMix must be set up to allow MIDI remote control:
#     - Select 'Settings' from 'Options' menu, select MIDI tab and select 
#       'LoopBe Internal MIDI' as MIDI in and 'None' as MIDI out
#     - In 'Options' menu select 'Enable MIDI control' (item must be checked)
#
# Introduced commands:
#   midiinit
#   midigetdrivers
#   midishortmsg
#   midiplaynote
#   midiexit
#

import sys
import time

# append path to SoundMexPro\bin
sys.path.append('..\\..\\bin')
# import soundmexpro
from soundmexpro import soundmexpro

# retrieve all drivers (nit really used here, just to show usage...)
retvals = soundmexpro('midigetdrivers');

# here you may want to check, if driver 'LoopBe Internal MIDI' is available
# in drivers. However, midiinit will fail with correesponding error
# message, if it's missing


# initialize MIDI driver. There is no need to initialize SoundMexPro itself
# to use the MIDI commands
soundmexpro('midiinit', {'driver' : 'LoopBe Internal MIDI'})

# send commands according to the RME FireFace UC manual, chapter 'MIDI
# Remote Control', paragraph 'MIDI Control'
# NOTE: here the HEX values are used (converted with hex2dec), because most
# MIDI documentations denote all bytes to be sent to MIDI in HEX

# NOTE: some 'pushbuttons' on TotalMix are toggle buttons (e.g. 'Mono',
# 'Master Mute' ....). Unfortunately these buttons can only be toggeled
# without knowing the current status! Thus we recommend to store the
# desired setings of TotalMix in a SnapShot (Mix) and load this Snapshot to
# be sure to have all settings as expected!

# 1. toggle 'Mono'
# sending a simple note on / note off. Here we use the defaults for
# 'volume' (127) and for 'channel' (0) which is fine for controlling
# TotalMix
input('Toggeling "Mono". Hit Enter to apply');
soundmexpro('midiplaynote', {'note' : int('0x2a', 16)})

input('Toggeling "Mono" back. Hit Enter to apply');

# 2. 'midiplaynote' is an simple wrapper for two subsequent
# 'midishortmsg' commands. To demonstrate this we toggle 'Mono' back again
# using two such commands
# a. HEX 90 means 'note on on first channel', 'midi1' is the note and
# 'midi2' is the volume (velocity)
soundmexpro('midishortmsg', 
            {
            'status' : int('0x90', 16), 
            'midi1'  : int('0x2a', 16), 
            'midi2'  : int('0x7f', 16)
            }
)
# b. HEX 80 means 'note off on first channel', 'midi1' is the note and
# 'midi2' is the volume (velocity)
soundmexpro('midishortmsg', 
            {
            'status' : int('0x80', 16), 
            'midi1'  : int('0x2a', 16), 
            'midi2'  : 0
            }
)

# 3. access a slider
# NOTE: the RME manual does not explicitly 'name' the control number for
# controlling the master volume, but it says, that the "Main Out" can be
# controlled with the "standard Control Change Volume" via MIDI channel 1
# Thus you have to use the hex values B0 for status (first midi channel)
# and 07 for midi1 (this is the midi number for "Main Volume" according to
# the General MIDI Standard Controller description.

# set master volume AND first playback volume to minimum, values of status,
# midi1 and midi2 according to RME manual
input('setting master volume and first playback channel volume to minimum. Hit Enter to apply');
soundmexpro('midishortmsg', 
            {
            'status' : int('0xb0', 16), 
            'midi1'  : int('0x07', 16), 
            'midi2'  : 0
            }
)

soundmexpro('midishortmsg', 
            {
            'status' : int('0xb4', 16), 
            'midi1'  : int('0x66', 16), 
            'midi2'  : 0
            }
)

# set master volume to maximum
input('setting master volume to maximum. Hit Enter to apply');
soundmexpro('midishortmsg', 
            {
            'status' : int('0xb0', 16), 
            'midi1'  : int('0x07', 16), 
            'midi2'  : int('0x7f', 16)
            }
)

# set master volume and first playback volume to 0 dB
input('setting master volume and first playback channel volume to 0dB. Hit Enter to apply');
soundmexpro('midishortmsg', 
            {
            'status' : int('0xb0', 16), 
            'midi1'  : int('0x07', 16), 
            'midi2'  : int('0x68', 16)
            }
)
soundmexpro('midishortmsg', 
            {
            'status' : int('0xb4', 16), 
            'midi1'  : int('0x66', 16), 
            'midi2'  : int('0x68', 16)
            }
)

# finally (re-)load Snapshot 1 (Mix 1)
input('Load Snapshot 1 (Mix 1). Hit Enter to apply');
soundmexpro('midiplaynote', {'note' : int('0x36', 16)})

# exit
soundmexpro('midiexit')



