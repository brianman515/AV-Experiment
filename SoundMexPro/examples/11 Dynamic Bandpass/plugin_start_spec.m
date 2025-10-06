%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
%
% 
% t_07b_realtime_plugin_spec.m shipped with SoundMexPro. It is called on
% intialization of the script plugin and must return '1' on success or
% other values on error. It receives the number of input and output
% channels and the number of samples in each channel to be expected in
% later calls to the processing script.
%

function retval = plugin_start_spec(inchannels, outchannels, samples)

% Here the sfst is initialized. Change the fftlen and windowlen as needed.
% The stft will pad (fftlen-windowlen)/2 zeros. For each short time
% spectrum the user definded function 'userfcn' is called: adjust name if
% you want and implement your processing there. For more information see
% smp_stftinit.m

% define global userdata in same size as we expect them in processing
% function and initialize them
global userdata;
userdata = zeros(100, outchannels);


% read startup data written by test.m
load plugin.mat 

% define global buffers for extracting magnitude and phase of spectrum and
% initialize them with correct size. 
global stft_mag stft_phase;
stft_mag = zeros(plugin.fftlen,2);
stft_phase = zeros(plugin.fftlen,2);


% initialize stft
smp_stftinit(samples, ...            % never change this: this is the 'outer' buffer size for the stft
             plugin.fftlen,  ...     % fftlength read from plugin.mat
             plugin.windowlen, ...   % window read from plugin.mat. Descripton see above
             1, ...                  % we want to process only one channel
             'stft_userfcn' ...      % name of user defined function to be called to process the spectrum
        );

% return 'success'
retval = 1;
