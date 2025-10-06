%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
%
% This example shows usage of a VST plugin with all corresponding commands
% in SoundMexPro. The used plugin is shipped with SoundMexPro. It is a 
% simple 'gain' plugin supporting up to 8 inputs and outputs.
%
% SoundMexPro commands introduced/used in this example:
%   vstquery
%   vstload
%   vstunload
%   vstprogram
%   vstprogramname
%   vstparam
%   vstset
%   vststore
%   vstedit


% call tutorial-initialization script
t_00b_init_tutorial

% initialise two channels 
if 1 ~= soundmexpro('init', ...         % command name
        'driver', smpcfg.driver,  ...       % driver index
        'output', smpcfg.output ...    % list of output channels to use         
        )
    error(['error calling ''init''' error_loc(dbstack)]);
end


% -------------------------------------------------------------------------
% 1. vstquery: query a plugin by filename
% NOTE: you can query a loaded plugin as well by input and position. This
% is not shown here.
filename = '..\plugins\HtVSTGain.dll';
[success, info, numin, numout, programs, program, params, values] =  ...
    soundmexpro('vstquery', ... % command name
    'filename', filename ...    % filename of plugin
    );
% check success
if (success ~= 1)
    error(['error calling ''vstquery''' error_loc(dbstack)]);
end
    
% plot retrieved info
smp_disp(['Info about plugin "' filename '":']);
smp_disp(['Plugin contains effect "' info{1} '" (' info{2} ') manufactured by "' info{3} '".']);
smp_disp(['It has ' num2str(numin) ' inputs and ' num2str(numout) ' outputs.']);
smp_disp(['Plugin has ' num2str(length(programs)) ' programs, current program is "' program{1} '".']);
smp_disp(['Plugin has ' num2str(length(params)) ' parameters. Names and values are:']);
for i = 1 : length(params)
    smp_disp(['   ' params{i} ': ' num2str(values(i))]);
end

% -------------------------------------------------------------------------
% 2. vstload and vstunload
% a. load it with command line arguments
% load plugin to outr two tracks by command line. NOTE: when loading with
% all arguments in command line, then the return values are not very
% interesting, since we have passed them. But they may be interesting when
% loading a plugin by configfile (see below)
if 1 ~= soundmexpro('vstload', ...                  % command name
        'filename', '..\plugins\HtVSTGain.dll', ... % filename of plugin
        'type', 'track', ...                        % plugin type ('master' is default)
        'input', [0 1], ...                         % inputs to use
        'output', [0 1], ...                        % outputs to use
        'position', 0 ...                           % vertical position (layer) where to load plugin to
        )
    error(['error calling ''vstload''' error_loc(dbstack)]);
end
% b. unload it again
if 1 ~= soundmexpro('vstunload', ...            % command name
        'type', 'track', ...                    % plugin type ('master' is default)
        'input', 0, ...                         % one of the inputs where plugin is loaded to 
        'position', 0 ...                       % vertical position (layer) where plugin is loaded to
        )
    error(['error calling ''vstunload''' error_loc(dbstack)]);
end

% c. load it by config file showing 'commandline supersedes config' as well
[success, type, in, out, position] = ...
    soundmexpro('vstload', ...              % command name
    'configfile', 'vst_config.ini', ...     % name of config file
    'position', 0 ...                       % vertical position (layer) where to load plugin to: NOTE in config position is 1!
    );
if 1 ~= success
    error(['error calling ''vstload''' error_loc(dbstack)]);
end

% verify correct position
if (position ~= 0)
    error('position is unexpectedly not 0 here...');
end

% -------------------------------------------------------------------------
% 3. vstprogram and vstprogramname
% NOTE the difference between 'vstprogram' and 'vstprogramname': 
%   the command 'vstprogram' selects one of the programs of the plugin (if the 
%   plugin itselft supports different programs at all)
%   the command 'vstprogramname' does not select a new program by name, it renames
%   the current program! The plugin itself has to support this renaming, otherwise 
%   the command will fail.
smp_disp(' ');
% - retrieve current program. NOTE: was set to 'log' by configfile above!
[success, program] = soundmexpro('vstprogram', ...  % command name
        'type', 'track', ...                        % plugin type ('master' is default)
        'input', 0, ...                             % one of the inputs where plugin is loaded to 
        'position', 0 ...                           % vertical position (layer) where plugin is loaded to
        );
if 1 ~= success
    error(['error calling ''vstprogram''' error_loc(dbstack)]);
end
smp_disp(['current program is "' program{1} '". Now switching...']);
% - set current program. 
[success, program] = soundmexpro('vstprogram', ...  % command name
        'program', 'lin', ...                       % program name
        'type', 'track', ...                        % plugin type ('master' is default)
        'input', 0, ...                             % one of the inputs where plugin is loaded to 
        'position', 0 ...                           % vertical position (layer) where plugin is loaded to
        );
if 1 ~= success
    error(['error calling ''vstprogram''' error_loc(dbstack)]);
end
smp_disp(['current program now is "' program{1} '".']);

% -------------------------------------------------------------------------
% 4. vstparam
smp_disp(' ');
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

% b. set and retrieve multiple parameters (here 'gain_0' and 'gain_2')
[success, params, values] = soundmexpro('vstparam', ... % command name
        'parameter', {'gain_0', 'gain_2'}, ...          % parameters to set
        'value', [0.2 0.5], ...                         % values to set
        'type', 'track', ...                            % plugin type ('master' is default)
        'input', 0, ...                                 % one of the inputs where plugin is loaded to 
        'position', 0 ...                               % vertical position (layer) where plugin is loaded to
        );
if 1 ~= success
    error(['error calling ''vstparam''' error_loc(dbstack)]);
end
smp_disp('New parameter values after switching are:');
for i = 1 : length(params)
    smp_disp(['   ' params{i} ': ' num2str(values(i))]);
end

% -------------------------------------------------------------------------
% 5. vststore
% store these values in an inifile
% - delete it in case it exists
if (exist('vst_config_test.ini')) 
    delete('vst_config_test.ini');
end
if 1 ~= soundmexpro('vststore', ...                 % command name
        'configfile', 'vst_config_test.ini', ...    % name of config file
        'type', 'track', ...                        % plugin type ('master' is default)
        'input', 0, ...                             % one of the inputs where plugin is loaded to 
        'position', 0 ...                           % vertical position (layer) where plugin is loaded to
        )
    error(['error calling ''vststore''' error_loc(dbstack)]);
end

% -------------------------------------------------------------------------
% 6. vstset
smp_disp(' ');
% load a second plugin, this time as master plugin at position 0 (both
% default)
if 1 ~= soundmexpro('vstload', ...              % command name
        'filename', '..\plugins\HtVSTGain.dll', ... % filename of plugin
        'input', [0 1], ...                     % inputs to use
        'output', [0 1] ...                     % outputs to use
        )
    error(['error calling ''vstload''' error_loc(dbstack)]);
end

% show current values of parameters
[success, params, values] = soundmexpro('vstparam', ... % command name
        'input', 0, ...                                 % one of the inputs where plugin is loaded to 
        'position', 0 ...                               % vertical position (layer) where plugin is loaded to
        );
if 1 ~= success
    error(['error calling ''vstparam''' error_loc(dbstack)]);
end
smp_disp('current parameter values for master plugin are:');
for i = 1 : length(params)
    smp_disp(['   ' params{i} ': ' num2str(values(i))]);
end

% now use config file created above in 'vststore' example to set values.
% To do this we must 'overload' the type ('track' was written to file, we
% want to set 'master' plugin!!)
if 1~=  soundmexpro('vstset', ...                   % command name
        'configfile', 'vst_config_test.ini', ...    % name of config file
        'type', 'master' ...                        % plugin type ('master' is default)
        )
    error(['error calling ''vstparam''' error_loc(dbstack)]);
end

% show current values of parameters
[success, params, values] = soundmexpro('vstparam', ... % command name
        'input', 0, ...                                 % one of the inputs where plugin is loaded to 
        'position', 0 ...                               % vertical position (layer) where plugin is loaded to
        );
if 1 ~= success
    error(['error calling ''vstparam''' error_loc(dbstack)]);
end
smp_disp('Parameter values after using "vstset" for master plugin are:');
for i = 1 : length(params)
    smp_disp(['   ' params{i} ': ' num2str(values(i))]);
end
% delete configfile again
if (exist('vst_config_test.ini'))
    delete('vst_config_test.ini');
end

% -------------------------------------------------------------------------
% 7. vstedit
% unload the track plugin again
if 1 ~= soundmexpro('vstunload', ...            % command name
        'type', 'track', ...                    % plugin type ('master' is default)
        'input', 0, ...                         % one of the inputs where plugin is loaded to 
        'position', 0 ...                       % vertical position (layer) where plugin is loaded to
        )
    error(['error calling ''vstunload''' error_loc(dbstack)]);
end

% play some audio data
if 1 ~= soundmexpro('loadfile', ...                 % command name
        'filename', '../waves/eurovision.wav', ...  % filename
        'loopcount', 0 ...                          % loopcount
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

smp_disp('Now the editor of the plugin is shown. You can change values by "moving"');
smp_disp('the blue value bars with the mouse. NOTE: only first two channels are used');
smp_disp('in this example! You can change the program with the menu to "log" to apply');
smp_disp('log gains (display will change accordingly). Hit a key to show the editor.'); 
userinteraction
% show VST-Editor
if 1 ~= soundmexpro('vstedit', ...  % command name
        'type', 'master', ...       % plugin type ('master' is default)
        'input', 0, ...             % one of the inputs where plugin is loaded to 
        'position', 0 ...           % vertical position (layer) where plugin is loaded to
        )
    error(['error calling ''vstedit''' error_loc(dbstack)]);
end



% show visualisation
if 1 ~= soundmexpro('show')
    error(['error calling ''show''' error_loc(dbstack)]);
end
% start playback
if 1 ~= soundmexpro('start')
    error(['error calling ''start''' error_loc(dbstack)]);
end
smp_disp('Hit a key to quit example');
userinteraction

clear soundmexpro
