%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
%
% This example shows how to process audio data buffer by buffer with a 
% spectral MATLAB script (plugin) in realtime.
% Here the fisrt channel is filtered with a bandpass, the second channel is
% not processed. A slider is shown, where the center frequency of the
% bandpass can be adjusted
% The filter is created and sent to the plugin in function setfreq, which
% is attached to the slider. There lower and the upper bin of the bandpass
% are calculated and sent to the plugin using the command 'pluginsetdata'.
% The plugin then reads these values and applies the filter (see
% stft_userfcn.m)
%

function bandpass()

% call tutorial-initialization script
addpath('..\..\tutorial');
t_00b_init_tutorial


global plugin;
% create plugin configuration read by plugin_start_spec.m
plugin.fftlen       = 2048;
plugin.windowlen    = 1600;
plugin.samplerate   = 44100;
save plugin.mat plugin


% initialize SoundMexPro with first ASIO driver, use two output, no input
% channels (default).
% NOTE: for further explanations on this example see the scripts
% plugin_start_spec.m and plugin_proc_spec.m!!
if 1 ~= soundmexpro('init', ...                 % command name
        'driver', smpcfg.driver , ...           % driver index
        'output', smpcfg.output, ...            % list of output channels to use 
        'samplerate', plugin.samplerate, ...    % samplerate
        'pluginstart', 'plugin_start_spec', ... % name of MATLAB command to call on startup. NOTE: must be in the MATLAB seacrh path!!
        'pluginproc', 'plugin_proc_spec', ...   % name of MATLAB command to call for every buffer. NOTE: must be in the MATLAB seacrh path!!
        'pluginshow', 0, ...                    % flag if to show processing MATLAB engine (debugging only!)
        'pluginkill', 1 ...                     % flag if to kill processing MATLAB engine on 'exit'
        )
    error(['error calling ''init''' error_loc(dbstack)]);
end

% load a noise file
if 1 ~= soundmexpro(  'loadfile', ...               % command name
        'filename', '..\..\waves\noise_16bit.wav', ...  % name of wavefile
        'loopcount', 0 ...                          % endess loop
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

% set volume on second channel lower (will not be processed in example)
if 1 ~= soundmexpro(  'trackvolume', ...               % command name
        'track', 1, ...
        'value', 0.1 ...                          % endess loop
        )
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end


% show the gui defined below
sine_genarator_gui;
% set initial value
bandpass_setfreq;


% start playback. 
if 1 ~= soundmexpro('start')
    error(['error calling ''start''' error_loc(dbstack)]);
end

pause(0.5)
started = 1;
while started
    pause(0.1);
    % check if device is still running ('Stop') button stops output)
    [success, started] = soundmexpro('started');
    if success ~= 1
        clear soundmexpro;
        close all;
        error(['error calling ''started''' error_loc(dbstack)]);
    end
end

clear soundmexpro;
close all;

% -------------------------------------------------------------------------
% End of example, GUI definition below
% callback for setting frequency implemented in bandpass_setfreq.m
% -------------------------------------------------------------------------


% callback function attached to slider to set new frequency
function setfreq(varargin)
global plugin;
% search the slider...
slider = findobj('Tag','Slider1');
if slider == 0
    error('cannot find slider');
end
% ... and retrieve current value (i.e. new desired frequency)
freq = get(slider, 'Value');

% retrieve the user data directly once (then we have a matrix with correct
% dimensions for setting them again!)
[success, userdata] = soundmexpro('plugingetdata', ... % command name
    'mode', 'output' ...  % retrieve output user data (this is default)
    );
if success ~= 1
    error(['error calling ''plugingetdata''' error_loc(dbstack)]);
end


% -----------------  FILTER CREATION --------------------------------------
% calculate the 'dumb' filter: linear factors for the bins that
% should be NOT 0 (all others are set to 0 in stft_userfcn
binsize = plugin.samplerate / plugin.fftlen;

% calculate first bin and last bin
lowerbin = round((freq-200)/binsize);
if (lowerbin < 1)
    lowerbin = 1;
end
upperbin = round((freq+200)/binsize);
if (upperbin > plugin.fftlen)
    upperbin = plugin.fftlen;
end

% write new value to userdata: first and second value
% are the bin numbers /first and last!
userdata(1,1) = lowerbin;
userdata(2,1) = upperbin;
% next values are the factors, here: ones
userdata(3:(upperbin-lowerbin)+3) = 1;

% and set them!
if 1 ~= soundmexpro('pluginsetdata', ...    % command name
        'data', userdata, ...           % matrix with user data to se
        'mode', 'output' ...            % set output user data (this is default)
        )
    error(['error calling ''pluginsetdata''' error_loc(dbstack)]);
end

% -----------------  FILTER CREATION END ----------------------------------


% show new frequency
textfield = findobj('Tag','Text1');
if textfield == 0
    error('cannot find text field');
end
set(textfield, 'String', ['Frequency: ' num2str(freq) ' Hz ']);

% function creating a test GUI window
function fig = sine_genarator_gui()

% edit this values to get the desired look
fw = 0.4;                 % figureWidth
fh = 0.15;                 % figureHeigth


h0 = figure('MenuBar','none',...
    'Name','Changing bandpass center frequency', ...
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
    'String','', ...
    'Tag','Text1');
h2 = uicontrol('Parent',h0, ...
    'Style', 'slider', ...
    'Min', 400, ...
    'Max', 4000, ...
    'Value', 1000, ...
    'SliderStep',[1/20 1/10], ...
    'Units','normalized', ...
    'ListboxTop',0, ...
    'Position',[0.1 0.40 0.8 0.2], ...
    'FontName','Arial',...
    'FontUnits', 'normalized',...
    'FontSize',0.4, ...
    'String','', ...
    'callback', 'bandpass_setfreq', ...    
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
