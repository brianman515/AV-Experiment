
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
% This example shows the usage of the VST visualization plugin HtVSTVisualize.dll

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

% load visualization plugin to first channel with setting programname
% immediately (i.e. the inifile name to use)
if 1~= soundmexpro('vstload', ...                           % command name
        'filename', '..\..\plugins\htvstvisualize.dll', ...    % VST plugin name
        'input', 0, ...                                     % input(s) to use
        'output', 0, ...                                    % output(s) to use
        'type', 'master', ...                               % plugin type
        'position', 0, ...                                  % plugin position
        'programname', 'visualize.ini' ...                  % program name, which sets inifile name here
        )
    error(['error calling ''vstload''' error_loc(dbstack)]);
end

% load aufio file
if 1 ~= soundmexpro('loadfile', ...                 % command name
        'filename', '../../waves/eurovision.wav', ...  % filename
        'loopcount', 0 ...                          % endless loop 
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end
% go
if 1 ~= soundmexpro('start')
    error(['error calling ''start''' error_loc(dbstack)]);
end

% wait a bit
pause(4);

% hide visualization
if 1 ~= soundmexpro('vstparam',  ...    % command name
        'parameter', 'visible', ...     % parameter name
        'value', 0 ...                  % parameter value
        )
    error(['error calling ''vstparam''' error_loc(dbstack)]);
end

pause(2);
clear soundmexpro;


