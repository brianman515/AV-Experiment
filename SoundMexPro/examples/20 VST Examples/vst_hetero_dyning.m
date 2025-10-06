%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
% This example shows the usage of the VST hetero-dyning plugin HtVSTHeteroDyning.dll

% call tutorial-initialization script
addpath('..\..\tutorial');
t_00b_init_tutorial

% initialize with default values (two outout channels
if 1 ~= soundmexpro('init', ...                             % command name
        'driver', smpcfg.driver,  ...                       % driver index
        'output', smpcfg.output ...                         % list of output channels to use            
        )
    error(['error calling ''init''' error_loc(dbstack)]);
end

% load hetero-dyning plugin 
if 1~= soundmexpro('vstload', ...                           % command name
        'filename', '..\..\plugins\HtVSTHeteroDyning.dll', ... % VST plugin name
        'input', [0 1], ...                                 % input(s) to use
        'output', [0 1], ...                                % output(s) to use
        'type', 'master', ...                               % plugin type
        'position', 0 ...                                   % plugin position
        )
    error(['error calling ''vstload''' error_loc(dbstack)]);
end

% set hetero-dyning frequencies of first two channels and disable filter
% within one command
% NOTE: frequencies are fractions of samplerate. We set first channel to 4
% Hz (more a modulation) and second to 400 Hz
if 1 ~= soundmexpro('vstparam',  ...                                % command name
        'parameter', {'enabled', 'frequency_0', 'frequency_1'}, ... % parameter names
        'value', [0 4/44100 400/44100] ...                          % parameter values
        )
    error(['error calling ''vstparam''' error_loc(dbstack)]);
end

% load audio file
if 1 ~= soundmexpro('loadfile', ...                     % command name
        'filename', '../../waves/eurovision.wav', ...   % filename
        'loopcount', 0 ...                              % endless loop 
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end
% go
if 1 ~= soundmexpro('start')
    error(['error calling ''start''' error_loc(dbstack)]);
end

% wait a bit
pause(4);

% enable filter
if 1 ~= soundmexpro('vstparam',  ...                % command name
        'parameter', 'enabled', ...                 % parameter names
        'value', 1 ...                              % parameter values
        )
    error(['error calling ''vstparam''' error_loc(dbstack)]);
end


pause(4);

clear soundmexpro;


