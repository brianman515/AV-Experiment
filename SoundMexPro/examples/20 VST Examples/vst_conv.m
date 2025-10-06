%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
% This example shows the usage of the convolution plugin HtVSTConv.dll

% call tutorial-initialization script
addpath('..\..\tutorial');
t_00b_init_tutorial

% initialize two output channels, no input (default),
% with numbufs = 0 (minium delay!)
if 1 ~= soundmexpro('init', ...
        'driver', smpcfg.driver,  ...                   % driver index
        'output', smpcfg.output, ...                    % list of output channels to use            
        'numbufs', 0 ...
        )
    error(['error calling ''init''' error_loc(dbstack)]);
end

% show visualization
if 1 ~= soundmexpro('show')
    error(['error calling ''show''' error_loc(dbstack)]);
end


% load aufio file
if 1 ~= soundmexpro('loadfile', ...                 % command name
        'filename', '../../waves/eurovision.wav', ...  % filename
        'loopcount', 0 ...                          % endless loop 
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

% lower volume to avoid clipping
if 1 ~= soundmexpro('volume', 'value', 0.1)
    error(['error calling ''volume''' error_loc(dbstack)]);
end

% load the plugin
if 1 ~= soundmexpro('vstload', ...                  % command name
        'filename', '../../plugins/HtVSTConv.dll', ... % plugin name
        'input', [0 1], ...                         % inputs to use
        'output', [0 1] ...                         % outputs to use
        )
    error(['error calling ''vstload''' error_loc(dbstack)]);
end


% load an impulse response
if 1 ~= soundmexpro('vstprogramname', ...
        'programname', '..\..\plugins\ir.wav' ...
        )
    error(['error calling ''vstprogramname''' error_loc(dbstack)]);
end


% call plugin's editor (you may change gain and enable/disable plugin
if 1 ~= soundmexpro('vstedit')
    error(['error calling ''vstedit''' error_loc(dbstack)]);
end

% go!
if 1 ~= soundmexpro('start')
    error(['error calling ''start''' error_loc(dbstack)]);
end

userinteraction


clear soundmexpro;
close all;



