#
#             Setup script for the SoundMexPro tutorial
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
# Helper script for the SoundMexPro tutorials to select a sound card and
# sound card channels to be used for the tutorials
#

import sys
import time
import subprocess
import pip
import configparser

# ---- PREREQUISTITES FOR ALL TUTORIAL ----------------------------------------------------------------------
# function to install a package
def install(package):
    try:
        import package
    except ModuleNotFoundError:
        subprocess.check_call([sys.executable, "-m", "pip", "install", package])
	
# install packages needed by the tutorials 
try:
    # matplotlib
    try:
        # NOTE: matplotlib installs numpy if missing
        import matplotlib
    except ModuleNotFoundError:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "matplotlib"])
    # soundfile
    try:
        import soundfile
    except ModuleNotFoundError:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "soundfile"])
except:
    print('installing required packages failed: maybe you have to adjust the path for pip to be found')
    exit()
# -----------------------------------------------------------------------------------------------------------    

# Required Python libraries that are not part of the standard library
#   - numpy
import numpy 

# append path to SoundMexPro\bin
sys.path.append('..\\bin')
# import soundmexpro and 'isint'
from soundmexpro import soundmexpro
from soundmexpro import isint


# NOTE: other than in MATLAB/Octave SoundMexPro raises an error if a command fails, thus
# no need to check a return value after each SoundMexPro command. If you want to change 
# this behaviour please edit ..\bin\soundmexpro.py (look for AssertionError)

retvals = soundmexpro('getdrivers');
if len(retvals['driver']) == 0:
    raise ValueError('there are no ASIO drivers present in your system')

# show all available drivers and let user select one
for i in range(len(retvals['driver'])):
    print('({}) {}'.format(i, retvals['driver'][i]))
    
while 1:
    drv = input('Enter the index of the ASIO driver to be used and press enter: ')
    if isint(drv):
        drvindex = int(drv)
        if drvindex >= 0 and drvindex < len(retvals['driver']):
            break

drv = retvals['driver'][drvindex]

# show all available output channels and let user select two
retvals = soundmexpro('getchannels', {'driver' : drv})
for i in range(len(retvals['output'])):
    print('({}) {}'.format(i, retvals['output'][i]))

while 1:
    try:
        ch1, ch2 = input('Enter two indices of the output channels to be used seperated by a blank and press enter: ').split()    
    except:
        continue
        
    if isint(ch1) and isint(ch2):
        out_ch1index = int(ch1)
        out_ch2index = int(ch2)
        if  (   out_ch1index >= 0 and out_ch1index < len(retvals['output']) 
            and out_ch2index >= 0 and out_ch2index < len(retvals['output']) 
            and out_ch1index != out_ch2index):
            break

# show all available input channels and let user select two - optional
for i in range(len(retvals['input'])):
    print('({}) {}'.format(i, retvals['input'][i]))

in_channels = True
while 1:
    try:
        ch1, ch2 = input('Enter two indices of the input channels to be used seperated by a blank and press enter: ').split()
    except: 
        if 'y' == input('Invalid selection. Recording tutorials will not be available. Continue without input channels (y/n)? '):
            in_channels = False
            break
        else:        
            continue
            
    if isint(ch1) and isint(ch2):
        in_ch1index = int(ch1)
        in_ch2index = int(ch2)
        if  (   in_ch1index >= 0 and in_ch1index < len(retvals['input']) 
            and in_ch2index >= 0 and in_ch2index < len(retvals['input']) 
            and in_ch1index != in_ch2index):
            break
        else:
            if 'y' == input('Invalid selection. Recording tutorials will not be available. Continue without input channels (y/n)? '):
                in_channels = False
                break


config = configparser.ConfigParser()
config.read('t_smpcfg.ini')

print('')
print('The following selections were saved to inifile "t_smpcfg.ini" used in the tutorials:')

    
config['settings']['driver'] = drv
print('driver = {}'.format(drv))

ch = '[%d %d]' % (out_ch1index, out_ch2index)
config['settings']['output'] = ch
print('output = {}'.format(ch))
if in_channels:
    ch = '[%d %d]' % (in_ch1index, in_ch2index)
    config['settings']['input'] = ch
    print('input = {}'.format(ch))
else:    
    print('no input channels selected')
    
with open('t_smpcfg.ini', 'w') as configfile:    
    config.write(configfile)    

