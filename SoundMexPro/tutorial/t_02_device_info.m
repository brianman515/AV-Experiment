% 
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
% 
% This example shows how to retrieve information about the devices, their
% available channels and other device properties
% NOTE: this example shows as well some paramaters of 'init' command. Most
% other examples use default parameters only!
%
% SoundMexPro commands introduced in this example:
%   getdrivers
%   getdriverstatus
%   getchannels
%   getproperties
%   getactivedriver
%   getactivechannels
%   trackname
%   controlpanel



% call tutorial-initialization script
t_00b_init_tutorial

% A. start with commands, that do _not_ need an initialized SoundMexPro
%% 1. getdrivers
[success, drivers] = soundmexpro('getdrivers');
if (~success)
    % NOTE: error_loc.m ('error location') is a helper script located in
    % same directory that appends the location of this error (file, line)
    % to the error message
    error(['error calling ''getdrivers''' error_loc(dbstack)]);
end

if length(drivers) == 0
    error(['there are no ASIO drivers present in your system' error_loc(dbstack)]);
end

smp_disp([num2str(length(drivers)) ' ASIO drivers where found on the system:']);
drivers


%% 2. getdriverstatus
[success, driverstatus] = soundmexpro('getdriverstatus');
if (~success)
    error(['error calling ''getdriverstatus''' error_loc(dbstack)]);
end

smp_disp('The ASIO drivers have the following status (1=ok, 0=error):');
driverstatus


%% 3. getchannels of a driver 
[success, OutChannels, InChannels] = soundmexpro('getchannels', 'driver', smpcfg.driver);
if (~success)
    error(['error calling ''getchannels''' error_loc(dbstack)]);
end
smp_disp(['The ASIO driver "' smpcfg.driver '" has the following output and input channels:']);
OutChannels
InChannels

smp_disp('hit a key to proceed');
userinteraction;

%% B. Properties that need an initialized SoundMexPro. Again we use the
% first driver (initialized by index now). We only use two input and 
% output channels to get different return values for 'getchannels' and
% 'getactivechannels' 
if (length(OutChannels) < 2)
    error(['at least two output channels needed for proceeding' error_loc(dbstack)]);
end

%% 1. initialize SoundMexPro and ...
if 1 ~= soundmexpro('init', ...             % command name
        'driver', smpcfg.driver , ...       % driver index
        'output', smpcfg.output, ...        % list of output channels to use (default)
        'input', smpcfg.input, ...          % list of input channels to use
        'track', 4 ...
        )
    error(['error calling ''init''' error_loc(dbstack)]);
end

%% 2. retrieve current driver
[success, drivername] = soundmexpro('getactivedriver');
if (~success)
    error(['error calling ''getactivedriver''' error_loc(dbstack)]);
end

%% 3. retrieve properties 
[success, samplerate, buffersize, supported_rates, soundformat] = soundmexpro('getproperties');
if (~success)
    error(['error calling ''getproperties''' error_loc(dbstack)]);
end

% show properties. NOTE: drivername is a cell array! All strings returned
% by SoundMexPro commands are cell arrays, except for command 'getlasterror'!
smp_disp(['Device "' drivername{1} '" initialized with samplerate ' num2str(samplerate) ' Hz and buffer size is set to ' num2str(buffersize) ' samples']);
smp_disp(['Device will use this format for playback: ' soundformat{1}]);
smp_disp('It supports at least the following samplerates:');
supported_rates

%% 4. retrieve active channel names
[success, OutChannels, InChannels] = soundmexpro('getactivechannels');
if (~success)
    error(['error calling ''getactivechannels''' error_loc(dbstack)]);
end

smp_disp('The following output and input channels are initialized:');
OutChannels
InChannels

%% 5. show usage of 'trackname'. The commands 'channelname' and 'recname' are
% used in the same way, but for ouput channels and input channels
% respectively.
smp_disp(['The default track names are:']);
[success, tracknames] = soundmexpro('trackname');
if (~success)
    error(['error calling ''trackname''' error_loc(dbstack)]);
end
tracknames


% change output names 
[success, tracknames] = soundmexpro('channelname', 'name', {'myout1', 'out 2'});

% change tracknames 
% NOTE: track names must NEVER contain comma or semicolon!!
[success, tracknames] = soundmexpro('trackname', 'name', {'Noise left', 'Noise right', 'Signal front', 'other name'});
if (~success)
    error(['error calling ''trackname''' error_loc(dbstack)]);
end
smp_disp(['Now the user defined track names are:']);
[success, tracknames] = soundmexpro('trackname');
if (~success)
    error(['error calling ''trackname''' error_loc(dbstack)]);
end
tracknames

% now show the mixer to show, that tracknames are shown
if 1 ~= soundmexpro('showmixer')
    error(['error calling ''showmixer''' error_loc(dbstack)]);
end

% set volume of second track by using it's index
[success, tracknames] = soundmexpro('trackvolume', 'track', 1, 'value', 0.2);
if (~success)
    error(['error calling ''trackname''' error_loc(dbstack)]);
end

smp_disp('hit a key to proceed');
userinteraction;

% set volume of second track by using it's name
% NOTE: the name we want to use contains a blank!. Thus set parameter as
% cell array
[success, tracknames] = soundmexpro('trackvolume', 'track', {'Noise right'}, 'value', 1);
if (~success)
    error(['error calling ''trackname''' error_loc(dbstack)]);
end

smp_disp('hit a key to proceed');
userinteraction;

%% 6. show/starts drivers own control panel
[success] = soundmexpro('controlpanel');
if (~success)
    warning('error calling ''controlpanel''');
end

clear soundmexpro;
