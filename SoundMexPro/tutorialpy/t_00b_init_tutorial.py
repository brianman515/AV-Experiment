#
#                    Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
# Helper script for the SoundMexPro tutorials. Called at the beginning of
# every tutorial script. Reads inifile t_smpcfg.ini and returns content
 
import configparser
import os

def smp_get_cfg(inputs):
    config = configparser.ConfigParser()
    config.read(os.path.dirname(__file__) + '\\t_smpcfg.ini')
    retvals = dict(config.items('settings'))
    # remove inputs if requested
    if inputs == 0:
        retvals.pop("input")    
    return retvals
    
    