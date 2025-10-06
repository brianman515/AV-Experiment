%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
% This example shows how play a noise and a sine in mixing mode and adjust
% the SNR online using a slider
%
%
% Declaring 'main' as function, because GUI is implemented as function at the bottom
% of this file!
function changing_snr()

% call tutorial-initialization script
addpath('..\..\tutorial');
t_00b_init_tutorial


% initialize SoundMexPro with default driver and two playback channels
% (output not specified, first two channels is default!)
if 1~= soundmexpro('init', ...      % command name
        'driver', smpcfg.driver , ...   % driver index
        'output', smpcfg.output, ...   % list of output channels to use            
        'track', 4 ...              % number of virtual tracks, here 4 (i.e. 2 tracks per channel)
        )
    error(['error calling ''init''' error_loc(dbstack)]);
end
% ... show visualization
if 1~= soundmexpro('show')
    error(['error calling ''show''' error_loc(dbstack)]);
end

% load noise with loadfile in endless loop to first two tracks
if 1~= soundmexpro('loadfile', ...                  % command name
        'filename', '../../waves/noise_16bit.wav', ... % wavefile name
        'track', [0 1], ...                         % tracks were to play file
        'loopcount', 0 ...                          % endless loop
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

% load signal 'mixing' file in endless loop to next tracks
if 1~= soundmexpro('loadfile', ...              % command name
        'filename', '../../waves/sine.wav', ...    % wavefile name
        'track', [2 3], ...                     % tracks were to play file
        'loopcount', 0 ...                      % endless loop
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

% set volumes to -10 dB to have headroom for raising trackvolumes below
if 1~= soundmexpro('volume', ...    % command name
        'value', 10^(-10/20) ...    % value
        )
    error(['error calling ''trackvolume''' error_loc(dbstack)]);
end

% set noise tracks to - 10dB
if 1~= soundmexpro('trackvolume', ...    % command name
        'track', [0 1], ...              % tracks to set
        'value', 10^(-10/20) ...         % value
        )
    error(['error calling ''trackvolume''' error_loc(dbstack)]);
end


% show the gui defined below
changing_snr_gui;

% start playback
if 1~= soundmexpro('start')
    error(['error calling ''start''' error_loc(dbstack)]);
end

changing_snr_setsnr;

started = 1;
while started
    pause(0.1);
    % check if device is still running ('Stop' button stops output)
    [success, started] = soundmexpro('started');
    if success ~= 1
        clear soundmexpro;
        close all;
        error(['error calling ''started''' error_loc(dbstack)]);
    end
end

% done
close all;
clear soundmexpro;
    

% -------------------------------------------------------------------------
% End of example, GUI definition below
% button callback implemented in changing_snr_setsnr.m
% -------------------------------------------------------------------------



% creating a test GUI window
function fig = changing_snr_gui()

% edit this values to get the desired look
fw = 0.4;                 % figureWidth
fh = 0.15;                 % figureHeigth


h0 = figure('MenuBar','none',...
    'Name','Changing SNR', ...
    'PaperPosition',[18 180 576 432], ...
    'PaperUnits','points', ...
    'Units','normalized',...
    'Position',[(1-fw)/2 (1-fh)/2 fw fh], ...
    'Resize','off',...
    'Tag','Fig1', ...
    'ToolBar','none');
h1 = uicontrol('Parent',h0, ...
    'Style', 'text', ...
    'Units','normalized', ...
    'Position',[0.1 0.70 0.8 0.2], ...
    'FontName','Arial',...
    'FontUnits', 'normalized',...
    'FontSize',0.8, ...
    'String','Hallo', ...
    'Tag','Text1');
h2 = uicontrol('Parent',h0, ...
    'Style', 'slider', ...
    'Min', -10, ...
    'Max', 10, ...
    'Value', 0, ...
    'SliderStep',[1/20 1/10], ...
    'Units','normalized', ...
    'ListboxTop',0, ...
    'Position',[0.1 0.40 0.8 0.2], ...
    'FontName','Arial',...
    'FontUnits', 'normalized',...
    'FontSize',0.4, ...
    'String','', ...
    'callback', 'changing_snr_setsnr', ...    
    'Tag','Slider1');
h3 = uicontrol('Parent',h0, ...
    'Units','normalized', ...
    'ListboxTop',0, ...
    'Position',[0.1 0.1 0.8 0.2], ...
    'FontName','Arial',...
    'FontUnits', 'normalized',...
    'FontSize',0.4, ...
    'String','Stop', ...
    'callback', 'soundmexpro(''stop'');', ...    
    'Tag','Pushbutton1');
if nargout > 0, fig = h0; end
