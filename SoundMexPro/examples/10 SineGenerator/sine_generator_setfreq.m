
% callback function attached to slider to set new frequency
function sine_generator_setfreq(varargin)

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
% write new value to userdata ...
userdata(1,1) = freq;
% and set them!
if 1 ~= soundmexpro('pluginsetdata', ...    % command name
        'data', userdata, ...           % matrix with user data to se
        'mode', 'output' ...            % set output user data (this is default)
        )
    error(['error calling ''pluginsetdata''' error_loc(dbstack)]);
end

% show new frequency
textfield = findobj('Tag','Text1');
if textfield == 0
    error('cannot find text field');
end
set(textfield, 'String', ['Frequency: ' num2str(freq) ' Hz ']);
end

