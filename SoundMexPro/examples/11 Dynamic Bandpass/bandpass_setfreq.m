% callback function attached to slider to set new frequency
function bandpass_setfreq(varargin)
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

