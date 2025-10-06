%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
%
% This example usage of the command 'adm' for ASIO Direct Monitoring (ADM).
% NOTE: This example will only run properly if the soundcard/driver that is
% used supports ADM
%
% SoundMexPro commands introduced in this example:
%   adm

% call tutorial-initialization script
t_00b_init_tutorial


% initialize SoundMexPro with first ASIO driver, use two output, two input
% channels
if 1 ~= soundmexpro('init', ...         % command name
        'driver', smpcfg.driver , ...   % driver index
        'output', [0 1], ...            % list of output channels to use
        'input', [0 1] ...              % list of input channels to use
        )
    error(['error calling ''init''' error_loc(dbstack)]);
end

smp_disp('Mapping input channel 0 to output channel 0, pan "middle" (may be played on channels 0 and 1)');
% set input 0 to gain 0dB, pan in the middle and monitored by output
% channel 0
if 1 ~= soundmexpro('adm', ...          % command name
        'input', 0, ...                 % input channel to map
        'output', 0, ...                % utput channel use for monitoring input channel
        'gain', 536870912, ...          % gain (hex 0x20000000)
        'pan', 1073741823, ...          % pan (hex 0x7fffffff/2, i.e. middle position)
        'mode', 1 ...                   % switch mapping 'on', i.e. connect input 0 to output 2
        )
    error(['error calling ''iostatus''' error_loc(dbstack)]);
end

% if any input is connected now, you should 'see' that it is played as well
% on the visualization 
smp_disp('Hit a key to quit example');
userinteraction

clear soundmexpro;
