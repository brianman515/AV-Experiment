%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
%
% This script is used as plugin startup script in the example
% t_07b_realtime_plugin_spec.m shipped with SoundMexPro. It is called on
% intialization of the script plugin and must return '1' on success or
% other values on error. It receives the number of input and output
% channels and the number of samples in each channel to be expected in
% later calls to the processing script.
% Do not call this script directly
%

function retval = t_07b_x_plugin_start(inchannels, outchannels, samples)


% define global userdata in same size as we expect them in processing
% function and initialize them
global userdata;



% Here the sfst is initialized. Change the fftlen and windowlen as needed.
% The stft will pad (fftlen-windowlen)/2 zeros. For each short time
% spectrum the user definded function 'userfcn' is called: adjust name if
% you want and implement your processing there. For more information see
% smp_stftinit.m
fftlen      = 512;
windowlen   = 400;

% set name of function (script) to call for each buffer within FFT
userfcn     = 't_07b_x_stft_userfcn';
% initialize stft
smp_stftinit(samples, ...        % never change this: this is the 'outer' buffer size for the stft
    fftlen,  ...        % see above
    windowlen, ...      % see above
    outchannels, ...    % we want to process all output cahnnels here
    userfcn ...         % see above
    );

% define global buffers for extracting magnitude and phase of spectrum and
% initialize them with correct size. In the processing script with name
% t_07b_x_stft_userfcn (see below) be always use these buffers. In this way
% the performance of the processing is optimized, because we don't have to
% allocate these buffers in each processing call again and again.
global stft_mag stft_phase;
stft_mag = zeros(fftlen,2);
stft_phase = zeros(fftlen,2);


% create frequency axis for the plot: 44kHz sampling rate
global vFreq;
vFreq  = (0:fftlen/2-1)' * (44100/fftlen);


% return 'success'
retval = 1;
