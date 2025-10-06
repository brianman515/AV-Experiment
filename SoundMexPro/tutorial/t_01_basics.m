% 
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
% 
% This is the first example of the SoundMexPro tutorial. The tutorial shows
% examples for all commands of SoundMexPro. It starts with basic commands
% and simple tasks becoming more complex in later examples. It is
% recommended to go through all examples in order to find out about the
% extremely flexible commands and their options and get used to the best
% way to solve your task with SoundMexPro. The tutorial does not contain
% very sophisticated examples with 'mixed' tasks, so you may not find a
% complete solution to your problem here. But after going through the
% tutorial you may have a look at the 'advanced' examples that use a
% variety of SoundMexPro features within one task.
%
% This first example shows the very basic commands.
% NOTE: this example shows some paramaters of 'init' command. Most
% other examples use default parameters only! 
%
% SoundMexPro commands introduced in this example:
%   help
%   license
%   init
%   trackmap
%   initialized
%   exit
%   version
%   show
%   hide


% call tutorial-initialization script
t_00b_init_tutorial


%% 1. help
if 1 ~= soundmexpro('helpa')
    % NOTE: error_loc.m ('error location') is a helper script located in
    % same directory that appends the location of this error (file, line)
    % to the error message.
    error(['error calling ''help''' error_loc(dbstack)]);
end
smp_disp('Above a command list is shown in alphabetical order. Hit a key to continue');
userinteraction
clc

%% 2. help on specific command
if 1 ~= soundmexpro('help', 'volume')
    error(['error calling ''help''' error_loc(dbstack)]);
end

smp_disp('Above the online help for command ''volume'' is shown. Hit a key to continue');
userinteraction
clc

%% 3a. license (can be called before init)
[success, major, lictype] = soundmexpro('license');
% first check success of command
if 1 ~= success
    error(['error calling ''license''' error_loc(dbstack)]);
end
% then show license type. NOTE: third return value is a cell array! All 
% strings returned by SoundMexPro commands are cell arrays, except for
% command  'getlasterror'!
smp_disp(['You are running SoundMexPro major version ' num2str(major) ' with licence type: ' lictype{1}]);

%% 3b. init
smp_disp('initializing SoundMexPro');
[success, lictype] = soundmexpro('init', ...    % command name
    'driver', smpcfg.driver , ...               % enter a name here to load a driver by it's name
    'samplerate', 44100,...                     % samplerate to use (default is 44100)
    'numbufs', 10, ...                          % number of software buffers used to avoid xruns (dropouts, default is 10)
    'output', smpcfg.output, ...                % list of output channels to use 
    'input', smpcfg.input, ...                  % list of input channels to use
    'track', 4 ...                              % number of virtual tracks, here: four tracks
    );

% first check success of command
if 1 ~= success
    error(['error calling ''init''' error_loc(dbstack)]);
end
% then show license type. NOTE: second return value is a cell array! All 
% strings returned by SoundMexPro commands are cell arrays, except for
% command  'getlasterror'!
smp_disp(['You are running SoundMexPro with licence type: ' lictype{1}]);

%% 4. trackmap
% retrieve the current track mapping (i.e. default)
[success, trackmap] = soundmexpro('trackmap');
% first check success of command itself
if (~success)
    error(['error calling ''trackmap''' error_loc(dbstack)]);
end
% show mapping 
smp_disp('Default track mapping:');
for i = 1 : length(trackmap)
    smp_disp(['Virtual track no. ' num2str(i-1) ' is currently mapped to output channel no. ' num2str(trackmap(i))]);
end

% change mapping to map three virtual tracks (0, 1 and 3) to output channel
% 0 and the remaining track No. 2 to output channel 1
[success, trackmap] = soundmexpro('trackmap', ...
   'track', [0 0 1 0] ...        % new mapping
    );

% first check success of command itself
if (~success)
    error(['error calling ''trackmap''' error_loc(dbstack)]);
end

% show new mapping 
smp_disp(' ');
smp_disp('User defined track mapping:');
for i = 1 : length(trackmap)
    smp_disp(['Virtual track no. ' num2str(i-1) ' is currently mapped to output channel no. ' num2str(trackmap(i))]);
end
smp_disp('Hit any key to continue');
userinteraction

%% 5. initialized, exit
[success, initialized] = soundmexpro('initialized');
% first check success of command itself
if (~success)
    error(['error calling ''initialized''' error_loc(dbstack)]);
end
% then check second return value to check if device _is_ initialized (what
% we expect now!
if (~initialized)
    error('soundmexpro is unexpectedly not initialized!');
end
smp_disp('soundmexpro is now initialized');
% now exit again
smp_disp('exiting SoundMexPro');
if 1 ~= soundmexpro('exit')
    error(['error calling ''exit''' error_loc(dbstack)]);
end
% and check initialized status again
[success, initialized] = soundmexpro('initialized');
if (~success)
    error(['error calling ''initialized''' error_loc(dbstack)]);
end
if (initialized)
    error('soundmexpro is unexpectedly still initialized!');
end
smp_disp('soundmexpro is NOT initialized');


% finally call init again 
if 1 ~= soundmexpro('init', ...    % command name
        'driver', smpcfg.driver , ...  % enter a name here to load a driver by it's name
        'output', smpcfg.output, ...  % list of output channels to use 
        'input', smpcfg.input ...    % list of input channels to use
    )
    error(['error calling ''init''' error_loc(dbstack)]);
end

%% 6. version
[success, versionnumber] = soundmexpro('version');
% first check success of command itself
if (~success)
    error(['error calling ''version''' error_loc(dbstack)]);
end
% show version. NOTE: second return value is a cell array! All strings returned
% by SoundMexPro commands are cell arrays, except for command 'getlasterror'!
smp_disp(['You are running SoundMexPro version ' versionnumber{1} ]);


%% 7. show, hide
% NOTE: since SoundMexPro 2.0  this is identical to showmixer and hidemixer
% show visualization
if 1~= soundmexpro('show')
    error(['error calling ''show''' error_loc(dbstack)]);
end
smp_disp('Mixer/visualization now is visible. Hit any key to hide it again');
userinteraction

% hide visualization
if 1~= soundmexpro('hide')
    error(['error calling ''hide''' error_loc(dbstack)]);
end
smp_disp('Mixer/visualization now is hidden again. Hit any key to continue');
userinteraction


clear soundmexpro;
