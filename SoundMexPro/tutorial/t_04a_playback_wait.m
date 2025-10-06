%           Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
%
% This example shows playback of files with different methods of waiting
% for playback to be complete and different parts of files/vectors to be
% played
%
% 
% SoundMexPro commands introduced in this example:
%   loadfile
%   start
%   started
%   wait
%   playing
%   stop
%   playposition                                                     

% call tutorial-initialization script
t_00b_init_tutorial

% initialize two output channels, no input (default)
if 1 ~= soundmexpro('init', ...             % command name
                    'driver', smpcfg.driver , ...  % driver 
                    'output', smpcfg.output ... % list of output channels to use                     
            )
    error(['error calling ''init''' error_loc(dbstack)]);
end
% show visualization
if 1 ~= soundmexpro('show')
    error(['error calling ''show''' error_loc(dbstack)]);
end

% -------------------------------------------------------------------------
%% 1. play a file two times and wait for it to be finished with command
% 'wait', which waits in 'blocking' mode (i.e. command returns after
% playback is complete). NOTE: the second return value of 'loadfile' (the
% 'busy' flag) is not checked here. See example t_04c_play_con_stim_gen.m
% for that task.
smp_disp('Example 1: waiting for playback done (blocking)');
 
if 1 ~= soundmexpro('loadfile', ...                 % command name
        'filename', '../SoundMexPro/waves/eurovision.wav', ...  % filename
        'loopcount', 2 ...                          % loop count
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end


% start playback 
if 1 ~= soundmexpro('start', ...    % command name
        'length', -1 ...            % length, here -1: stop if no track has more data (this is default)
        )
    error(['error calling ''start''' error_loc(dbstack)]);
end
% here we show usage of 'started' command (even if not needed here)
[success, started] = soundmexpro('started');
if success ~= 1
    error(['error calling ''started''' error_loc(dbstack)]);
end
if started ~= 1
    error('device unexpectedly not running!');
end

% then wait
if 1 ~= soundmexpro('wait', 'mode', 'stop')
    error(['error calling ''wait''' error_loc(dbstack)]);
end
smp_disp('playback done');
%pause(0.0001);
% here we show usage of 'playing' command (even if not needed here)
[success, playing] = soundmexpro('playing');
if success ~= 1
    error(['error calling ''playing''' error_loc(dbstack)]);
end
if max(playing) ~= 0
    error('device unexpectedly still playing!');
end

smp_disp('Hit a key to continue');
userinteraction

% -------------------------------------------------------------------------
%% 2. play a file two times and wait for it to be finished non-blocking.
% In a loop the 'playing' command checks, if the sound is still playing and
% does some calculation meanwhile.
smp_disp('Example 2: waiting for playback done (non-blocking, calculating during playback)');
if 1 ~= soundmexpro('loadfile', ...                 % command name
        'filename', '../SoundMexPro/waves/eurovision.wav', ...  % filename
        'loopcount', 2 ...                          % loop count
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end
if 1 ~= soundmexpro('start', ...    % command name
        'length', -1 ...            % length, here -1: stop if no track has more data (this is default)
        )
    error(['error calling ''start''' error_loc(dbstack)]);
end

counter = 0;
playing = 1;
% check if at least one channel is (still) playing
while max(playing)
    % query device
    [success, playing] = soundmexpro('playing');
    % check success of command itself
    if success ~= 1
        clear soundmexpro
        error(['error calling ''playing''' error_loc(dbstack)]);
    end
    % NOTE: no while loops without a small pause!
    pause(0.01);
    % dummy-calculation: simply increase a counter
    counter = counter + 1;
end

% stop it
if 1 ~= soundmexpro('stop')
    error(['error calling ''stop''' error_loc(dbstack)]);
end

smp_disp(['playback done, calculation loop called ' num2str(counter) ' times.']);
smp_disp('Hit a key to continue');
userinteraction

% -------------------------------------------------------------------------
%% 3. play a file one times. Device is started with length 0, i.e. it does not
% stop after playback, but plays zeros. We wait a bit and load file one
% time again to immediate output with a random position and stop the device
% afterwards.
smp_disp('Example 3: waiting for playback, add more data wait again');
if 1 ~= soundmexpro('loadfile', ...                 % command name
        'filename', '../SoundMexPro/waves/eurovision.wav', ...  % filename
        'loopcount', 1 ...                          % loop count (this is default as well)
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end
% start playback with length 0, i.e. endless mode
if 1 ~= soundmexpro('start', ...    % command name
        'length', 0 ...             % length, here 0: run endlessly
        )
    error(['error calling ''start''' error_loc(dbstack)]);
end

% then wait
if 1 ~= soundmexpro('wait')
    error(['error calling ''wait''' error_loc(dbstack)]);
end
smp_disp('playback 1 done');

% check, that device is still running
[success, started] = soundmexpro('started');
if success ~= 1
    error(['error calling ''started''' error_loc(dbstack)]);
end
if started ~= 1
    error('device unexpectedly not running anymore!');
end

% wait a bit ...
pause(1);

% play file again, this time from a random position to the end + one
% complete loop
if 1 ~= soundmexpro('loadfile', ...                 % command name
        'filename', '../SoundMexPro/waves/eurovision.wav', ...  % filename
        'loopcount', 2, ...                         % loop count
        'startoffset' , -1 ...                      % offset within file, here: -1 (random position)
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

% then wait
if 1 ~= soundmexpro('wait')
    error(['error calling ''wait''' error_loc(dbstack)]);
end
if 1 ~= soundmexpro('stop')
    error(['error calling ''stop''' error_loc(dbstack)]);
end
smp_disp('playback 2 done');
smp_disp('Hit a key to continue');
userinteraction


% -------------------------------------------------------------------------
%% 4. load a file for playing multiple times. Device is started with length
% > 0, i.e.  it does stops after the corresponding number of samples is
% played.
smp_disp('Example 4: stop playback after particular number of samples');
if 1 ~= soundmexpro('loadfile', ...                 % command name
        'filename', '../SoundMexPro/waves/eurovision.wav', ...  % filename
        'loopcount', 5 ...                          % loop count 
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end
% start playback with particular length 
if 1 ~= soundmexpro('start', ...    % command name
        'length', 44100 ...         % length, here 44100: stop after one second
        )
    error(['error calling ''start''' error_loc(dbstack)]);
end

% then wait
if 1 ~= soundmexpro('wait', 'mode', 'stop')
    error(['error calling ''wait''' error_loc(dbstack)]);
end
smp_disp('playback done');

% check, that device is stopped 
[success, started] = soundmexpro('started');
if success ~= 1
    error(['error calling ''started''' error_loc(dbstack)]);
end
if started == 1
    error('device unexpectedly still running!');
end

smp_disp('Hit a key to continue');
userinteraction



% -------------------------------------------------------------------------
%% 5. Show usage of parameters 'offset' 'startoffset', 'fileoffset' and 'length' 
% for command 'loadfile' and setting a play position in pause mode
smp_disp('Example 5: show usage of "loadfile" arguments and command "playposition"');

% load data to be played before the 'sophisticated' example file
if 1 ~= soundmexpro('loadfile', ...                 % command name
        'filename', '../SoundMexPro/waves/eurovision.wav' ...  % filename
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

% The file ../waves/3sine_16bit.wav contains a sequence of three sine
% signals of one second length each: first second 440 Hz, then 900 Hz
% finally 600 Hz.
% In this example we want to play it with the following properties:
%  - start with one second silence (i.e. after the data loaded above): 
%    -> use parameter 'offset'
%  - use just a part of the file (snippet) not starting at the begining
%    of the file
%    -> use parameters 'fileoffset' and 'length' to define the snippet
%  - do not start at first sample of the snippet in first loop (useful e.g.
%    for pseude-running-noise)
%    -> use parameter 'startoffset'
if 1 ~= soundmexpro('loadfile', ...                 % command name
        'filename', '../SoundMexPro/waves/3sine_16bit.wav', ... % filename
        'offset', 44100, ...                        % one second silence
        'fileoffset', 22050, ...                    % 0.5 seconds: we start with our snippet at the second half of the first 440 Hz sine
        'length', 88200, ...                        % build a 2 seconds snippet: together with 'fileoffset' this leads to a snippet:
        ...                                         % i.e.: 0.5 seconds 440Hz - 1 second 900 Hz - 0.5 seconds 600 Hz
        'loopcount', 3, ...                         % loop count of the snippet
        'startoffset', 22050 ...                    % skip 0.5 second in first loop, i.e. skip the 440 Hz in first loop
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end


% load more data after the 'sophisticated' example
if 1 ~= soundmexpro('loadfile', ...                 % command name
        'filename', '../SoundMexPro/waves/eurovision.wav', ...  % filename
        'loopcount', 5 ...                          % loop count
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end


% -> total expected output is (combining all parameters/comments % above:
%
% eurovsion.wav -                               
% 1s silence - 
% 1s 900 Hz - 0.5s 600 Hz -                     % first loop with startoffset, i.e. 0.5s 440 Hz skipped
% 0.5s 440 Hz - 1s 900Hz - 0.5s 600 Hz -        % second full loop of snippet
% 0.5s 440 Hz - 1s 900Hz - 0.5s 600 Hz -        % third full loop of snippet
% eurovsion.wav multiple times
%
% NOTE: the vertical dooted loop lines in track view show the loop
% positions of the snippet, not the file!!

% initialize track view GUI
if 1 ~= soundmexpro('showtracks', 'wavedata', 1)    % command name
    error(['error calling ''showtracks''' error_loc(dbstack)]);
end

% start playback 
if 1 ~= soundmexpro('start')    % command name
    error(['error calling ''start''' error_loc(dbstack)]);
end

% no we wait until the last file plays
pause(12);

% then pause
if 1 ~= soundmexpro('pause', 'value', 1)    % command name
    error(['error calling ''pause''' error_loc(dbstack)]);
end

% set play position: note cursor moves in track view
smp_disp('Moving playposition to 6 seconds');
if 1 ~= soundmexpro('playposition', ...         % command name
                    'position', 6*44100 ...     % position: 6 seconds
                    )
    error(['error calling ''pause''' error_loc(dbstack)]);
end
% wait a bit
pause(2);
smp_disp('resume');
% unpause
if 1 ~= soundmexpro('pause', 'value', 0)    % command name
    error(['error calling ''pause''' error_loc(dbstack)]);
end

smp_disp('Hit a key to stop example');

userinteraction

clear soundmexpro;
