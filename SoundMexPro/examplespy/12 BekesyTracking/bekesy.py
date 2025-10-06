#
#                    Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
# This example shows how to use a VST (sine generator) plugin to implement a
# Bekesy-Tracking procedure. 
#
# NOTE: here the user interation (feedback) is done by spacebar press/release
#
# In an (endless) loop the current frequency and level is displayed and an indicator
# shows the current status of client response
#
# NOTE: after starting the example you hear 125 Hz at 0 dB attenuation. Pressing AND
# holding the spacebar lowers the level. Then release the spacebar if you don't hear 
# the initial tone any more. After releasing the sine sweep starts and the level is 
# raised until the space bar is pressed again, then level is lowered again....

import sys
import time
import numpy 
import math
import matplotlib.pyplot as plt 
import threading


# ------------------------------------------------------------------------------------------
# set some properties of the test
startfreq  = 125      # start frequency in Hz
stopfreq   = 8000     # stop frequency in Hz
sweeptime  = 300      # time in seconds for complete frequency sweep
dBperSec   = 2.5      # level change per second
samplerate = 44100    # samplerate to use
minlevel   = -80      # minimum level in dB to use (maximum is 0 dB) in dB fullscale
# ------------------------------------------------------------------------------------------


# append path to SoundMexPro\bin
sys.path.append('..\\..\\bin')
# import soundmexpro
from soundmexpro import soundmexpro
 

# global flags used for starting/stopping measurement(see below)
sweepstarted = 0
stopcondition = 0
# flag for current level direction (up/down)
increaselevel = 1

# global figure (and axis)
fig, ax = plt.subplots()

# create an indicator if spacebar is currently pressed (lime) or released (red) in the upper
# right corner of the plot
textindicator = ax.text(0.85, 0.95, 'huhu', color='red', transform=ax.transAxes, fontsize=14,
    verticalalignment='top', bbox={'facecolor' :'red'})

# functions
# -------------------------------------------------------------
# function to set frequency within VST plugin
def set_frequency(value):
    soundmexpro('vstparam',        
                {
                'type' : 'track', 
                'parameter' : 'frequency',
                'value' : float(value)/22050
                }
    )
# -------------------------------------------------------------

# -------------------------------------------------------------
# function to set color of indicator
def set_indicator(value):
    global textindicator
    textindicator.set_color(value)
    textindicator.set_bbox({'facecolor' : value}) # text inside the edit box
# -------------------------------------------------------------


# -------------------------------------------------------------
# measurement procedure as a function
# -------------------------------------------------------------
def measurement():
    # access global variables declared above
    global stopcondition
    global sweepstarted
    global startfreq  
    global stopfreq   
    global sweeptime  
    global dBperSec   
    global samplerate 
    global minlevel   
    global ax

    
    # NOTE: other than in MATLAB/Octave SoundMexPro raises an error if a command fails, thus
    # no need to check a return value after each SoundMexPro command. If you want to change 
    # this behaviour please edit ..\bin\soundmexpro.py (look for AssertionError)

    # read settings from tutorial
    sys.path.append('..\\..\\tutorialpy')
    from t_00b_init_tutorial import smp_get_cfg
    # get config 
    # NOTE: flag 0 will remove inputs, returned dictionary will hold driver and output only, 
    # i.e. suitable for 'init' directly
    smp_cfg = smp_get_cfg(0)
    # force fix samplerate
    smp_cfg['samplerate'] = samplerate
    # init with first two outputs
    soundmexpro('init', smp_cfg)    

    # load the plugin to first track only, i.e. sine is only generated/played
    # on first channel. Change here to measure the other ear
    soundmexpro('vstload',                   # command name
                {
                'filename' : '../../plugins/HtVSTSine.dll', # plugin name
                'type' : 'track',                           # type of plugin
                'input' : [0],                              # inputs to use
                'output' : [0]                              # outputs to use
                }
    )

    # initialize frequency with startfreq 
    frequency = startfreq
    # set in in plugin
    set_frequency(frequency)

    # start playback
    soundmexpro('start', {'length' : 0})     # play zeros endlessly, plugin will generated sine

    # set while-loop speed
    loopspeed = 0.1
    # calculate frequency increment per loop 
    freqincrement = (stopfreq-startfreq) / sweeptime * loopspeed
    # calculate level increment/decrement per loop to change level by
    # dBperSec per second
    levelincrementfactor =  2 -(10**(loopspeed*dBperSec/20))
    # convert min level in dB to linear volume
    minlevelfactor = 10**(minlevel/20)
    # initialize data: frequencies, levels and line plot
    freqs   = [startfreq]
    levels  = [0]
    line,   = ax.plot(freqs, levels, 'r-')
    
    counter = 0
    # run a loop where we adjust level and frequency
    while stopcondition == 0:
        time.sleep(loopspeed)
        
        # check if device is still running: if not, then some fatal error
        # may have stopped the device and we have to break the endless loop!
        retvals = soundmexpro('started')
        if retvals['value'] != 1:
            raise ValueError('device unexpectedly stopped')

        # retrieve current volume
        retvals = soundmexpro('volume');
        oldvolume = retvals['value'][0]
        # increase or decrease level respectively
        if increaselevel == 0:
            newlevel = oldvolume * levelincrementfactor
        else:
            newlevel = oldvolume / levelincrementfactor
        
        # apply constraints (0dB to settings.minlevel, i.e. linear factor from
        # 1 to minlevelfactor
        if newlevel > 1:
            newlevel = 1
        elif newlevel < minlevelfactor:
            newlevel = minlevelfactor
        
        # update level in soundmexpro only if it has changed
        if newlevel != oldvolume:
            soundmexpro('volume', {'value' : newlevel})
            
        # set frequency if seep started at all
        if sweepstarted:            
            frequency = frequency + freqincrement
            set_frequency(frequency)

        # adjuts display of level and frequency on every third loop
        
        if counter % 3 == 0:
            # calculate level in dB fullscale
            leveldB = 20*math.log10(newlevel)
            s = 'Press spacebar while tone is audible, otherwise release it.\nFreq: %0.f Hz, Level: %.1f dB' % (frequency, leveldB)
            fig.suptitle(s)
            
            # append level and frequency to arrays
            freqs.append(frequency)
            levels.append(leveldB)
            # update line plot's data
            line.set_xdata(freqs)
            line.set_ydata(levels)
            # force update
            fig.canvas.draw()
            
        counter = counter + 1

    # exit after loop is done
    soundmexpro('exit')
# -------------------------------------------------------------


# -------------------------------------------------------------
# Create the GUI....
def CreateGUI():
   
    global stopcondition
    global startfreq  
    global stopfreq   
    global minlevel   
   
    def stop(event):
        # break the loop in measurement() by setting global variable
        global stopcondition
        stopcondition = 1

    def on_press(event):
        if event.key == ' ':
            # set global variable to lower level now
            global increaselevel
            increaselevel = 0
            # update color of indicator
            set_indicator('lime')
    def on_release(event):
        if event.key == ' ':
            # set global variable to lower level now AND set variable
            # that sweep is to be started (applies only on first release 
            # of space bar)
            global increaselevel
            global sweepstarted
            increaselevel = 1
            sweepstarted = 1
            # update color of indicator
            set_indicator('red')

    
    plt.subplots_adjust(bottom=0.2)
    
    # set initial title of plot
    s = 'Press spacebar while tone is audible, otherwise release it.\nFreq: %0.f Hz, Level: 0.0 dB' % (startfreq)
    fig.suptitle(s)
    
    # attach callbacks handling space bar press/release
    fig.canvas.mpl_connect('key_press_event', on_press)
    fig.canvas.mpl_connect('key_release_event', on_release)
    
    # set axis properties
    plt.xlabel("Frequency [Hz]")
    plt.xlim(startfreq, stopfreq)
    plt.ylabel("Level [dB fullscale]")
    plt.ylim(minlevel, 0)
       
    # create the 'stop' button
    axstop = plt.axes([0.15, 0.02, 0.7, 0.075])
    bstop = plt.Button(axstop, 'STOP')
    bstop.on_clicked(stop)

    plt.show()
    # break the loop in measurement() by setting global variable
    stopcondition = 1
# -------------------------------------------------------------

# -------------------------------------------------------------
# main function creating separate thread for measurement 
def main():
    mthread = threading.Thread(target=measurement)
    mthread.start()
    CreateGUI()
    mthread.join()
# -------------------------------------------------------------

# go!
main()

