%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
%
% This example shows how to process audio data buffer by buffer with a 
% MATLAB script (plugin) in realtime, i.e. while the data are played on a
% device. Additional user data can be passed between this processing script
% and the workspace (the workspace itself is unknown to the processing
% engine). NOTE: The processing script recieves all input and ouput data,
% so you may simple adapt this example for processing of recording data.
%
% The plugin processing script 't_07a_realtime_plugin_proc.m' does a simple
% scaling of the output data with the user data (see comments in file 
% t_07a_x_plugin_proc.m).
%
% SoundMexPro commands introduced in this example:
%   special parameters of command 'init' related to plugins, namely
%     - pluginstart
%     - pluginproc
%     - pluginuserdatasize
%     - pluginshow
%     - pluginkill
%   pluginsetdata
%   plugingetdata
%   xrun
%   dspload
%   dsploadreset


% call tutorial-initialization script
t_00b_init_tutorial

% initialize SoundMexPro with first ASIO driver, use two output, no input
% channels (default)
if 1 ~= soundmexpro('init', ...             % command name
        'driver', smpcfg.driver , ...           % driver index
        'output', smpcfg.output, ...       % list of output channels to use 
        'numbufs', 20, ...                  % set higher number of software buffers to avoid xruns
        'pluginstart', 't_07a_x_plugin_start', ...  % name of MATLAB command to call on startup. NOTE: must be in the MATLAB search path!!
        'pluginproc', 't_07a_x_plugin_proc', ...    % name of MATLAB command to call for every buffer. NOTE: must be in the MATLAB search path!!
        'pluginuserdatasize', 40, ...               % size of user data per channel (default is 100)
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
        'loopcount', 0 ...                      % endess loop
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

% start playback. NOTE: at the moment the plugin script 'plugin_proc.m'
% mutes the output, because the user data all are 0 on startup!
if 1 ~= soundmexpro('start')
    error(['error calling ''start''' error_loc(dbstack)]);
end
% reset dspload after start (may be high on first bufffer(s))
[success] = soundmexpro('dsploadreset');
if success ~= 1
    error(['error calling ''dsploadreset''' error_loc(dbstack)]);
end


% retrieve the user data directly once (then we have a matrix with correct
% dimensions for setting them again!)
[success, userdata] = soundmexpro('plugingetdata', ... % command name
        'mode', 'output' ...  % retrieve output user data (this is default)
        );
if success ~= 1
    error(['error calling ''plugingetdata''' error_loc(dbstack)]);
end

smp_disp('playing output muted by processing script');
% wait a little bit
pause(2);

% now set gains of the two channels to different values
userdata(1,1) = 0.8;
userdata(1,2) = 0.05;

if 1 ~= soundmexpro('pluginsetdata', ...    % command name
        'data', userdata, ...           % matrix with user data to se
        'mode', 'output' ...            % set output user data (this is default)
        )
        error(['error calling ''pluginsetdata''' error_loc(dbstack)]);
end
smp_disp('playing output now with different gains on the two channels');

% wait a little bit
pause(5);
% retrieve user data again to show current buffer counter
[success, userdata] = soundmexpro('plugingetdata', ... % command name
        'mode', 'output' ...  % retrieve output user data (this is default)
        );
if success ~= 1
    error(['error calling ''plugingetdata''' error_loc(dbstack)]);
end
smp_disp(['the processing script was called ' int2str(userdata(2,1)) ' times up to now']);

% check if xrun detection is supported for current fdriver model

 
[check_xruns, xrun] = soundmexpro('xrun');
if check_xruns ~= 1
    warning('NOTE: xrun detection not supported. Corresponding tests are skipped');
end

if check_xruns == 1
    % retrieve current xrun counters (number of buffers where dropouts occurred)
    [success, xrun] = soundmexpro('xrun');
    if success ~= 1
        error(['error calling ''xrun''' error_loc(dbstack)]);
    end
    smp_disp(['up to now there were ' int2str(xrun) ' xruns']);
end
% retrieve maximum dspload that occurred
[success, dspload, dsploadmax] = soundmexpro('dspload');
if success ~= 1
    error(['error calling ''dspload''' error_loc(dbstack)]);
end
smp_disp(['the maximum dspload was ' int2str(dsploadmax) '%']);
[success] = soundmexpro('dsploadreset');
if success ~= 1
    error(['error calling ''dsploadreset''' error_loc(dbstack)]);
end

if check_xruns == 1
    % now a we simulate xruns due to processing that is too slow! This can be
    % done by setting the userdata(2,2) to a value other than 0. Then the
    % processing script will do a pause on every call resulting in xruns that
    % should be detected by the system
    % now set gains of the two channels to different values
    smp_disp('now forcing xruns');
    userdata(2,2) = 1;
    if 1 ~= soundmexpro('pluginsetdata', ...    % command name
            'data', userdata, ...           % matrix with user data to se
            'mode', 'output' ...            % set output user data (this is default)
            )
        error(['error calling ''pluginsetdata''' error_loc(dbstack)]);
    end

    % wait a bit
    pause(3);

    % retrieve current xrun count (number of buffers where dropouts occurred)
    [success, xrun, proc_xruns, done_xruns] = soundmexpro('xrun');
    if success ~= 1
        error(['error calling ''xrun''' error_loc(dbstack)]);
    end
    smp_disp(['up to now there were ' int2str(xrun) ' xruns (' int2str(proc_xruns) ' in processing queue, ' int2str(done_xruns) ' in  visualization/recording to disk queue)']);

    % retrieve maximum dspload that occurred
    [success, dspload, dsploadmax] = soundmexpro('dspload');
    if success ~= 1
        error(['error calling ''dspload''' error_loc(dbstack)]);
    end
    smp_disp(['the maximum dspload was ' int2str(dsploadmax) '%']);
end

clear soundmexpro;
