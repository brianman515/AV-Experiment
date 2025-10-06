%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
%
% This example shows how check for and handle 'asynchroneous errors'. These
% errors are errors that do _not_ occur as immediate result of calling a
% SoundMexPro command e.g. due to a syntax error. Such errors are reported
% directly and can be checked for by evaluating the first return value of
% every SoundMex Pro command. 'Asynchroneous errors' occur while a sound
% device is running during the sound processing. They can occur at every
% time, but since no SoundMexPro command is called to force this error,
% SoundMexPro cannot report such an error immediately to MATLAB. Therefore
% such errors are stored and usually the device is stopped. After an
% asynchroneus error occurred, every command called afterwards will
% plot the error description, additionally all commands except ''exit',
% 'stop', 'resetasyncerror' and 'asyncerror' will fail. Usually such errors
% should not occur (if no hardware error occurs), except if a plugin
% (script plugin or VST plugin) returns an error during signal processing.
% In case of a script plugin you have to enable the visibility of the
% processing engine and check the error there (see also
% t_07a_realtime_plugin.m). 
% This example runs a script plugin that returns an error after several blocks
% were processed successfully
%
% SoundMexPro commands introduced in this example:
%   asyncerror
%   resetasyncerror


% call tutorial-initialization script
t_00b_init_tutorial

% initialize SoundMexPro with first ASIO driver, use two output, no input
% channels, with no pluginstart script and with an 'special' pluginproc
% script that returns only errors after processing several buffers (see
% processing script 'plugin_error.m' itself)
if 1 ~= soundmexpro('init', ...             % command name
        'driver', smpcfg.driver , ...       % driver index
        'output', smpcfg.output, ...        % list of output channels to use 
        'numbufs', 20, ...                  % set higher number of software buffers to avoid xruns
        'pluginproc', 't_08_async_errors_x_plugin_proc_error', ...   % name of MATLAB command to call for every buffer
        'pluginshow', 1, ...                % flag if to show processing MATLAB engine (debugging only!)
        'pluginkill', 1 ...                 % flag if to kill processing MATLAB engine on 'exit'
        )
    error(['error calling ''init''' error_loc(dbstack)]);
end

% show device visualization
if 1 ~= soundmexpro('show')
    error(['error calling ''show''' error_loc(dbstack)]);
end

% load a file 
if 1 ~= soundmexpro(  'loadfile', ...           % command name
        'filename', '../waves/sine.wav', ...    % name of wavefile
        'loopcount', 1000 ...                   % loop count
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

% start playback. 
if 1 ~= soundmexpro('start')
    error(['error calling ''start''' error_loc(dbstack)]);
end

% wait for playback to be finished: here it will be 'forced', because the
% error in the processing script will cause the playback to stop!
if 1 ~= soundmexpro('wait', 'mode', 'stop')
    error(['error calling ''wait''' error_loc(dbstack)]);
end

% check the asyncerror
[success, error, errtext] = soundmexpro('asyncerror');
if success ~= 1
    error(['error calling ''asyncerror''' error_loc(dbstack)]);
end
if error ~= 1
    error('unexpectedly there was no async error!' );
end

smp_disp(['The following error occurred: ' errtext{1}]);

% reset the error
if 1 ~= soundmexpro('resetasyncerror')
    error(['error calling ''reseterror''' error_loc(dbstack)]);
end

% done
clear soundmexpro;
