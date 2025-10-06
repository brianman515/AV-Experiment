%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2010, written by Daniel Berg
%
%
% This script is used as plugin startup script in the example
% bekesy.m shipped with SoundMexPro. It is called on
% intialization of the script plugin and must return '1' on success or
% other values on error. It receives the number of input and output
% channels and the number of samples in each channel to be expected in
% later calls to the processing script.
%

function retval = sine_generator_plugin_start(inchannels, outchannels, samples)

% read MAT file with settings written by main file bekesy.m to global
% variable cfg (used in bekesy_plugin_proc)
global cfg;
cfg = load('bekesy.mat');

% return 'success'
retval = 1;
