%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
%
% This example shows simple usage of a VST plugins 'routing'. This example
% is described in the manual in the chapter 'I/O-configuration of
% VST-plugins'
% NOTE: you will need a soundcard with four channels at least to run this
% example!
%
% SoundMexPro commands introduced in this example:
%   vstload


% call tutorial-initialization script
t_00b_init_tutorial

channels = 4;

% initialise first four channels: may fail, if driver has not four
% channels!
output = [0:channels-1];
if 1 ~= soundmexpro('init', ...         % command name
        'driver', smpcfg.driver, ...    % driver index
        'output', output ...            % list of output channels to use
        )
    error(['error calling ''init''' error_loc(dbstack)]);
end

% show device visualization
if 1 ~= soundmexpro('show')
    error(['error calling ''show''' error_loc(dbstack)]);
end

% load four different sine signals to the four tracks
if 1 ~= soundmexpro('loadfile', ...            % command name
        'filename', '../waves/300Hz.wav', ...  % filename
        'track', 0, ...                        % track 
        'loopcount', 3 ...                     % loop count
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end
if 1 ~= soundmexpro('loadfile', ...            % command name
        'filename', '../waves/400Hz.wav', ...  % filename
        'track', 1, ...                        % track 
        'loopcount', 3 ...                     % loop count
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end
if 1 ~= soundmexpro('loadfile', ...            % command name
        'filename', '../waves/500Hz.wav', ...  % filename
        'track', 2, ...                        % track 
        'loopcount', 3 ...                     % loop count
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end
if 1 ~= soundmexpro('loadfile', ...            % command name
        'filename', '../waves/600Hz.wav', ...  % filename
        'track', 3, ...                        % track 
        'loopcount', 3 ...                     % loop count
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

% switch on debug saving for all channels
if 1 ~= soundmexpro('debugsave', ...    % command name
        'value', 1 ...                  % enable/disable flag (here: enable)
        )
    error(['error calling ''debugsave''' error_loc(dbstack)]);
end

% load plugin (routed as in description of this example in the manual). 
% NOTE: this example is only intended to demonstrate the I/O-configuration
% (routing) of VST plugins. No gains are applied, the plugin here is
% 'abused' as some kind of audio mixer. See tutorial 't_09c_vst_gain.m' for
% using the gain parameters of this plugin!
if 1 ~= soundmexpro('vstload', ...                          % command name
            'filename', '..\plugins\HtVSTGain.dll', ...     % filename of plugin binary
            'type', 'track', ...                            % plugin type, here: track plugin
            'input', [0 3], ...                             % tracks to read data from
            'output', [1 2] ...                             % tracks to write processed data to
	)
    error(['error calling ''vstload''' error_loc(dbstack)]);
end
% This routing of inputs and outputs will lead to 
%  track 0: silence 
%  track 1: sum of 300Hz (through plugin from track 0) and a 400Hz (originally in track1)
%  track 2: sum of 600Hz (through plugin from track 3) and a 500Hz (originally in track2)
%  track 3: silence 

% start playback 
if 1 ~= soundmexpro('start', ...    % command name
        'length', -1 ...            % length, here -1: stop if no track has more data (this is default)
        )
    error(['error calling ''start''' error_loc(dbstack)]);
end
% and wait for it to be complete
if 1 ~= soundmexpro('wait', 'mode', 'stop')
    error(['error calling ''wait''' error_loc(dbstack)]);
end

smp_disp('done. You may check the debug files out_0.wav ... out_3.wav to see what was played');

clear soundmexpro
