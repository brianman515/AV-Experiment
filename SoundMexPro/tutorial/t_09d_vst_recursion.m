%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2011, written by Daniel Berg
%
%
% This example shows usage of a VST plugin with recurse wiring in SoundMexPro. 
% The gain plugin shipped with SoundMexPro is used for this example.
%
% SoundMexPro commands introduced/used in this example:
%   vstload with parameters 'recursechannel' and 'recursepos'


% call tutorial-initialization script
t_00b_init_tutorial


% This example for the configuration of a recursion in the VST plugin
% host is a very simple (dummy) example: it simply loads the gain plugin
% shipped with SoundMexPro using for channels of it. Two tracks playing a 
% each playing a sine signal will be mapped to the first two inputs
% (indices  0 and 1) of the plugin. The corresponding outputs of the plugin 
% are connected to the SoundMexPro connected to the output channels  0 and 1
% (standard). The 3rd and 4th plugin inputs (indices 2 and 3) are configured 
% for recursion (value -1 in 'input' vector in 'vstload'-command. With the
% parameters 'recursechannel' and 'recursepos' they are configured to use
% the first two outputs (!) of the plugin as input: imagine as if 'wires'
% connect the first two plugins outputs to the 3rd and 4th input of the
% same plugin:


%                   INPUTS
%
%           0      1      2      3   
%           |      |      
%           |      |      ----------------------       
%           |      |      |                    |
%           |      |      |      ----------    |
%           |      |      |      |        |    |
%         --------------------------      |    |
%        |                          |     |    |
%        |                          |     |    |
%        |                          |     |    |
%        |          PLUGIN          |     |    |
%        |                          |     |    |
%        |                          |     |    |
%        |                          |     |    |
%         --------------------------      |    |
%           |      |      |      |        |    |
%           |      |      |      |        |    |
%           |      |      2      3        |    |
%           |      |                      |    |
%           |      |-----------------------    |   
%           |      |      recursion 'wire'     |
%           |      1                           |      
%           |                                  |     
%           |-----------------------------------
%           |          recursion 'wire' 
%           0            
%
%                   OUTPUTS 
%
% With this wiring the outputs 0 and 1 are 'copied' to the inputs 2 and 3
% (with one buffer delay, soee SoundMexPro manual). The effect is
% demonstrated below by changinge the gains of the four plugin channels:
% changing the gain of channels 0 (or 1) 1 will affect the total output gains
% of output tracks 0 AND 2 (or 1 and 3) because the outputs (!) are copied,
% thus lowering the gain in plugin channel 0 will lower the input (i.e. the
% gain of the data copied to input 2) in plugin channel 2. Changing the
% gain in channel 2 (or 3) will only affect that channel itself.

% This example is some kind of 'artificial' to demonstrate recursive
% wiring. To make 'real' use of recursion you will need VST plugins that
% expect recursive inputs e.g. adaptive filter plugins.

% initialise four channels (may fail if your soundcard does not have four
% channels
if 1 ~= soundmexpro('init', ...     % command name
        'driver', smpcfg.driver,  ...   % driver index
        'output', [0 1 2 3] ...     % first four channels
        )
    error(['error calling ''init''' error_loc(dbstack)]);
end

% show visualisation
if 1 ~= soundmexpro('show')
    error(['error calling ''show''' error_loc(dbstack)]);
end

% load signal with two sine tones to first two tracks
if 1 ~= soundmexpro('loadfile', ...                 % command name
        'filename', '../waves/900l_450r.wav', ...   % filename
        'track', [0 1], ...                         % tracks
        'loopcount', 0 ...                          % endless loop 
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

% load the plugin
if 1 ~= soundmexpro('vstload', ...                  % command name
        'filename', '../plugins/HtVSTGain.dll', ... % plugin filename
        'type', 'track', ...                        % plug it into tracks
        'input', [0 1 -1 -1], ...                   % input configuration: first two channels use first two tracks, 3rd and fourth do recursion
        'recursechannel', [0 1], ...                % recursion: first recursion channel (i.e. first plugin input with '-1' in 'input' vector: 
        ...                                         % index 2) reads from channel 0, second from channel 1
        'recursepos', [0 0], ...                    % both recursion channels read AFTER plugin 0 (this plugin itself)
        'output', [0 1 2 3] ...                     % output configuration: 'straight' wiring of the four tracks
        )
end

% start 
if 1 ~= soundmexpro('start')
    error(['error calling ''start''' error_loc(dbstack)]);
end

% print info ...
disp('The VST editor is shown next: change the gains of the first four channels and');
disp('watch the effects in the output visualization (see comment in script above)');
disp('Press a key to quit example.');

% ... and show VST editor
if 1 ~= soundmexpro('vstedit', 'type', 'track')
    error(['error calling ''vstedit''' error_loc(dbstack)]);
end

userinteraction;
clear soundmexpro;
