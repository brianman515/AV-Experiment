%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2016, written by Daniel Berg
%
%
% This script is used as plugin startup script in the example
% threshold_driven_playback.m shipped with SoundMexPro. It is called on
% intialization of the script plugin and must return '1' on success or
% other values on error. It initializes data for the plugin:
% - loads audio data
% - intializes data positions within audio data
% - intializes threshold values

function retval = tdp_plugin_start(inchannels, outchannels, samples)

% initialize global parameters to be used in processing script

% audio data. Here: create two different sine signals (300Hz and 500Hz, 
% 44100 samples length each) for the two channels
global audiodata;
audiodata = [0.5.*sin(([0:44100-1]' * 300 / 44100) .*2*pi) ...
             0.5.*sin(([0:44100-1]' * 500 / 44100) .*2*pi) ];

% position within audio data. 0 means: no playback now (look for trigger!
global datapos;
datapos = [0 0];

% thresholds: here set the values of your choice (may be changed later via
% user data passed to plugin...)
global threshold;
threshold = [0.5 0.5];

% return 'success'
retval = 1;
