

% callback function attached to 'Play 1' and 'Play 2' buttons (see
% pair_comparison_gui). Calls 'trackvolume' to switch volumes of the to
% alternatives
function pair_comparison_alternative(value)
% be kind: disable all other buttons as long as switching is done!
enable_gui('off');
% then set the volumes both alternatives
if 1~= soundmexpro('trackvolume', ...       % command name
        'track', [0 1 2 3], ...
        'value', [abs(value-1) abs(value-1) value value], ...
        'ramplen', 44100 ...                % ramp length 44100 -> 1 second
        )
    soundmexpro('exit');
    error(['error calling ''trackvolume''' error_loc(dbstack)]);
end
% enable buttons again
enable_gui('on');

% helper function to enable/disable the three buttons
function enable_gui(value)
h1 = findobj('String','Play 1');
h2 = findobj('String','Play 2');
h3 = findobj('String','Done');
set(h1, 'Enable', value);
set(h2, 'Enable', value);
set(h3, 'Enable', value);
% force painting of buttons
drawnow;


