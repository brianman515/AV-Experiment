%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
% This example shows how to mark some buttons on a Matlab window
% synchronized with playback of a 'stimulus' in noise
%
% SoundMexPro commands introduced in this example:
%   setbutton

% declare 'main' as function, because GUI is implemented as function at the bottom
% of this file!

function t_04d_play_mark_buttons


% call tutorial-initialization script
t_00b_init_tutorial

% close all windows
close all

% initialize SoundMexPro with two output, no input (default), 4 virtual
% tracks
if 1 ~= soundmexpro('init', ...         % command name
        'driver', smpcfg.driver , ...       % driver index
        'output', smpcfg.output, ...   % list of output channels to use         
        'track', 4 ...                  % number of virtual tracks, here 4 (i.e. 2 tracks per channel)
        )
    error(['error calling ''init''' error_loc(dbstack)]);
end

% show device visualization
if 1 ~= soundmexpro('show')
    error(['error calling ''show''' error_loc(dbstack)]);
end

% create a window with three buttons defined in function mark_buttons_gui
% below
mark_buttons_gui;

% set channel volume (avoid clipping when adding waves)
if 1 ~= soundmexpro('volume', ...   % command name
        'value', 0.2 ...            % volume (factor to be applied). Her only one value, i.e. applied to all channels
        )
    error(['error calling ''volume''' error_loc(dbstack)]);
end

% load noise file to first two tracks
if 1 ~= soundmexpro(  'loadfile', ...               % command name
        'filename', '../waves/noise_16bit.wav', ... % name of wavefile
        'track', [0 1], ...                         % tracks were to load file, here 0 (channel 0) and 1 (channel 1)
        'loopcount', 0 ...                          % endloss loop (loopcount 0)
        );
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

% start playback
if 1 ~= soundmexpro('start')
    error(['error calling ''start''' error_loc(dbstack)]);
end

% wait a bit: let noise be played alone
pause(2);

% load second wave to next tracks in 'add' mode
if 1 ~= soundmexpro(  'loadfile', ...               % command name
        'filename', '../waves/3sine_16bit.wav', ... % name of wavefile
        'track', [2 3] ...                          % tracks were to load file, here 2 (channel 0) and 3 (channel 1)
        );
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

% now determine the 'offset' to set for the button marking positions by 
% calling 'loadposition' command (NOTE: 'playposition' returns the sample
% position of the currently audible buffer, but here we need the load 
% position, i.e. the position, where the stimulus was loaded to loadfile
% command above, see also help to commands 'playposition' and 'loadposition')
[success, offset] = soundmexpro('loadposition');
if 1 ~= success
    error(['error calling ''loadposition''' error_loc(dbstack)]);
end

% set button-highlight-positions: pass handle of the button and the
% highlighing positions to the function
if 1 ~= soundmexpro(  'setbutton', ...          % command name
        'handle', findobj('String','1'), ...    % handle of button with caption '1'
        'startpos', offset, ...                 % starting position
        'length', 44000 ...                     % length
        )
    error(['error calling ''setbutton''' error_loc(dbstack)]);
end

if 1 ~= soundmexpro(  'setbutton', ...          % command name
        'handle', findobj('String','2'), ...    % handle of button 2
        'startpos', offset + 44100, ...         % starting position
        'length', 44000 ...                     % length
        )
    error(['error calling ''setbutton''' error_loc(dbstack)]);
end

if 1 ~= soundmexpro(  'setbutton', ...          % command name
        'handle', findobj('String','3'), ...    % handle of button 3
        'startpos', offset + 88200, ...         % starting position
        'length', 44000 ...                     % length
        )
    error(['error calling ''setbutton''' error_loc(dbstack)]);
end

% wait a bit until playback of stimulus has started
pause(1);
% wait until playback of stimulus has ended
while  1
    [success, playing] = soundmexpro('playing');
    % check success of command
    if 1 ~= success
        soundmexpro('exit');
        error('Fatal error in loop. Aborting...');
    end
    % then check the last two tracks (NOTE: vector is 1-based!)
    if (max(playing(3:end)) == 0)
        break;
    end
    pause(0.3)
end

% close window
close;

clear soundmexpro;


% creating a test GUI window
function fig = mark_buttons_gui()

% edit this values to get the desired look
bw = 0.25;                % buttonWidth
fw = 0.6;                 % figureWidth
fh = 0.3;                 % figureHeigth

screen = get(0,'screensize'); % !! after adjusting screen resolution restart matlab to get the right screen size!
sp = screen(3)/screen(4); % screenProportion
bd = (1-3*bw)/4;          % buttonDistance
df = fw/fh*sp;             % distortion factor to provide exactly square buttons

h0 = figure('Color',[0.8 0.8 0.8], ...
    'MenuBar','none',...
    'Name','Mark buttons example', ...
    'PaperPosition',[18 180 576 432], ...
    'PaperUnits','points', ...
    'Units','normalized',...
    'Position',[(1-fw)/2 (1-fh)/2 fw fh], ...
    'Resize','off',...
    'Tag','Fig1', ...
    'ToolBar','none');

h1 = uicontrol('Parent',h0, ...
    'Units','points', ...
    'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
    'ListboxTop',0, ...
    'Units','normalized',...
    'Position',[bd (1-df*bw)/2 bw df*bw], ...
    'FontName','Arial',...
    'FontUnits', 'normalized',...
    'FontSize',0.1, ...
    'String','1', ...
    'Tag','Pushbutton1');
h2 = uicontrol('Parent',h0, ...
    'Units','points', ...
    'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
    'ListboxTop',0, ...
    'Units','normalized',...
    'Position',[2*bd+bw (1-df*bw)/2 bw df*bw], ...
    'FontName','Arial',...
    'FontUnits', 'normalized',...
    'FontSize',0.1, ...
    'String','2', ...
    'Tag','Pushbutton1');
h3 = uicontrol('Parent',h0, ...
    'Units','points', ...
    'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
    'ListboxTop',0, ...
    'Units','normalized',...
    'Position',[3*bd+2*bw (1-df*bw)/2 bw df*bw], ...
    'FontName','Arial',...
    'FontUnits', 'normalized',...
    'FontSize',0.1, ...
    'String','3', ...
    'Tag','Pushbutton1');
if nargout > 0, fig = h0; end
pause(0.2);
