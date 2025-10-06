%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
% This example shows how do a pair comparison for two audio files. The files
% contain the same sound, one of them bandpass filtered. On switching between
% the two alternatives a cross fade between the two files is done while
% playback continues.
%

% Declaring 'main' as function, because GUI is implemented as function at the bottom
% of this file!
function pair_comparison()


% call tutorial-initialization script
addpath('..\..\tutorial');
t_00b_init_tutorial


% initialize SoundMexPro with default driver and two playback channels 
% (output not specified, first two channels is default!)
if 1~= soundmexpro('init', ...          % command name
        'driver', smpcfg.driver , ...   % driver index
        'output', smpcfg.output, ...    % list of output channels to use            
        'track', 4 ...                  % number of virtual tracks, here 4 (i.e. 2 tracks per channel)
        )
    error(['error calling ''init''' error_loc(dbstack)]);
end
% ... show visualization
if 1~= soundmexpro('show')
    error(['error calling ''show''' error_loc(dbstack)]);
end

% load first wave with loadfile in endless loop to first two tracks
if 1~= soundmexpro('loadfile', ...                  % command name
        'filename', '../../waves/eurovision.wav', ...  % wavefile name
        'track', [0 1], ...                         % tracks were to play file
        'loopcount', 0 ...                          % endless loop
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

% then load second wave with mixfile in endless loop to next tracks
if 1~= soundmexpro('loadfile', ...                  % command name
        'filename', '../../waves/euro_tel.wav', ...    % wavefile name
        'track', [2 3], ...                         % tracks were to play file
        'loopcount', 0 ...                          % endless loop
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

% switch to first alternative now (funtion implemented below)
pair_comparison_alternative(0);

pair_comparison_gui;

% start playback
if 1~= soundmexpro('start')
    error(['error calling ''start''' error_loc(dbstack)]);
end


% here we wait until playback has ended
while  1
    [success, playing] = soundmexpro('playing');
    % check success of command
    if 1 ~= success
        soundmexpro('exit');
        error('Fatal error in loop. Aborting...');
    end
    % check if no (!) channel is playing any more
    if max(playing) == 0
        break;
    end
    
    % NOTE: never do while loops without some 'pause' to avoid heavy
    % processing load causing dropouts!
    pause(0.3);
end

close all;

% check which alternative had volume 'up' on 'done': this was the selected one
% when pressing "done"
[success, volume] = soundmexpro('trackvolume');
if 1 ~= success
    error(['error calling ''trackvolume''' error_loc(dbstack)]);    
end

if volume(1) == 1
    smp_disp('alternative 1 was playing when pressing "done"');
else
    smp_disp('alternative 2 was playing when pressing "done"');
end

clear soundmexpro;
close all;



% -------------------------------------------------------------------------
% End of example, GUI definition below
% button callback implemented in pair_comparison_alternative
% -------------------------------------------------------------------------


% creating a test GUI window
function fig = pair_comparison_gui()

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
    'Name','Press "Play 1" and "Play2" to switch, "Done" to quit', ...
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
    'String','Play 1', ...
    'callback', 'pair_comparison_alternative(0);', ...    
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
    'String','Play 2', ...
    'callback', 'pair_comparison_alternative(1);', ...    
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
    'String','Done', ...
    'callback', 'soundmexpro(''stop'');', ...
    'Tag','Pushbutton1');
if nargout > 0, fig = h0; end

