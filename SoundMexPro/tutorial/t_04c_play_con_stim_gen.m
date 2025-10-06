%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
% This example shows playback of audio data, that are passed to the device
% 'on the fly' while it is running. It shows how to detect 'underruns'
% (i.e. the device rans out of data, before new data are passed to it), and
% 'overflows' (i.e. data segments are passed too fast to the device)
%
%
% SoundMexPro commands introduced in this example:
%   trackload
%   underrun
%   debugsave
%

% call tutorial-initialization script
t_00b_init_tutorial

% initialize two output channels, no input (default)
if 1 ~= soundmexpro('init', ...         % command name
        'driver', smpcfg.driver,  ...       % driver index
        'output', smpcfg.output ...    % list of output channels to use 
        )
    error(['error calling ''init''' error_loc(dbstack)]);
end
% show visualization
if 1 ~= soundmexpro('show')
    error(['error calling ''show''' error_loc(dbstack)]);
end


% create a dummy buffer: read a short signal with sines of different
% frequencies in two channels
if 0 == exist('audioread')
    signal = wavread('../waves/900l_450r.wav');
else
    signal = audioread('../waves/900l_450r.wav');
end


% pre-load a few buffers (here: 10). NOTE: we can do this by preloading 
% 'one longer buffer' by loopcount!
if 1 ~= soundmexpro('loadmem', 'data', signal, 'loopcount', 10)
    error(['error calling ''loadmem''' error_loc(dbstack)]);
end

% start device in 'play-zeros-if-no-data-in-tracks'-mode
if 1 ~= soundmexpro('start', ...   % command name
        'length', 0 ...            % 'play-zeros-if-no-data-in-tracks'-mode
        )
    error(['error calling ''start''' error_loc(dbstack)]);
end

% -------------------------------------------------------------------------
%% 1: we pass new data quite too fast. So, we expect that the number of
% loaded data segments, ie. the 'trackload' raises. 
% 
smp_disp('First example: no underruns, adding new data "too fast"');
for i = 1:50
    [success] =  soundmexpro('loadmem', 'data', signal);
    if success ~= 1
        error(['error calling ''loadmem''' error_loc(dbstack)]);
    end
    % small pause. 
    pause(0.02);
end

% check, if we had underruns (not expected!)
[success, underrun] =  soundmexpro('underrun');
if success ~= 1
    error(['error calling ''underrun''' error_loc(dbstack)]);
end
if max(underrun) > 0
    smp_disp('UNEXPECTEDLY THERE WAS A DATA UNDERRUN');
else
    % now we expect that quite same data segments are 'accumulated'
    [success, trackload] = soundmexpro('trackload');
    if success ~= 1
        error(['error calling ''trackload''' error_loc(dbstack)]);
    end
    smp_disp(['no underrun occurred, currently ' num2str(trackload(1)) ' data segments are pending for output']);
end

if 1 ~= soundmexpro('stop')
    error(['error calling ''stop''' error_loc(dbstack)]);
end
pause(0.5);

% -------------------------------------------------------------------------
%% 2: the data adding loop is fast again, but we take care of the
% current trackload! This is the recommended way to do it!
% 
smp_disp(' ');
smp_disp('-------------------------------------------------------------------------');
smp_disp('Second example: no underruns, taking care of trackload');

% pre-load a few buffers (here: 10). NOTE: we can do this by preloading 
% 'one longer buffer' by loopcount!
if 1 ~= soundmexpro('loadmem', 'data', signal, 'loopcount', 10)
    error(['error calling ''loadmem''' error_loc(dbstack)]);
end

% start device in 'play-zeros-if-no-data-in-tracks'-mode
if 1 ~= soundmexpro('start', ...   % command name
        'length', 0 ...            % 'play-zeros-if-no-data-in-tracks'-mode
        )
    error(['error calling ''start''' error_loc(dbstack)]);
end

busycounter     = 0;
successcounter  = 0;
while (successcounter < 30)
    % retrieve current trackload
    [success, trackload] = soundmexpro('trackload');
    if success ~= 1
        error(['error calling ''trackload''' error_loc(dbstack)]);
    end
    % more that 10 segments pending? do not load new data
    if (trackload(1) > 10)
        busycounter =  busycounter + 1;
    else
        [success] =  soundmexpro('loadmem', 'data', signal);
        if success ~= 1
            error(['error calling ''loadmem''' error_loc(dbstack)]);
        end
        successcounter = successcounter + 1;
    end
    
    % very small pause. 
    pause(0.01);
end

% check, if we had underruns (not expected!)
[success, underrun] =  soundmexpro('underrun');
if success ~= 1
    error(['error calling ''underrun''' error_loc(dbstack)]);
end
if max(underrun) > 0
    smp_disp('UNEXPECTEDLY THERE WAS A DATA UNDERRUN');
else
    smp_disp(['no underrun occurred, ' num2str(busycounter) ' times data loading was skipped']);
end
if 1 ~= soundmexpro('stop')
    error(['error calling ''stop''' error_loc(dbstack)]);
end

pause(0.5);

% -------------------------------------------------------------------------
%% 3: we are too slow (in this example far too slow), so we hear
% dropouts and can detect the underrun afterwards!
smp_disp(' ');
smp_disp('-------------------------------------------------------------------------');
smp_disp('Third example: an underrun occurs');

% in this example we show usage of 'debugsave' as well: we save the final
% output of the first channel and plot it afterwards

% switch on debug saving
if 1 ~= soundmexpro('debugsave', ...    % command name
        'value', 1, ...                 % enable/disable flag (here: enable)
        'channel', 0 ...                % channel(s) where to apply value
        )
    error(['error calling ''debugsave''' error_loc(dbstack)]);
end

% pre-load one buffer
if 1 ~= soundmexpro('loadmem', 'data', signal)
    error(['error calling ''loadmem''' error_loc(dbstack)]);
end

% start device in 'play-zeros-if-no-data-pending'-mode
if 1 ~= soundmexpro('start', ...   % command name
        'length', 0 ...            % 'play-zeros-if-no-data-in-tracks'-mode
        )
    error(['error calling ''start''' error_loc(dbstack)]);
end

for i = 1:10
    [success] =  soundmexpro('loadmem', 'data', signal);
    if success ~= 1
        error(['error calling ''loadmem''' error_loc(dbstack)]);
    end
    % pause, that is quite too long
    pause(0.2);
end

% check, if we had underruns: expected this time!
[success, underrun] =  soundmexpro('underrun');
if success ~= 1
    error(['error calling ''underrun''' error_loc(dbstack)]);
end
if max(underrun) < 1
    smp_disp('UNEXPECTEDLY THERE WAS NO DATA UNDERRUN');
end

if 1 ~= soundmexpro('stop')
    error(['error calling ''stop''' error_loc(dbstack)]);
end
pause(0.01)
% plot the 'debugsave' data. NOTE: MATLAB versions < 6 do not support
% reading 32bit float waves, so in that case we use the tool script shipped
% with SoundMexPro 
if strncmp(version, '5', 1) == 1
   x = wavread_sdp('out_0.wav');
else
   if 0 == exist('audioread') 
       x = wavread('out_0.wav');
   else
       x = audioread('out_0.wav');
   end
end

   
plot(x);
delete('out_0.wav');
smp_disp('Hit a key to continue');
userinteraction
close all;
% done
clear soundmexpro;
