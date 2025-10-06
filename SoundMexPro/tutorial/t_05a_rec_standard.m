%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
% The examples named t_05????? show how to record wave data with SoundMexPro.
% Starting with a simple recording task the examples become
% more sophisticted using threshold recording and online 'grabbing' of
% recorded data into the MATLAB workspace.
% NOTE: It is recommended to connect the first two output channels with the
% first two input channels with a a shortcut cable to run these examples.
% You may also use other channels by setting global variables (see below)
%
% This example shows recording on two channels with user defined filename
% and pausing one of the channels durcing recording.
%
% SoundMexPro commands introduced in this example:
%   recording
%   recposition
%   recfilename
%   recpause
%   clipcount (for recorded data)


% call tutorial-initialization script
t_00b_init_tutorial

% initialize SoundMexPro with first ASIO driver, use two output, two input
% channels
if 1 ~= soundmexpro('init', ...         % command name
        'driver', smpcfg.driver , ...       % driver index
        'output', smpcfg.output, ...   % list of output channels to use (default)
        'input', smpcfg.input, ...     % list of input channels to use
        'track', 4 ...                  % number of virtual tracks, here 4 (i.e. 2 tracks per channel)
        )
    error(['error calling ''init''' error_loc(dbstack)]);
end

% show device visualization
if 1 ~= soundmexpro('show')
    error(['error calling ''show''' error_loc(dbstack)]);
end

% set filename of recording of first channel to other than default and
% print both resulting filenames
[success, files] = soundmexpro('recfilename', ...   % command name
    'filename', 'myrecfile.wav', ...                % new filename 
    'channel', 0 ...                                % channel to set filename
    );
if success ~= 1
    error(['error calling ''recfilename''' error_loc(dbstack)]);
end
smp_disp('The recording filenames are:');
smp_disp(files');

% lower volume to avoid clipping when adding waves
if 1 ~= soundmexpro('volume', ...   % command name
        'value', 0.2 ...            % volume (factor to be applied). Her only one value, i.e. applied to all channels
        )
    error(['error calling ''volume''' error_loc(dbstack)]);
end

% load a noise file. 
if 1 ~= soundmexpro(  'loadfile', ...               % command name
        'filename', '../waves/noise_16bit.wav', ... % name of wavefile
        'track', [0 1], ...                         % play on first two tracks (both channels)
        'loopcount', 0 ...                          % endless loop
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end
% load a 'stimulus' with an offset of 2 sec. to next two tracks
if 1 ~= soundmexpro(  'loadfile', ...               % command name
        'filename', '../waves/3sine_16bit.wav', ... % name of wavefile
        'track', [2 3], ...                         % play on last two tracks (both channels)
        'offset', 88200 ...                         % offset in samples
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

% start device (playback and recording!)
if 1 ~= soundmexpro('start')
    error(['error calling ''start''' error_loc(dbstack)]);
end

% now show, that both channels are recording at the moment
[success, recording] = soundmexpro('recording');
if success ~= 1
    error(['error calling ''recording''' error_loc(dbstack)]);
end
smp_disp(['First channel does record to file: ' int2str(recording(1)) ', second channel does record to file: ' int2str(recording(2))]);


% wait until 'mixing' has ended (playback on tracks 2 and 3)
while  1
    [success, playing] = soundmexpro('playing');
    % check success of command
    if 1 ~= success
        soundmexpro('exit');
        error('Fatal error in loop. Aborting...');
    end
    % then check the last two tracks (NOTE: vector is 1-based!)
    if (max(playing(3:end)) == 0)
        break;
    end
    pause(0.05)
end

% show identical recpositions (recorded lengths) of the two channels
[success, recpos] = soundmexpro('recposition');
if success ~= 1
    error(['error calling ''recpause''' error_loc(dbstack)]);
end
smp_disp(['samples recorded on first channel: ' int2str(recpos(1)) ', second channel: ' int2str(recpos(2))]);

% after mixing, we disable recording of first channel again
if 1 ~= soundmexpro('recpause', ...     % command name
        'value', 1, ...                 % value to set (1 is pause, 0 is resume)
        'channel', 0 ...                % channel to apply value to
        )
    error(['error calling ''recpause''' error_loc(dbstack)]);
end

% wait again
pause(1);

% now show, that only second channels is recording at the moment
[success, recording] = soundmexpro('recording');
if success ~= 1
    error(['error calling ''recording''' error_loc(dbstack)]);
end
smp_disp(['First channel does record to file: ' int2str(recording(1)) ', second channel does record to file: ' int2str(recording(2))]);

% show now different recpositions (recorded lengths) of the two channels
[success, recpos] = soundmexpro('recposition');
if success ~= 1
    error(['error calling ''recpause''' error_loc(dbstack)]);
end
smp_disp(['samples recorded on first channel: ' int2str(recpos(1)) ', second channel: ' int2str(recpos(2))]);


% check, if we had clippings on input (depends on your hardware: change
% your input sensitivity to force clipping). NOTE: SoundMexPro defines
% 'clipping' on the input as two subsequent samples that contain 1 (or -1
% respectively).
[success, clipout, clipin] = soundmexpro('clipcount');
if success ~= 1
    error(['error calling ''clipcount''' error_loc(dbstack)]);
end
smp_disp(['Clipped input buffers on first channel: ' int2str(clipin(1)) ', on second channel: ' int2str(clipout(2)) '.  Hit a key to continue']);

clear soundmexpro;

% load two recorded wavs and cleanup. NOTE: MATLAB versions < 6 do not support
% reading 32bit float waves, so in that case we use the tool script shipped
% with SoundMexPro 
if strncmp(version, '5', 1) == 1
    x = wavread_sdp('myrecfile.wav');
    y = wavread_sdp('rec_1.wav');
else
    if 0 == exist('audioread')
        x = wavread('myrecfile.wav');
        y = wavread('rec_1.wav');
    else
        x = audioread('myrecfile.wav');
        y = audioread('rec_1.wav');
    end
end
delete('myrecfile.wav');
delete('rec_1.wav');

% plot them 
close all;
figure; hold;
plot(y, 'b');
plot(x, 'r');
smp_disp('Hit a key to quit example');
userinteraction

close all;
clear soundmexpro;
