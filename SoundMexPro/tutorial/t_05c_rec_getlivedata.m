%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
%
% This example shows how to retrieve live data bufferwise from the device
% and 'collect' them to have all recorded data on available on the fly
% NOTE: It is recommended to connect the first two output channels with the
% first two input channels with a a shortcut cable to run these examples.
% You may also use other channels by setting global variables (see below)
%
% NOTE: the commands 'recbufsize' and 'recgetdata' are only available in
% demo version and with a DSP license!
%
% SoundMexPro commands introduced in this example:
%   recbufsize
%   recgetdata



% call tutorial-initialization script
t_00b_init_tutorial


% initialize SoundMexPro with first ASIO driver, use two output, two input
% channels
if 1 ~= soundmexpro('init', ...         % command name
        'driver', smpcfg.driver,...     % driver index
        'output', smpcfg.output, ...    % list of output channels to use
        'input', smpcfg.input ...       % list of input channels to use
        )
    error(['error calling ''init''' error_loc(dbstack)]);
end

% show device visualization
if 1 ~= soundmexpro('show')
    error(['error calling ''show''' error_loc(dbstack)]);
end

% set record buffer size to 20000 samples
if 1 ~= soundmexpro('recbufsize', ...   % command name
        'value', 20000 ...              % buffer size in samples
        )
    error(['error calling ''recbufsize''' error_loc(dbstack)]);
end

% disable 'regular' recording to file. NOTE: the regular files rec_?.wav
% are created anyway, but stay empty
if 1 ~= soundmexpro('recpause', ...     % command name
        'value', 1 ...                  % enable pause
        )
    error(['error calling ''recpause''' error_loc(dbstack)]);
end

% concatenate three example wave files and add a few zeros
if 0 == exist('audioread')
    data = [wavread('../waves/eurovision.wav') ; ...
        wavread('../waves/3sine_16bit.wav') ; ...
        0.5.*wavread('../waves/sweep.wav') ; ...
        zeros(10000,2)];
else
    data = [audioread('../waves/eurovision.wav') ; ...
        audioread('../waves/3sine_16bit.wav') ; ...
        0.5.*audioread('../waves/sweep.wav') ; ...
        zeros(10000,2)];
end

if 1 ~= soundmexpro('loadmem', ...      % command name
        'data', data ...                % data vector
        )
    error(['error calling ''loadmem''' error_loc(dbstack)]);
end

% start playback and record
if 1 ~= soundmexpro('start')
    error(['error calling ''start''' error_loc(dbstack)]);
end

recdata = [];
recpos = 0;
while 1
    % query recorded data: NOTE after each call to recgetdata 'recbuf' will
    % contain the last n recorded samples, where n is the recbufsize set
    % above. 'pos' is set to the absolute position of the first sample in
    % time (since the device is running). In subsequent calls to 'recgetdata'
    % you may retrieve overlapping data (if you are calling fast!), and
    % thus the number of 'new' samples n (i.e. samples, that were not already
    % retrieved in last call) can be calculated by the difference of the
    % two retrieved positions p1 and p2:
    %       n = (p2 - p1)
    % If this number is larger than your recbufsize, than you have missed
    % data! Otherwise you can copy the new data with respect to the
    % overlap: the last (recbufsize - n) samples in the first buffer are
    % identical to the first (recbufsize - n) samples in the second buffer
    % and you may skip them
    [success, recbuf, pos] = soundmexpro('recgetdata');
    if success ~= 1
        clear soundmexpro
        error(['error calling ''recgetdata''' error_loc(dbstack)]);
    end

    % NOTE: if you don't want to wave 'dummy-zeros' in the beginning, then
    % throw away all value retrieved with 'recgetdata' with negative
    % indices, i.e. start storing values in recdata from (pos + recbuf(i)
    % >= 0)


    % NOTE: after first call (i.e recpos still 0) we might not have caught
    % the very first buffer, so we have to adjust the position here
    if (recpos == 0)
        recpos = pos + 1;
    end
    
    % append data with respect to current record position!
    % - check, if we have 'missed' data
    if pos > recpos
        clear soundmexpro
        error('stopping example: we missed record data!');
    end
    
    % - calculate position, where the first sample is located, that we did
    % not already retrieve in last call
    readstart = recpos - pos;
    % - append read new data. NOTE: if you do this in loooooooong recording
    % loops you may produce heavy memory and processor load, because the
    % matrix has to be resized in every call!
    
    recdata = [recdata ; recbuf(readstart:end,:)];
    % - increment absolute recording position
    recpos = recpos + (length(recbuf) - readstart ) + 1;
    
    % check if device is still running. NOTE: it was started in default mode
    % 0, i.e. it stops automatically after playback is complete!
    [success, started] = soundmexpro('started');
    if success ~= 1
        clear soundmexpro
        error(['error calling ''started''' error_loc(dbstack)]);
    end
    % if not, we're done
    if started ~= 1
        break;
    end
    % wait a bit before retrieving next data. Increase this value to get
    % the 'missing data' scenario tested above.
    pause(0.1);
end

delete('rec_0.wav');
delete('rec_1.wav');

close all;
% plot collected data
plot(recdata);
smp_disp('Hit a key to quit example');
userinteraction

close all;
clear soundmexpro;
