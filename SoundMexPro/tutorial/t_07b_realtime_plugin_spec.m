%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
%
% This example shows how to process audio data buffer by buffer with a 
% MATLAB script (plugin) in realtime, i.e. while the data are played on a
% device. In this example the smp_stft (short time fft) scripts shipped with
% SoundMexPro are introduced to implement a script plugin, that does
% processing in the frequency domain using a block-wise fft with
% overlapped add and zero padding
%
% The plugin script 't_07b_x_plugin_start.m' (name is variable and passed in init below)
% does the plugin initialization of the short time fft. The second plugin script 
% 't_07b_x_plugin_proc.m' (name is variable and passed in init below) is
% called for every wave buffer and calls the smp_stft scripts. The processing
% and plotting is done in the user defined spctrum-manipulation function
% stft_userfcn.m (name is variable and set in t_07b_x_plugin_start.m).
% It plots every 30th fft before and after processing and does a very
% simple boost of some frequency bins.
%


% call tutorial-initialization script
t_00b_init_tutorial

% initialize SoundMexPro with first ASIO driver, use two output, no input
% channels (default).
% NOTE: for further explanations on this example see the scripts
% plugin_start_spec.m and plugin_proc_spec.m!!
if 1 ~= soundmexpro('init', ...                 % command name
        'driver', smpcfg.driver , ...               % driver index
        'output', smpcfg.output, ...           % list of output channels to use 
        'numbufs', 20, ...                      % set higher number of software buffers to avoid xruns
        'pluginstart', 't_07b_x_plugin_start', ... % name of MATLAB command to call on startup. NOTE: must be in the MATLAB seacrh path!!
        'pluginproc', 't_07b_x_plugin_proc', ...   % name of MATLAB command to call for every buffer. NOTE: must be in the MATLAB seacrh path!!
        'pluginshow', 1, ...                    % flag if to show processing MATLAB engine (debugging only!)
        'pluginkill', 1 ...                     % flag if to kill processing MATLAB engine on 'exit'
        )
    error(['error calling ''init''' error_loc(dbstack)]);
end


% load a file
if 1 ~= soundmexpro(  'loadfile', ...               % command name
        'filename', '../waves/eurovision.wav', ...  % name of wavefile
        'loopcount', 0 ...                          % endess loop
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end



% retrieve the user data directly once (then we have a matrix with correct
% dimensions for setting them again!)
[success, userdata] = soundmexpro('plugingetdata', ... % command name
        'mode', 'output' ...  % retrieve output user data (this is default)
        );
if success ~= 1
    error(['error calling ''plugingetdata''' error_loc(dbstack)]);
end


% start playback. NOTE: currently the processing is disabled in
% stft_userfcn.m!!
if 1 ~= soundmexpro('start')
    error(['error calling ''start''' error_loc(dbstack)]);
end

smp_disp('Playing file with inactive filter. Hit a key enable the filter');
userinteraction;

% now set first value in user data to 1 and pass them to plugin using
% 'pluginsetdata': stft_userfcn will read it and enable the filter!!
userdata(1,1) = 1;
if 1 ~= soundmexpro('pluginsetdata', ...    % command name
        'data', userdata, ...           % matrix with user data to se
        'mode', 'output' ...            % set output user data (this is default)
        )
        error(['error calling ''pluginsetdata''' error_loc(dbstack)]);
end


smp_disp('Playing file with active filter. Hit a key to quit the example');
if exist('fflush') > 0
    fflush(stdout);
end
userinteraction;
clear soundmexpro
