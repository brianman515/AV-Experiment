%           Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
% The examples named t_04????? show usage of multiple commands related to
% playback of files and vectors with mixing (multiple tracks per channel),
% waiting, clipping ... They show similar playback situations with slightly
% different features to show different behaviour of SoundMexPro needed for
% different tasks.
%
% This example mainly shows the usage of the command 'loadfile' and
% especially usage of the paameters 'crossfadelen', 'ramplen',
% 'loopramplen' and 'loopcrossfade'. For this purpose only simple playback
% on two channels is done.
%
% 
% SoundMexPro commands introduced in this example:
%   loadfile
%   start
%   wait
%   tracklen
%   stop

% call tutorial-initialization script
t_00b_init_tutorial

% initialize two output channels, no input (default)
if 1 ~= soundmexpro('init', ...                     % command name
                    'driver', smpcfg.driver , ...   % driver 
                    'output', smpcfg.output ...     % list of output channels to use                     
            )
    error(['error calling ''init''' error_loc(dbstack)]);
end


% -------------------------------------------------------------------------
%% 1. show crossfade between different files
if 1 ~= soundmexpro('loadfile', ...                 % command name
        'filename', '../waves/eurovision.wav' ...   % filename
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

if 1 ~= soundmexpro('loadfile', ...                     % command name
        'filename', '../waves/3sine_16bit.wav', ...     % filename
        'crossfadelen', 60000 ...                       % do a crossfade of 60000 samples with object BEFORE this one
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

% show visualization
if 1 ~= soundmexpro('showtracks')
    error(['error calling ''showtracks''' error_loc(dbstack)]);
end

% start playback 
if 1 ~= soundmexpro('start', ...    % command name
        'length', -1 ...            % length, here -1: stop if no track has more data (this is default)
        )
    error(['error calling ''start''' error_loc(dbstack)]);
end

% then wait
if 1 ~= soundmexpro('wait', 'mode', 'stop')
    error(['error calling ''wait''' error_loc(dbstack)]);
end

smp_disp('Hit a key to continue');
userinteraction

% -------------------------------------------------------------------------
%% 2. ramps within a looped object
if 1 ~= soundmexpro('loadfile', ...                     % command name
        'filename', '../waves/3sine_16bit.wav', ...     % filename
        'ramplen', 44100, ...                           % initial and final ramp of 44100 samples length
        'loopcount', 3, ...                             % play three loops
        'loopramplen', 10000 ...                        % ramp at end and beginning of each loop of 10000 samples length
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end


% update visualization
if 1 ~= soundmexpro('updatetracks')
    error(['error calling ''updatetracks''' error_loc(dbstack)]);
end
% plot current length of track in samples and seconds
[success, tracklength] = soundmexpro('tracklen');
if 1 ~= success
    error(['error calling ''tracklen''' error_loc(dbstack)]);
end
smp_disp(['track length of three full loops: ' num2str(tracklength(1)) ', (' num2str(tracklength(1)/44100) ' seconds)']);
drawnow;
% start playback 
if 1 ~= soundmexpro('start', ...    % command name
        'length', -1 ...            % length, here -1: stop if no track has more data (this is default)
        )
    error(['error calling ''start''' error_loc(dbstack)]);
end

% then wait
if 1 ~= soundmexpro('wait', 'mode', 'stop')
    error(['error calling ''wait''' error_loc(dbstack)]);
end

smp_disp('Hit a key to continue');
userinteraction

% -------------------------------------------------------------------------
%% 3. crossfade within a looped object
if 1 ~= soundmexpro('loadfile', ...                     % command name
        'filename', '../waves/3sine_16bit.wav', ...     % filename
        'ramplen', 44100, ...                           % initial and final ramp of 44100 samples length
        'loopcount', 3, ...                             % play three loops
        'loopramplen', 44100, ...                       % crossfade between loops of 44100 samples length
        'loopcrossfade', 1 ...                          % enable loop-crossfade
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end


% show visualization
if 1 ~= soundmexpro('updatetracks')
    error(['error calling ''updatetracks''' error_loc(dbstack)]);
end
% plot current length of track in samples and seconds
[success, tracklength] = soundmexpro('tracklen');
if 1 ~= success
    error(['error calling ''tracklen''' error_loc(dbstack)]);
end
smp_disp(['track length of three loops with crossfade: ' num2str(tracklength(1)) ', (' num2str(tracklength(1)/44100) ' seconds)']);
drawnow;
% start playback 
if 1 ~= soundmexpro('start', ...    % command name
        'length', -1 ...            % length, here -1: stop if no track has more data (this is default)
        )
    error(['error calling ''start''' error_loc(dbstack)]);
end

% then wait
if 1 ~= soundmexpro('wait', 'mode', 'stop')
    error(['error calling ''wait''' error_loc(dbstack)]);
end


smp_disp('Hit a key to exit the tutorial');
userinteraction

clear soundmexpro;
