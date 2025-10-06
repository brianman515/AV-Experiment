%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
%
% This script is used as plugin startup script in the example
% t_07a_realtime_plugin.m shipped with SoundMexPro. Do NOT call it
% directly. It is called on intialization of the script plugin and must
% return '1' on success or other values on error. It receives the number of 
% input and output channels and the number of samples in each channel to be
% expected in later calls to the processing script.
 
%

function retval = plugin_start(inchannels, outchannels, samples)

% Here you may read initialization data (e.g. written by 'main' MATLAB
% programm to MAT-files). In this example we only plot the passed
% arguments. NOTE: this only becomes 'visible' after the first call to the
% processing script: the processing engine is 'blocking' and cannot be
% updated, moved...
smp_disp(' ');
smp_disp(' ');
smp_disp(['Used input channels: ' int2str(inchannels) ', output channels: ' int2str(outchannels) ', samples: ' int2str(samples)]);


% return 'success'
retval = 1;
