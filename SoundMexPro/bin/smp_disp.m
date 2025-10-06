%
% Helper function to call 'drawnow' in MATLAB or fflush(stdout) in OCTAVE
% after calling 'disp'
%
% Copyright HoerTech gGmbH Oldenburg 2015, written by Daniel Berg
%
function smp_disp(X)

disp(X);

if exist('fflush') > 0
    fflush(stdout);
else
    drawnow;
end

