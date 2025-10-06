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

% load sine plugin in first track
if 1~= soundmexpro('vstload', ...                           % command name
        'filename', '..\..\plugins\HtVSTSine.dll', ... % VST plugin name
        'input', [0], ...                                 % input(s) to use
        'output', [0], ...                                % output(s) to use
        'type', 'track', ...                               % plugin type
        'position', 0 ...                                   % plugin position
        )
    error(['error calling ''vstload''' error_loc(dbstack)]);
end


% a. retrieve values of all parameters. NOTE: 'gain_0' was set to 0.8 by
% configfile above
[success, params, values] = soundmexpro('vstparam', ... % command name
        'type', 'track', ...                            % plugin type ('master' is default)
        'input', 0, ...                                 % one of the inputs where plugin is loaded to 
        'position', 0 ...                               % vertical position (layer) where plugin is loaded to
        );
if 1 ~= success
    error(['error calling ''vstparam''' error_loc(dbstack)]);
end
smp_disp('current parameter values:');
for i = 1 : length(params)
    smp_disp(['   ' params{i} ': ' num2str(values(i))]);
end
%return

% call plugin's editor (you may change gain and enable/disable plugin
if 1 ~= soundmexpro('vstedit', 'type', 'track')
    error(['error calling ''vstedit''' error_loc(dbstack)]);
end
%return
% go
if 1 ~= soundmexpro('start', 'length', 0)
    error(['error calling ''start''' error_loc(dbstack)]);
end


pause

% enable filter
if 1 ~= soundmexpro('vstparam',  ...                % command name
        'parameter', 'frequency', ...                 % parameter names
        'value', 880/22050, ...                              % parameter values
        'type', 'track' ... 
        )
    error(['error calling ''vstparam''' error_loc(dbstack)]);
end


pause

clear soundmexpro;


