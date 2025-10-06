%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
%
% This example shows how to do complex 'wiring' with multiple VST plugins
% and what this means for the data flow. It is a pure 'artificial' example
% using a simple 'gain' plugin supporting uo to 8 inputs and outputs and
% using articficial audio data (a diagonal matrix) to 'see' after
% processing, which channels were mixed and what gains were applied
% NOTE: you will need a soundcard with four channels at least to run this
% example!
%
% SoundMexPro commands introduced in this example:
%   vstload
%   vstparam


% call tutorial-initialization script
t_00b_init_tutorial

channels = 4;

% initialise first four channels
output = [0:channels-1];
if 1 ~= soundmexpro('init', ...         % command name
        'driver', smpcfg.driver , ...   % driver index
        'output', output ...            % list of output channels to use
        )
    error(['error calling ''init''' error_loc(dbstack)]);
end

% Creating diagonal dummy data and load them
audiodata = diag(ones(channels,1), 0);

if 1 ~= soundmexpro('loadmem', ...  % command name
        'data', audiodata, ...      % data (here: only first channel)
        'loopcount', 1024 ...       % loopcount
        )
    error(['error calling ''loadmem''' error_loc(dbstack)]);
end

% switch on debug saving for all channels
if 1 ~= soundmexpro('debugsave', ...    % command name
        'value', 1 ...                  % enable/disable flag (here: enable)
        )
    error(['error calling ''debugsave''' error_loc(dbstack)]);
end

% NOTE: in the following all values, parameters and programs are set
% 'manually' (without using config file) to 'see' directly what is done
% here. 

% Load five plugins. The wiring is shown on the left side of the scheme
% below: the lines symbolize the audio data flow. Data are flowing
% from top to bottom. The p? are plugins. For example at position (layer) 1
% only one plugin is loaded (p3) using channels 1 and 2 as inputs and
% channels 1 and 3 as output. On the right hand the audio data between the 
% different layers are shown assuming 'pure' data as the channel numbers
% from 0 to 3 at the top. Processed data are symbolized by the plugin name
% as function, e.g. data 1 proccessed by plugin p4 are symbolized by p4(1).
%
%          Wiring                           Channel data 
%          ------                           ------------
%
%                 |   |   |   |             0           1           2           3                   
%                 |   |   |   |
% Position 0      p1  p1  p2  |
%                 |   |   |   |
%                 |   |   |   |             p1(0)       p1(1)       p2(2)       3
%                 |   |   |   |
% Position 1      |   p3  p3  |
%                 |   |    \  |
%                 |   |     \_|             p1(0)       p3(p1(1))   empty       p3(p2(2)) + 3
%                 |   |       |
% Position 2      p4  |       p5
%                  \  |       |
%                   \_|       |             empty       p4(p1(0))   empty       p5(p3(p2(2)) + 3)
%                     |       |                         +p3(p1(1))


% load plugin p1
if 1 ~= soundmexpro('vstload', ...                  % command name
        'filename', '..\plugins\HtVSTGain.dll', ... % filename of plugin
        'type', 'master', ...                       % plugin type ('master' is default)
        'input', [0 1], ...                         % inputs to use
        'output', [0 1], ...                        % outputs to use
        'position', 0 ...                           % vertical position (layer) where to load plugin to
        )
    error(['error calling ''vstload''' error_loc(dbstack)]);
end
% load plugin p2
if 1 ~= soundmexpro('vstload', ...                  % command name
        'filename', '..\plugins\HtVSTGain.dll', ... % filename of plugin
        'type', 'master', ...                       % plugin type ('master' is default)
        'input', 2, ...                             % inputs to use
        'output', 2, ...                            % outputs to use
        'position', 0 ...                           % vertical position (layer) where to load plugin to
        )
    error(['error calling ''vstload''' error_loc(dbstack)]);
end
% load plugin p3
if 1 ~= soundmexpro('vstload', ...                  % command name
        'filename', '..\plugins\HtVSTGain.dll', ... % filename of plugin
        'type', 'master', ...                       % plugin type ('master' is default)
        'input', [1 2], ...                         % inputs to use
        'output', [1 3], ...                        % outputs to use
        'position', 1 ...                           % vertical position (layer) where to load plugin to
        )
    error(['error calling ''vstload''' error_loc(dbstack)]);
end
% load plugin p4
if 1 ~= soundmexpro('vstload', ...                  % command name
        'filename', '..\plugins\HtVSTGain.dll', ... % filename of plugin
        'type', 'master', ...                       % plugin type ('master' is default)
        'input', 0, ...                             % inputs to use
        'output', 1, ...                            % outputs to use
        'position', 2 ...                           % vertical position (layer) where to load plugin to
        )
    error(['error calling ''vstload''' error_loc(dbstack)]);
end
% load plugin p5
if 1 ~= soundmexpro('vstload', ...                  % command name
        'filename', '..\plugins\HtVSTGain.dll', ... % filename of plugin
        'type', 'master', ...                       % plugin type ('master' is default)
        'input', 3, ...                             % inputs to use
        'output', 3, ...                            % outputs to use
        'position', 2 ...                           % vertical position (layer) where to load plugin to
        )
    error(['error calling ''vstload''' error_loc(dbstack)]);
end


% set different linear gains for all five plugins
if 1 ~= soundmexpro('vstparam', ...             % command name
        'input', 0, ...                         % one of the inputs, where plugin is plugged to
        'position', 0, ...                      % vertical position (layer) where plugin is loaded
        'parameter', {'gain_0', 'gain_1'}, ...  % cell array with parameter names to set
        'value', [0.2 0.2] ...                  % vector with values to set
        )
    error(['error calling ''vstparam''' error_loc(dbstack)]);
end
if 1 ~= soundmexpro('vstparam', ...             % command name
        'input', 2, ...                         % one of the inputs, where plugin is plugged to
        'position', 0, ...                      % vertical position (layer) where plugin is loaded
        'parameter', {'gain_0'}, ...            % cell array with parameter names to set
        'value', 0.3 ...                       % vector with values to set
        )
    error(['error calling ''vstparam''' error_loc(dbstack)]);
end
if 1 ~= soundmexpro('vstparam', ...             % command name
        'input', 1, ...                         % one of the inputs, where plugin is plugged to
        'position', 1, ...                      % vertical position (layer) where plugin is loaded
        'parameter', {'gain_0', 'gain_1'}, ...  % cell array with parameter names to set
        'value', [0.4 0.4] ...                  % vector with values to set
        )
    error(['error calling ''vstparam''' error_loc(dbstack)]);
end
if 1 ~= soundmexpro('vstparam', ...             % command name
        'input', 0, ...                         % one of the inputs, where plugin is plugged to
        'position', 2, ...                      % vertical position (layer) where plugin is loaded
        'parameter', {'gain_0'}, ...            % cell array with parameter names to set
        'value', 0.5 ...                        % vector with values to set
        )
    error(['error calling ''vstparam''' error_loc(dbstack)]);
end
if 1 ~= soundmexpro('vstparam', ...             % command name
        'input', 3, ...                         % one of the inputs, where plugin is plugged to
        'position', 2, ...                      % vertical position (layer) where plugin is loaded
        'parameter', {'gain_0'}, ...            % cell array with parameter names to set
        'value', 0.6 ...                        % vector with values to set
        )
    error(['error calling ''vstparam''' error_loc(dbstack)]);
end


% start and wait
if 1 ~= soundmexpro('start')
    error(['error calling ''start''' error_loc(dbstack)]);
end
if 1 ~= soundmexpro('wait', 'mode', 'stop')
    error(['error calling ''wait''' error_loc(dbstack)]);
end
pause(0.5);

% read the four debugfiles and 'rebuild' data matrix
wavedata = [];
for i = 0:channels-1
    % read it (for MATLAB 5.x use script shipped with SoundMexPro)
    if strncmp(version, '5', 1) == 1
        tmp = wavread_sdp(['out_' num2str(i) '.wav']);
    else
        if 0 == exist('audioread')
            tmp = wavread(['out_' num2str(i) '.wav']);
        else
            tmp = audioread(['out_' num2str(i) '.wav']);
        end
    end
    % delete debug file
    delete(['out_' num2str(i) '.wav']);
    % concatenate
    wavedata = [wavedata  tmp];
end
wavedata
% plot four saved samples from somewhere in the middle (no ramping active
% anymore
wavedata(1002:1005,1:end)

% compare with upper scheme:
% - input data are ones
% - gains (fatcors) are 0.2 ... 0.6

% -     first column should contain zeros only
% -     second column should contain:
%          first line: p4(p1(0)), i.e. 0.5*0.2*1 = 0.1
%          second line: p3(p1((1)), i.e. 0.4*0.2*1 = 0.08
%          others: zero 
% -     third column should contain zeros only
% -     fourth column should contain 
%          first two lines zero
%          third line: p5(p3(p2(2)), i.e. 0.6*0.4*0.3*1 = 0.072
%          fourth line: p5(3), i.e. 0.6*1 = 0.6
% thus should look like:
%          0    0.1000         0         0
%          0    0.0800         0         0
%          0         0         0    0.0720
%          0         0         0    0.6000

clear soundmexpro
