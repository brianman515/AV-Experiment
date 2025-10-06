%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
%
% This example shows how to use compiled plugins in compiled applications.
% The example contains a very simple script that only scales two channels
% by factors from user data (similar to t_07a_realtime_plugin)
% Additionally the parameter 'pluginexe' is specified in command 'init'.
%
% Detailed comments and hints on compiling and debugging compiled scripts
% using compiled script plugins can be found in the file bin\SMPPlugin.m of
% the SoundMexPro installation.
%cd
% You can compile this example with command line.
%
%    mcc -m -a SoundDllPro.dll -a libsndfile-1.dll -a SMPIPC.exe -a soundmexpro MainScript
%
% NOTE: adjust the driver and channel settings below: here no error
% checking or whatsover is done!
%
% The plugin for this example can be compiled with command line
%
%   mcc -m -a plugin_start -a plugin_proc -a mpluginmex SMPPlugin
%

% initialize SoundMexPro with first ASIO driver, use two output, no input
% channels 
smpcfg.driver = 0;
smpcfg.output = [0 1];


if 1 ~= soundmexpro('init', ...             % command name
        'driver', smpcfg.driver , ...       % driver index
        'output', smpcfg.output, ...        % list of output channels to use 
        'pluginexe', 'SMPPlugin.exe', ...   % name of the compiled plugin-executable
... %        'pluginexe', 'testbatch.bat', ...   % name of testbatch. Use this line for debugging (see comment in batch file)
        'pluginstart', 'plugin_start', ...  % name of MATLAB command to call on startup. NOTE: must be in the MATLAB search path!!
        'pluginproc', 'plugin_proc', ...    % name of MATLAB command to call for every buffer. NOTE: must be in the MATLAB search path!!
        'pluginshow', 0, ...                % flag if to show processing MATLAB engine (debugging only!)
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
        'filename', '../../waves/sine.wav', ...    % name of wavefile
        'loopcount', 0 ...                      % endess loop
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

% start playback. NOTE: at the moment the plugin script 'plugin_proc.m'
% mutes the output, because the user data all are 0 on startup!
if 1 ~= soundmexpro('start')
    error(['error calling ''start''' error_loc(dbstack)]);
end

% retrieve the user data directly once (then we have a matrix with correct
% dimensions for setting them again!)
[success, userdata] = soundmexpro('plugingetdata', ... % command name
        'mode', 'output' ...  % retrieve output user data (this is default)
        );
if success ~= 1
    error(['error calling ''plugingetdata''' error_loc(dbstack)]);
end

disp('playing file muted (gain 0 set in plugin)');

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

disp('playing file with different gains on left and right channel');
% wait a little bit
pause(5);

% exit
clear soundmexpro;
