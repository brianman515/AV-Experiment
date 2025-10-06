
% callback function attached to slider to set new SNR
function changing_snr_setsnr(varargin)
% search the slider...
slider = findobj('Tag','Slider1');
if slider == 0
    error('cannot find slider');
end
% ... and retrieve current value (i.e. new desired mix-volume)
% NOTE: here we can use mix valumes > 0 without clipping, because we have
% set master volume to -15 dB above!!!
vol = get(slider, 'Value');
% set volume of mixing sine (i.e. tracks 2 and 3) to new value
[success, volume] = soundmexpro('trackvolume', ...  % command name
    'track', [2 3], ...                             % tracks were to apply volume to
    'value', 10^((vol-10)/20) ...                        % volume value
    );
if success ~= 1
    error(['error calling ''trackvolume''' error_loc(dbstack)]);
end

 % show new SNR
 textfield = findobj('Tag','Text1');
 if textfield == 0
     error('cannot find text field');
 end
 set(textfield, 'String', ['SNR: ' num2str(20*log10(volume(3)), 3) ' dB ']);
