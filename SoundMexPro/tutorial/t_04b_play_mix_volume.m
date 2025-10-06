%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
% This example shows playback of multiple files, vectors, on multiple
% tracks including muliple tracks per channel (mixing), setting of
% (channel) volume and track volume respectively.
%
% SoundMexPro commands introduced in this example:
%   loadmem playposition volume trackvolume trackmode clipcount
% 
% NOTE: this example is the first that really uses multiple virtual tracks,
% so it is essential to know the basic concept of virtual tracks and to
% realize the difference between channels and virtual tracks. Please refer 
% to the SoundMexPro manual for an introduction on this topic.
%
% NOTE: the second return value of the commands 'loadfile' and 'loadmem' 
% (the 'busy' flag) is not checked here. See example
% t_04c_play_con_stim_gen.m for that task.
% 
% SoundMexPro commands introduced in this example:
%   showtracks
%   hidetracks
%   updatetracks
%   showmixer
%   hidemixer
%   clipcount
%   resetclipcount



% call tutorial-initialization script
t_00b_init_tutorial


% initialize two output channels, no input (default)
% NOTE; here we initialize 8 virtual tracks with default track mapping,
% i.e. tracks 0 and 2 are played on output channel 0, and tracks 1 and 3
% are played on output channel 1!
if 1 ~= soundmexpro('init', ...         % command name
        'driver', smpcfg.driver , ...       % driver index
        'output', smpcfg.output, ...   % list of output channels to use            
        'track', 4 ...                  % number of virtual tracks, here 4 (i.e. 2 tracks per channel)
        )
    error(['error calling ''init''' error_loc(dbstack)]);
end


% -------------------------------------------------------------------------
%% 1. Mixed playback.
% We setup a mixture of files, vectors, mixing files and mixing vectors for
% playback.
smp_disp('Example 1: mixed playback of files, memory ...');
% Start with a stereo file to be played on both channels 
if 1 ~= soundmexpro('loadfile', ...                 % command name
        'filename', '../waves/noise_16bit.wav', ... % filename
        'ramplen', 10000, ...                       % apply a ramp in the beginning and the end 
        'track', [0 1], ...                         % tracks, here 0 and 1 (one track on each channel)
        'loopcount', 1 ...                          % loopcount
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

% then append a sweep to same tracks, (for demonstration purposes loaded from to a vector)
if 0 == exist('audioread')
    sweep = wavread('../waves/sweep.wav')./4;
else
    sweep = audioread('../waves/sweep.wav')./4;
end
if 1 ~= soundmexpro('loadmem', ...      % command name
        'data', sweep, ...              % data vector
        'name', 'sweep', ...            % name used in track view for this vector
        'ramplen', 20000, ...           % apply a ramp in the beginning and the end 
        'loopramplen', 5000, ...        % apply a ramp when looping
        'track', [0 1], ...             % tracks, here 0 and 1 (one track on each channel)
        'loopcount', 3 ...              % loopcount
        )
    error(['error calling ''loadmem''' error_loc(dbstack)]);
end

% Create a modulation sine 
modsin = 0.5 + 0.5*sin([0:44100-1]'/44100*pi*8);
% Multiply first track with this sine. For this purpose we set the track
% mode of the third track of output channel 0 to multiply mode
if 1 ~= soundmexpro('trackmode', ...    % command name
        'track', 2, ...                 % track to apply mode to
        'mode', 1 ...                   % track mode, here: multiplication (0 is adding)
        )
    error(['error calling ''trackmode''' error_loc(dbstack)]);
end
% then load modulation sine to that track
if 1 ~= soundmexpro('loadmem', ...      % command name
        'data', modsin, ...             % data vector
        'name', 'modulator', ...        % name used in track view for this vector
        'loopcount', 2, ...             % loopcount
        'track', 2 ...                  % track to load data to
        )
    error(['error calling ''loadmem''' error_loc(dbstack)]);
end

% on the other channel add some other audio data for additive mixing 
if 1 ~= soundmexpro('loadfile', ...                  % command name
        'filename', '../waves/eurovision.wav', ...  % filename
        'track', [-1, 3], ...                       % ignore first file channel, play second on track 3 (second track of channel 1)
        'offset', 44100, ...                        % add 1 second of silence to the beginning
        'loopramplen', 10000, ...                   % apply a ramp for loops ...
        'loopcrossfade', 1, ...                     % ... and use this ramp for a crossfade
        'loopcount', 2 ...                          % loopcount
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

% show track view visualization (updates tracks as well)
if 1 ~= soundmexpro('showtracks', 'wavedata', 1)
    error(['error calling ''showtracks''' error_loc(dbstack)]);
end

% start playback
if 1 ~= soundmexpro('start')
    error(['error calling ''start''' error_loc(dbstack)]);
end

% check if at least one of the tracks 2 and 3 (zero based!), is still
% playing
while 1
    % query device
    [success, playing] = soundmexpro('playing');
    % check success of command itself
    if success ~= 1;
        clear soundmexpro
        error(['error calling ''playing''' error_loc(dbstack)]);
    end
    % then check the last two tracks (NOTE: vector is 1-based!)
    if (max(playing(3:end)) == 0)
        break;
    end
    
    % NOTE: no while loops without a pause!
    pause(0.1);
    % show playback position
    [success, position] = soundmexpro('playposition');
    if success ~= 1
        clear soundmexpro
        error(['error calling ''playposition''' error_loc(dbstack)]);
    end
    smp_disp(['played ' num2str(position) ' samples']);
end
smp_disp('mixing done');
if 1 ~= soundmexpro('wait', 'mode', 'stop')
    error(['error calling ''wait''' error_loc(dbstack)]);
end

smp_disp('playing done. Hit a key to proceed with next example.');
userinteraction

% reset all tracks to standard adding mode!
if 1 ~= soundmexpro('trackmode', ...    % command name
        'mode', 0 ...                   % track mode, here: adding
        )
    error(['error calling ''trackmode''' error_loc(dbstack)]);
end

% -------------------------------------------------------------------------
%% 2. Demonstration of how multichannel data are 'aligned' if loaded to
% tracks with different amount of data loaded earlier
smp_disp('Example 2: demonstration of "alignment"');

% Start with a stereo file, where we only use first channel on first track,
% therefore second track stays empty!
if 1 ~= soundmexpro('loadfile', ...                 % command name
        'filename', '../waves/sweep.wav', ...       % filename
        'track', [0 -1], ...                        % tracks, here 0 and -1 (ignore second file channel)
        'loopcount', 2 ...                          % loopcount
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

% Then a stereo file to be played on both channels: this must result in
% prepended zeros for second channel, so that you first should hear the sweep on
% the first channel only, and afterwards 'eurovision.wav' on both channels
% 'synchronized'
if 1 ~= soundmexpro('loadfile', ...                 % command name
        'filename', '../waves/eurovision.wav', ... % filename
        'offset', 22050,...
        'track', [0 1], ...                         % tracks, here 0 and 1 (one track on each channel)
        'loopcount', 1 ...                          % loopcount
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

if 1 ~= soundmexpro('showtracks', 'wavedata', 1)
    error(['error calling ''updatetracks''' error_loc(dbstack)]);
end

% start playback
if 1 ~= soundmexpro('start')
    error(['error calling ''start''' error_loc(dbstack)]);
end

if 1 ~= soundmexpro('wait', 'mode', 'stop')
    error(['error calling ''wait''' error_loc(dbstack)]);
end


smp_disp('playing done. Hit a key to proceed with next example.');
userinteraction

if 1 ~= soundmexpro('stop')
    error(['error calling ''stop''' error_loc(dbstack)]);
end

% hide track view visualization
if 1 ~= soundmexpro('hidetracks')
    error(['error calling ''hidetracks''' error_loc(dbstack)]);
end

% -------------------------------------------------------------------------
%% 3. Using volume and trackvolume and checking clipcount
% Play some noise and start mixing a sweep later
smp_disp('Example 3: volume, trackvolume, clipcount ...');

% In the beginning set (channel) volume of all channels to avoid clipping
[success, volume] = soundmexpro('volume', ...   % command name
    'value', 0.5 ...                            % same volume for the two channels
    );
if success ~= 1
    error(['error calling ''volume''' error_loc(dbstack)]);
end
% show current volumes in dB fullscale
smp_disp(['set total attenuation to ' num2str(20*log10(volume(1))) ' dB']);

% load noise
if 1 ~= soundmexpro('loadfile', ...                 % command name
        'filename', '../waves/noise_16bit.wav', ... % filename
        'track', [0 1], ...                         % tracks, here 0 and 1 (one track on each channel)
        'loopcount', 0 ...                          % loopcount (endless loop)
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

% show mixer
if 1 ~= soundmexpro('showmixer')
    error(['error calling ''showmixer''' error_loc(dbstack)]);
end

% start playback
if 1 ~= soundmexpro('start')
    error(['error calling ''start''' error_loc(dbstack)]);
end
% wait a bit 
pause(1);

% start mixing data on both channels using the next virtual tracks
if 1 ~= soundmexpro('loadfile', ...             % command name
        'filename', '../waves/sweep.wav', ...  % filename
        'track', [2 3], ...                    % tracks, here 2 and 3 (one track on each channel)
        'loopcount', 0 ...                     % loopcount (endless loop)
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

% now change volumes of tracks '0 and 1' or '2 and 3' respectively to
% change 'SNR'. NOTE: we define an SNR of 0 dB here as same volume of the
% noise and the sweep!
smp_disp('playing sweep in noise at 0 dB SNR on both channels. Hit a key to continue');
userinteraction

% now change volume sweep only and calculate new SNR
[success, volume] = soundmexpro('trackvolume', ...  % command name
    'track', [2 3], ...                             % tracks, here 2 and 3 (sweep)
    'value', [0.1 0.5] ...                          % volume values for sweep
    );
if success ~= 1
    error(['error calling ''trackvolume''' error_loc(dbstack)]);
end
% calculate new SNR
snr = 20*log10(volume(3:4)./volume(1:2));
smp_disp(['First channel: ' num2str(snr(1), 2) ' dB SNR, second channel: ' num2str(snr(2), 2)  ' dB SNR . Hit a key to continue']);
userinteraction

% now change volume of noise and sweep part simultaneously and calculate new SNR
% Here we additionally do volume setting with a ramp
[success, volume] = soundmexpro('trackvolume', ...  % command name
    'track', [0 1 2 3], ...                         % tracks, here 2 and 3 (sweep)
    'value', [0.5 0.4 0.9 0.9], ...                 % volume values for sweep
    'ramplen', 22050 ...                            % use a ramp of half a second
    );
if success ~= 1
    error(['error calling ''trackvolume''' error_loc(dbstack)]);
end
snr = 20*log10(volume(3:4)./volume(1:2));
smp_disp(['First channel: ' num2str(snr(1), 2) ' dB SNR, second channel: ' num2str(snr(2), 2)  ' dB SNR.']);

% check, if we had clippings up to now (not expected).
[success, clip] = soundmexpro('clipcount');
if success ~= 1
    error(['error calling ''clipcount''' error_loc(dbstack)]);
end
smp_disp(['Clipped buffers on first channel: ' int2str(clip(1)) ', on second channel: ' int2str(clip(2)) '.  Hit a key to continue']);
userinteraction

% show mixer visualization with 'topmost' flag
if 1 ~= soundmexpro('showmixer', 'topmost', 1)
    error(['error calling ''showmixer''' error_loc(dbstack)]);
end

% now raise master volume on first channel to force clipping. Here we show
% as well the argument 'channel' for 'volume': we specify one channel and
% one volume to keep volume on other chanel unchanged!
if 1~= soundmexpro('volume', ...    % command name
        'value', 3, ...             % different volumes
        'channel', 0 ...            % channel to apply volume to
        )
    error(['error calling ''volume''' error_loc(dbstack)]);
end
% wait a bit
pause(1.5);
% check clipping again: now be should have had clipping on the first
% channel!
[success, clip] = soundmexpro('clipcount');
if success ~= 1
    error(['error calling ''clipcount''' error_loc(dbstack)]);
end
smp_disp(['Clipped buffers on first channel: ' int2str(clip(1)) ', on second channel: ' int2str(clip(2))]);
smp_disp('Note overdrive LED''s on mixer. Hit a key to continue');
userinteraction

if 1 ~= soundmexpro('stop')
    error(['error calling ''stop''' error_loc(dbstack)]);
end

% reset clipcount
if 1 ~= soundmexpro('resetclipcount')
    error(['error calling ''resetclipcount''' error_loc(dbstack)]);
end
% retrieve clipcoutn again: should be zero again
[success, clip] = soundmexpro('clipcount');
if success ~= 1
    error(['error calling ''clipcount''' error_loc(dbstack)]);
end
smp_disp(['Clipcounts resetted: clipped buffers on first channel: ' int2str(clip(1)) ', on second channel: ' int2str(clip(2))]);

smp_disp('Hit a key to quit example');
userinteraction

% hide mixer 
if 1 ~= soundmexpro('hidemixer')
    error(['error calling ''hidemixer''' error_loc(dbstack)]);
end


% done
clear soundmexpro;
