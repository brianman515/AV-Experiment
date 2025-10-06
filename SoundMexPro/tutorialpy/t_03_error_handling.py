#           Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
#       This example shows user defined error handling in SoundMex.  
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


# catch an error forced by calling an unknown command

try:
    soundmexpro('unknown')
except:    
    # retrieve the last error ('again': would be part of exception message as well, but 
    # here we want to show hov to retrieve it   
    retvals = soundmexpro('getlasterror')
    # show 'own' error    
    print('error returned from soundmexpro is: {}'.format(retvals['error']))
