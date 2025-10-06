%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
%
% This example shows how to start recording threshold driven and stop
% it automatically after x samples.
%
% NOTE: for this example it is mandatory to connect the first two output 
% channels with the first two input channels with a a shortcut cable.
% Otherwise no data will be present on A/D converter and the requested
% threshold is never exceeded. Furthermore you may have to adjust your
% analog input and output values accordingly, if the recorded values are
% not appropriate!
% You may also use other channels by setting global variables (see below)
%
% SoundMexPro commands introduced in this example:
%   recthreshold
%   reclength
%   recstarted


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

% show device visualization
if 1 ~= soundmexpro('show')
    error(['error calling ''show''' error_loc(dbstack)]);
end

% load a file containing a sine with ascending amplitude on first channel. 
if 1 ~= soundmexpro(  'loadfile', ...           % command name
        'filename', '../waves/envelope.wav' ... % name of wavefile
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

% set record length to 1 second 
if 1 ~= soundmexpro(  'reclength', ...      % command name
        'value', 44100 ...                  % length in samples
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

% set record threshold to 0.2
if 1 ~= soundmexpro(  'recthreshold', ...   % command name
        'value', 0.2, ...                   % threshold value to be exceeded (between 0 and 1)
        'mode', 1, ...                      % mode '1' (this is default): threshold to be exceeded in one channel 
        'channel', 0 ...                    % channel to look at 
        )
    error(['error calling ''recthreshold''' error_loc(dbstack)]);
end

% start device
if 1 ~= soundmexpro('start')
    error(['error calling ''start''' error_loc(dbstack)]);
end

% we wait, until recording is started at all (with timeout)
tic;
value  = 0;    
while max(value) == 0
    % check if record is started now
    [success, value] = soundmexpro('recstarted');
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
smp_disp('threshold exceeded!');

% now wait for recording (!) to be complete
value = 1;
while max(value) == 1
    % reaching this point, recording was started. 
    [success, value] = soundmexpro('recording');
    % check success of command
    if 1 ~= success
        soundmexpro('exit');
        error('Fatal error in loop. Aborting...');
    end
    pause(0.1);
end
smp_disp('recording done');

% plot recorded data
close all;
figure; hold;
% NOTE: MATLAB versions < 6 do not support reading 32bit float waves, so in
% that case we use the tool script shipped with SoundMexPro 
if strncmp(version, '5', 1) == 1
    x = wavread_sdp('rec_0.wav');
    y = wavread_sdp('rec_1.wav');
else
    if 0 == exist('audioread')
        x = wavread('rec_0.wav');
        y = wavread('rec_1.wav');
    else
        x = audioread('rec_0.wav');
        y = audioread('rec_1.wav');
    end
end
delete('rec_0.wav');
delete('rec_1.wav');
clear soundmexpro;

plot(y, 'b');
plot(x, 'r');
smp_disp('Hit a key to quit example');
userinteraction
close all;
