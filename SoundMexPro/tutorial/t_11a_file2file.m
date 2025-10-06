%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
%
% This example shows how to run file-to-file operation rather than using a
% real sound device. Using file-to-file operation is useful (only), if you
% want to evaluate own plugins (VST or MATLAB-script-plugins) that are too
% slow for real-time operation. If such 'slow' plugins are used with regular
% soundcard operation, then xruns (dropouts) would occur, because regular 
% operation is hardware driven (i.e. the soundcard driver calls SoundMexPro
% when it needs data).
% If you (only) want to store the output data (i.e. the audio data passed
% to the output channels) without evaluating such 'slow' plugins, then you 
% may use the command 'debugsave' rather than using file-to-file operation!
%
% SoundMexPro commands introduced in this example:
%   parameters 'file2file' and 'f2fbufsize' for command 'init'
%   f2ffilename


% call tutorial-initialization script
t_00b_init_tutorial

% initialize SoundMexPro in file2file-mode using 2 channels and 4 tracks
% NOTE: here you may specify your MATLAB script-plugins, see tutorials
% t_07*
if 1 ~= soundmexpro('init', ...     % command name
        'file2file', 1, ...         % switch on file2file-mode
        'f2fbufsize', 1024, ...     % buffersize to use for file2file-mode (1024 is default)
        'samplerate', 44100, ...    % samplerate to use for file2file-mode (44100 is default)
        'output', 2, ...            % number of output channels to use
        'track', 4 ...              % number of tracks to use  with standards mapping
        )
    error(['error calling ''init''' error_loc(dbstack)]);
end

% set the filenames for the output files other than default
if 1 ~= soundmexpro('f2ffilename', ...                  % command name
        'channel', [0 1], ...                           % channels to set filename for
        'filename', {'myfile1.wav', 'myfile2.wav'}...   % cell array with filenames
        )
    error(['error calling ''f2ffilename''' error_loc(dbstack)]);
end

% now you may load your VST-plugin(s), see tutorial t_09b_vst_gain and
% advanced examples in directory 'examples'

% load audio data to first two tracks (one track on each output channel
if 1 ~= soundmexpro('loadfile', ...                 % command name
        'filename', '../waves/eurovision.wav', ...  % filename
        'track', [0 1], ...                        % load it to first two tracks
        'loopcount', 2 ...                          % loopcount
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

% load a noise to 3rd track (to be added to output channel 0)
if 1 ~= soundmexpro('loadfile', ...                 % command name
        'filename', '../waves/noise_16bit.wav', ... % filename
        'track', [-1 2], ...                        % tracks, here 2 (other channel of file discarded by -1)
        'loopcount', 1 ...                          % loopcount
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

% create and load a modulation sine to track 3
% Create a modulation sine 
modsin = 1 + 0.8*sin([0:44100-1]'/44100*pi*16); 
% set track mode of corresponding track to 'multiply'
if 1 ~= soundmexpro('trackmode', ...    % command name
        'track', 3, ...                 % track to apply mode to
        'mode', 1 ...                   % track mode, here: multiplication (0 is adding)
        )
    error(['error calling ''trackmode''' error_loc(dbstack)]);
end
% then load modulation sine to that track
if 1 ~= soundmexpro('loadmem', ...      % command name
        'data', modsin, ...             % data vector
        'name', 'modulator', ...        % name used in track view for this vector
        'loopcount', 4, ...             % loopcount
        'track', 3 ...                  % track to load data to
        )
    error(['error calling ''loadmem''' error_loc(dbstack)]);
end

% go!
if 1 ~= soundmexpro('start')
    error(['error calling ''start''' error_loc(dbstack)]);
end

smp_disp('file2file-operation done');
drawnow;
% ---- now file2file-operation is complete --------------------------------

% now load the created files in 'regular' mode, show and play them
soundmexpro('exit');

% initialize 
if 1 ~= soundmexpro('init', ...         % command name
        'driver', smpcfg.driver,  ...       % driver index
        'output', smpcfg.output ...    % list of output channels to use            
        )
    error(['error calling ''init''' error_loc(dbstack)]);
end

% load the files
if 1 ~= soundmexpro('loadfile', ...     % command name
        'filename', 'myfile1.wav', ...  % first file (noise + music)
        'track', 0 ...                  % first track
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end
if 1 ~= soundmexpro('loadfile', ...     % command name
        'filename', 'myfile2.wav', ...  % second file (modulated music)
        'track', 1 ...                  % second track
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

% show tracks with option to paint wve data
if 1 ~= soundmexpro('showtracks', 'wavedata', 1)
    error(['error calling ''start''' error_loc(dbstack)]);
end

% start ...
if 1 ~= soundmexpro('start')
    error(['error calling ''start''' error_loc(dbstack)]);
end
% ... and wait for playback to be finished
if 1 ~= soundmexpro('wait')
    error(['error calling ''wait''' error_loc(dbstack)]);
end

smp_disp('Hit a key to quit example');
userinteraction

delete('myfile1.wav');
delete('myfile2.wav');

clear soundmexpro;
close all; 
