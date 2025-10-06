%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
% The examples named t_04????? show usage of multiple commands related to
% playback of files and vectors with mixing (multiple tracks per channel),
% waiting, clipping ... They show similar playback situations with slightly
% different features to show different behaviour of SoundMexPro needed for
% different tasks.
%
% This example shows muting, 'solo-ing', and clearing data
%
% 
% SoundMexPro commands introduced in this example:
%   pause
%   mute
%   trackmute
%   tracksolo
%   cleardata


% call tutorial-initialization script
t_00b_init_tutorial

% initialize SoundMexPro 
if 1 ~= soundmexpro('init', ...         % command name
        'output', smpcfg.output, ...   % list of output channels to use 
        'driver', smpcfg.driver ...         % driver index
        )
    error(['error calling ''init''' error_loc(dbstack)]);
end
% show visualization
if 1 ~= soundmexpro('show')
    error(['error calling ''show''' error_loc(dbstack)]);
end


% -------------------------------------------------------------------------
%% 1. show difference between 'mute' and 'pause'
smp_disp('Example 1: playback muting and pausing');
if 1 ~= soundmexpro('loadfile', ...                 % command name
        'filename', '../waves/eurovision.wav', ...  % filename
        'loopcount', 0 ...                          % loop count, here: endless loop
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end
% start playback
if 1 ~= soundmexpro('start')
    error(['error calling ''start''' error_loc(dbstack)]);
end

smp_disp('Hit a key to pause playback');
userinteraction

% set to paused mode
if 1 ~= soundmexpro('pause', 'value', 1)
    error(['error calling ''pause''' error_loc(dbstack)]);
end

smp_disp('Now playback is paused for 2 seconds. Afterwards playback proceeds at the same position');
pause(2);

% set to unpaused mode
if 1 ~= soundmexpro('pause', 'value', 0)
    error(['error calling ''pause''' error_loc(dbstack)]);
end

smp_disp('Hit a key to mute playback');
userinteraction

% set to muted mode
if 1 ~= soundmexpro('mute', 'value', 1)
    error(['error calling ''mute''' error_loc(dbstack)]);
end

smp_disp('Now playback is muted for 2 seconds. Playback continues meanwhile, so position advanced during muting!');
pause(2);


% set to unmuted mode
if 1 ~= soundmexpro('mute', 'value', 0)
    error(['error calling ''mute''' error_loc(dbstack)]);
end

pause(2);
smp_disp('Now playback is on first track only for 2 seconds.');
% mute first track
if 1 ~= soundmexpro('trackmute', 'track', 0, 'value', 1)
    error(['error calling ''trackmute''' error_loc(dbstack)]);
end
pause(2);
% set to unmuted mode
if 1 ~= soundmexpro('trackmute', 'value', 0) % here we specify no particular track, i.e. unmute all tracks!
    error(['error calling ''trackmute''' error_loc(dbstack)]);
end

pause(2);
smp_disp('Now "solo" shown: superseeds "mute"');
% mute first track
if 1 ~= soundmexpro('trackmute', 'track', 0, 'value', 1)
    error(['error calling ''trackmute''' error_loc(dbstack)]);
end
smp_disp('Only second channel audible: first is muted');
pause(2);
% now set first to solo
if 1 ~= soundmexpro('tracksolo', 'track', 0, 'value', 1)
    error(['error calling ''tracksolo''' error_loc(dbstack)]);
end
smp_disp('Only first channel audible: is set to "solo"');
pause(2);


smp_disp('Hit a key to continue');
userinteraction
if 1 ~= soundmexpro('stop')
    error(['error calling ''stop''' error_loc(dbstack)]);
end

% -------------------------------------------------------------------------
%% 2. show usage of command 'cleardata' in pause mode
smp_disp('Example 2: clearing data in pause mode');
if 1 ~= soundmexpro('loadfile', ...                 % command name
        'filename', '../waves/eurovision.wav', ...  % filename
        'loopcount', 0 ...                          % loop count, here: endless loop
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end
% start playback
if 1 ~= soundmexpro('start')
    error(['error calling ''start''' error_loc(dbstack)]);
end

% wait a bit
pause(1);

% pause playback
if 1 ~= soundmexpro('pause', 'value', 1)
    error(['error calling ''pause''' error_loc(dbstack)]);
end

smp_disp('device is paused');

% clear data in pause mode
if 1 ~= soundmexpro('cleardata')
    error(['error calling ''cleardata''' error_loc(dbstack)]);
end
% load other file
if 1 ~= soundmexpro('loadfile', ...                 % command name
        'filename', '../waves/3sine_16bit.wav', ... % filename
        'loopcount', 0 ...                          % loop count, here: endless loop
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end


% resume playback with new data
if 1 ~= soundmexpro('pause', 'value', 0)
    error(['error calling ''pause''' error_loc(dbstack)]);
end

smp_disp('device resumes after clearing and loading different data');

smp_disp('Hit a key to stop example');
userinteraction

clear soundmexpro;
