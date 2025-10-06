%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2016, written by Daniel Berg
%
% This example shows how to use a MATLAB script plugin to do threshold
% driven playback
%

% call tutorial-initialization script
addpath('..\..\tutorial');
t_00b_init_tutorial


% initialize SoundMexPro with first ASIO driver, use two output, no input
% channels (default)
if 1 ~= soundmexpro('init', ...                             % command name
        'driver', smpcfg.driver, ...                        % driver index
        'output', smpcfg.output, ...                        % list of output channels to use
        'input',  smpcfg.input, ...                          % list of input channels to use
        'pluginstart', 'tdp_plugin_start', ...              % name of MATLAB command to call on startup. NOTE: must be in the MATLAB search path!!
        'pluginproc', 'tdp_plugin_proc', ...                % name of MATLAB command to call for every buffer. NOTE: must be in the MATLAB search path!!
        'pluginshow', 0, ...                                % flag if to show processing MATLAB engine (debugging only!)
        'pluginkill', 1 ...                                 % flag if to kill processing MATLAB engine on 'exit'
        )
    error(['error calling ''init''' error_loc(dbstack)]);
end

% set recpause: here we don't want to record to file at all
[success, values] = soundmexpro('recpause', 'value', 1);
if success ~= 1
    error(['error calling ''recpause''' error_loc(dbstack)]);
end

% retrieve the user data directly once (then we have a matrix with correct
% dimensions for setting them again below!)
[success, userdata] = soundmexpro('plugingetdata', ... % command name
    'mode', 'output' ...  % retrieve output user data (this is default)
    );
if success ~= 1
    error(['error calling ''plugingetdata''' error_loc(dbstack)]);
end


% start playback with 'length' 0 i.e. zeros are played
if 1~= soundmexpro('start', 'length', 0)
    error(['error calling ''start''' error_loc(dbstack)]);
end

% now do a loop where you may enter key 1/2 to simulate an exceeded
% threshold on one of the channels
disp('Enter 1 or 2 to simulate exceeded threshold on corresponding channel or other value to quit');
while (1)
    % clear user data
    userdata(:) = 0;
    val = input('Value: ');
    if (val == 1)
        % set simulation value for first channel (see tdp_plugin_proc.m)
        userdata(1,1) = 1;
    elseif (val == 2)
        % set simulation value for second channel (see tdp_plugin_proc.m)
        userdata(1,2) = 1;
    else
        break;
    end
    % pass the userdata to plugin
    if 1 ~= soundmexpro('pluginsetdata', ...    % command name
            'data', userdata, ...               % matrix with user data to se
            'mode', 'output' ...                % set output user data (this is default)
            )
        error(['error calling ''pluginsetdata''' error_loc(dbstack)]);
    end
end

clear soundmexpro;


