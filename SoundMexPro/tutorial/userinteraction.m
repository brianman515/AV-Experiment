%           Helper script for SoundMexPro tutorials.
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
% Calls input('') if global variable NoUserInterAction is _not_ assigned.
%  
%
global NoUserInterAction;

if isempty(NoUserInterAction) || NoUserInterAction == 0
    if exist('fflush') > 0
        fflush (stdout);
    end
    % multiple calls to pause without argument seem to be buggy in OCTAVE_HOME
    % thus we use 'input' instead
    input('');
else
    pause(0.1);
end
