% 
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
% 
% This example shows usage of the tool scripts soundmexpro_showdevs.m,
% soundmexpro_showcfg.m and soundmexpro_trackmap.m located in the BIN
% subdirectory of SoundMexPro. These scripts may be usefull to check
% available hardware or your current SoundMexPro configuration after
% 'init' and to 'generate' command parameters for 'init' or 'trackmap'
% respectively
%
% SoundMexPro commands introduced in this example:
%   iostatus


% call tutorial-initialization script
t_00b_init_tutorial

%% 1. soundmexpro_showdevs. This script shows a figure containing a listbox
% with all ASIO driver names installed on the system and below two
% listboxes with available output and input channels respectively. Click a
% driver name to show it's available channels. Then select one ore more
% input and output channels and click 'Ok'

[drv, chnlOut, chnlIn] = soundmexpro_showdevs;
% show an 'init' command that might be built from this return values
smp_disp('your selection may be used for an init-command like:');
str = sprintf('soundmexpro(''init'',...\n\t\t\t''driver'', ''%s'', ...\n\t\t\t''output'', [%s],...\n\t\t\t''input'', [%s]);', drv, num2str(chnlOut), num2str(chnlIn));
smp_disp(str);


%% 2. soundmexpro_showcfg. This script shows a figure containing information
% about the currently used driver, input and output channels and the track
% and IO-configuration
% NOTE: this example requires a soundcard with at least four output and two
% input channels

% A. 'simple' configuration without user defined track mapping and without
% any I/O configuration
if 1 ~= soundmexpro('init', ... % command name
        'driver', smpcfg.driver , ...  % driver index
        'output', [0 2 3], ...  % output channels to use. NOTE: here we 'skip' channel 1, we use soundcard channels 1, 3 and 4
        'input', [0 1], ...     % input channels to use (default would be -1: no input at all)
        'track', 6 ...          % use six tracks with default (cyclic) mapping
        )
    error(['error calling ''init''' error_loc(dbstack)]);
end


% go. Now you should see three used output channels in the upper left
% listbox. SoundMexPro indices 0, 1, 2, hardware names depend on used
% soundcards but usually contain a channel index. If so, should be 1, 3, 4.
% Input listbox on upper right must contain two channels (first two of
% soundcard). Lower track listbox must contain six lines each starting with
% track index (0..5) followed by SoundMexPro ouput channel index, where
% track is connected to and the corresponding souncard channel name. Since
% we use default 'cyclic' mapping the indices should be in this order
% 0  0:  SOUNDCARDCHANNELNAME_1     -
% 1  1:  SOUNDCARDCHANNELNAME_3     -
% 2  2:  SOUNDCARDCHANNELNAME_4     -
% 3  0:  SOUNDCARDCHANNELNAME_1     -
% 4  1:  SOUNDCARDCHANNELNAME_3     -
% 5  2:  SOUNDCARDCHANNELNAME_4     -
% where SOUNDCARDCHANNELNAME_? is the same name as in output channel listbox
% (returned by driver, soundcard dependant) and '?' may be the number of
% the channel contained in the returned name. The final '-' shows, that no
% inputs are connected to the tracks.
soundmexpro_showcfg;
smp_disp('press a key to continue');
userinteraction;

close all;
%% B1. 'sophisticated' configuration where we change the track mapping and
% configure some I/O channels
% change trackmap: 
% - first four tracks all mapped (mixed) to second SoundMexPro channel
%   (index 1, which is third soundcard channel)
% - fifth track mapped to third SoundMexPro channel
%   (index 2, which is fourth soundcard channel)
% - sixth track mapped to fourth SoundMexPro channel
%   (index 0, which is first soundcard channel)
if 1 ~= soundmexpro('trackmap', ...
    'track', [1 1 1 1 2 0] ...        % new mapping
    )
    error(['error calling ''trackmap''' error_loc(dbstack)]);
end

% setup I/O configration. NOTE: the command 'iostatus' is introduced/used
% in tuorial t_06_direct_io.m in detail. Here we 'simply' use it. The
% command 'connects' input channels to tracks, i.e. the data from the
% soundcard input are added to the corresponding track
% - connect input 0 to tracks 0 and 2
if 1 ~= soundmexpro('iostatus', ...
    'input', [0], ...
    'track', [0 2] ...
    )
    error(['error calling ''iostatus''' error_loc(dbstack)]);
end
% - additionally connect input 1 to track 2 (so input 0 and 1 are added
%   to track 2!)
if 1 ~= soundmexpro('iostatus', ...
    'input', [1], ...
    'track', [2] ...
    )
    error(['error calling ''iostatus''' error_loc(dbstack)]);
end


% go again. Upper two listboxes (used inpout and output channels) are
% identical to upper example: 'hardware' wiring was not changed.
% Lower track listbox must contain six similar line, but this time shows
% the changed track mapping:
% 0  1:  SOUNDCARDCHANNELNAME_3     0
% 1  1:  SOUNDCARDCHANNELNAME_3     -
% 2  1:  SOUNDCARDCHANNELNAME_3     0,1
% 3  1:  SOUNDCARDCHANNELNAME_3     -
% 4  2:  SOUNDCARDCHANNELNAME_4     -
% 5  0:  SOUNDCARDCHANNELNAME_1     -
% Tracks 0 and 1 show the SoundMexPro (!) indices of the input channels
% that are connected: Track 0 'uses' input samples from channel 0 (first
% soundcard channel, see input channel listbox on top right), track 2
% 'uses' input samples from channel 0 and channel 1 (first and second
% soundcard channel)
soundmexpro_showcfg;
smp_disp('press a key to continue');
userinteraction;
close all;

%% B2. soundmexpro_trackmap. This script shows a figure containing information
% about current track mapping and available output channels and allows to
% generate a new track mapping: the corresponding value for parameter
% 'track' of command 'trackmap' is returned
clear soundmexpro;
% new clean init with four channels, eight tracks
if 1 ~= soundmexpro('init', ...     % command name
        'driver', smpcfg.driver , ...  % driver index
        'output', [0 1 2 3], ...    % output channels to use. 
        'track', 8 ...              % use eight tracks with default (cyclic) mapping
        )
    error(['error calling ''init''' error_loc(dbstack)]);
end

% go. Figure shows tracks and trackmapping on the left with default cyclic
% trackmapping
% 0  0:  SOUNDCARDCHANNELNAME_1
% 1  1:  SOUNDCARDCHANNELNAME_2
% 2  2:  SOUNDCARDCHANNELNAME_3
% 3  3:  SOUNDCARDCHANNELNAME_4
% 4  0:  SOUNDCARDCHANNELNAME_1
% 5  1:  SOUNDCARDCHANNELNAME_2
% 6  2:  SOUNDCARDCHANNELNAME_3
% 7  3:  SOUNDCARDCHANNELNAME_4
% Left listbox with available channels shows
% 0:  SOUNDCARDCHANNELNAME_1
% 1:  SOUNDCARDCHANNELNAME_2
% 2:  SOUNDCARDCHANNELNAME_3
% 3:  SOUNDCARDCHANNELNAME_4
% then change track mapping by selecting one ore more tracks in left list
% and map them to an output channel by selecting it in the right list
% afterwards. You may repeat this muliple times. Then click 'Ok'
trackmap = soundmexpro_trackmap;
% apply new returned trackmap
if 1 ~= soundmexpro('trackmap', ...
    'track', trackmap ...        % new mapping
    )
    error(['error calling ''trackmap''' error_loc(dbstack)]);
end
% call soundmexpro_showcf to show new mapping
soundmexpro_showcfg;
smp_disp('press a key to continue');
userinteraction;


close all;
drawnow;
clear soundmexpro;


