%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
%
% This example shows how to do direct 'io', i.e. recording audio from the
% soundcard and do direct playback of these recorded data. This is
% especially interesting when processing the data between recording and
% playback e.g. with the MATLAB script based DSP interface of SoundMexPro
% (not done here, see DSP examples). 
% NOTE: to get this example running you have to connect any audio input to
% the first two input channels of your soundcard (to have a recording
% source). The recorded data then are added to the first two tracks
% (connnected to the first two output channels) in switched order.
% Additional data are played on first track to show the feature of 'adding'
% the reorded input to 'regular' output data.
%
% SoundMexPro commands introduced in this example:
%   iostatus


% call tutorial-initialization script
t_00b_init_tutorial

% initialize SoundMexPro with first ASIO driver, use two output, two input
% channels
if 1 ~= soundmexpro('init', ...         % command name
        'driver', smpcfg.driver , ...   % driver index
        'output', smpcfg.output, ...    % list of output channels to use
        'input', smpcfg.input ...       % list of input channels to use
        )
    error(['error calling ''init''' error_loc(dbstack)]);
end

% show device visualization
if 1 ~= soundmexpro('show')
    error(['error calling ''show''' error_loc(dbstack)]);
end


% set IO-mapping: connect input channel 0 with output channel 1 and vice
% versa
if 1 ~= soundmexpro('iostatus', ...     % command name
        'track', 1, ...                 % tracks to map input to
        'input', 0 ...                  % input channel to map
        )
    error(['error calling ''iostatus''' error_loc(dbstack)]);
end
if 1 ~= soundmexpro('iostatus', ...     % command name
        'track', 0, ...                 % tracks to map input to
        'input', 1 ...                  % input channel to map
        )
    error(['error calling ''iostatus''' error_loc(dbstack)]);
end


% disable 'regular' recording to file. NOTE: the regular files rec_?.wav
% are created anyway, but stay empty
if 1 ~= soundmexpro('recpause', ...     % command name
        'value', 1 ...                  % enable pause
        )
    error(['error calling ''recpause''' error_loc(dbstack)]);
end

% lower channel volumes to avoid clipping
if 1 ~= soundmexpro('volume', ...       % command name
        'value', 0.5 ...                % volume
        )
    error(['error calling ''volume''' error_loc(dbstack)]);
end

% read additional data to play and scale them down
if 0 == exist('audioread')
    wavdata = wavread('../waves/eurovision.wav') .* 0.1;
else
    wavdata = audioread('../waves/eurovision.wav') .* 0.1;    
end
% play mem on first track
if 1 ~= soundmexpro('loadmem', ...  % command name
        'data', wavdata(:,1), ...   % data (here: only first channel)
        'track', 0, ...             % tracks, here 0 
        'loopcount', 2 ...          % loopcount
        )
    error(['error calling ''loadmem''' error_loc(dbstack)]);
end


% start playback and I/O in mode 'play-zeros-if-empty'
if 1 ~= soundmexpro('start', ...    % command name
        'length', 0 ...             % length, here 0: play zeros
        )
    error(['error calling ''start''' error_loc(dbstack)]);
end

% if any input is connected now, you should 'see' that it is played as well
% on the visualization 
smp_disp('Hit a key to quit example');
userinteraction


clear soundmexpro;
delete('rec_0.wav');
delete('rec_1.wav');
