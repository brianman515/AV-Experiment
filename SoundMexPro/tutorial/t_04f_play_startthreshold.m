%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
%
% This example shows how to start SoundMexPro triggered by a threshold on 
% a recording channel
%
% NOTE: for this example it is mandatory to use a second soundcard, CD
% player or any other device to play some sound to exceed the threshold,
% i.e. you have to connect this additional device to the input channel used
% in the tutorial and start it at the time, where you like to exceed the
% threshold!!
%
% SoundMexPro commands introduced in this example:
%   startthreshold


% call tutorial-initialization script
t_00b_init_tutorial

% initialize SoundMexPro with first ASIO driver, use two output, two input
% channels
if 1 ~= soundmexpro('init', ...         % command name
        'driver', smpcfg.driver , ...       % driver index
        'output', smpcfg.output, ...   % list of output channels to use (default)
        'input', smpcfg.input ...      % list of input channels to use
        )
    error(['error calling ''init''' error_loc(dbstack)]);
end

% disable 'regular' recording to file. NOTE: the regular files rec_?.wav
% are created anyway, but stay empty
if 1 ~= soundmexpro('recpause', ...     % command name
        'value', 1 ...                  % enable pause
        )
    error(['error calling ''recpause''' error_loc(dbstack)]);
end


% show device visualization
if 1 ~= soundmexpro('show')
    error(['error calling ''show''' error_loc(dbstack)]);
end

% load a playback file 
if 1 ~= soundmexpro(  'loadfile', ...             % command name
        'filename', '../waves/eurovision.wav' ... % name of wavefile
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end


% start device with 'starthreshold'
if 1 ~= soundmexpro(  'startthreshold', ...     % command name
        'value', 0.2, ...                       % threshold value (between 0 and 1)
        'mode', 1, ...                          % mode '1' (this is default): threshold to be exceeded in one channel 
        'channel', 0 ...                        % channel to look at 
        )
    error(['error calling ''startthreshold''' error_loc(dbstack)]);
end


% we wait, until device is started (with timeout)
tic;
value  = 0;    
while max(value) == 0
    % check if device is started meanwhile (i.e. threshold exceeded)
    [success, value] = soundmexpro('started');
    % check success of command
    if 1 ~= success
        soundmexpro('exit');
        error('Fatal error in loop. Aborting...');
    end
    % check for timeout
    if toc > 10
        soundmexpro('exit');
        error('timeout occurred, example stopped (check cables)');
    end
    pause(0.1);
end

smp_disp('threshold exceeded! Hit a key to quit example');

userinteraction;

clear soundmexpro;



