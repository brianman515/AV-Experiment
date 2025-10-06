%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
%
% This script is used as processing script in the frequency domain in the
% example t_07b_realtime_plugin_spec.m shipped with SoundMexPro. It is
% called every time a new complex short time spectrum is available. The
% spectrum can be manipulated in a global data buffer (this is done rather
% than a function call to avoid copying data in the real time environment
% here!). Do not call this function directly
%
function t_07b_x_stft_userfcn

% we need access to the global data: stft_data.fftbuf contains the current
% short time spectrum! Process the data in place if possible and avoid
% making copies of it!
global stft_data;
% access global buffers for magnitude and phase
global stft_mag stft_phase;


% add a persistent counter to count the number of calls to this function
persistent counter;
if isempty(counter)
    counter = 0;
end



% read global userdata
global userdata;

% only do the processing, if first value is 1 (set with command
% soundmexpro('pluginsetdata'....) in t_07b_realtime_plugin_spec.m to
% show an example how to control the filter on runtime! You may put more
% data into userdata such as cut off frequency ...
if userdata(1,1) == 1
    % NOTE: stft_data.fftbuf currently holds the COMPLETE complex spectrum of all
    % channels. So you may manipulate it in any way you like!

    % In this simple example amplify the spectrum and apply alow pass

    % extract magnitude and phase
    % NOTE: here we use the buffers stft_mag and stft_phase that were
    % already initialized in t_07b_x_plugin_start, see commenst there
    stft_mag   = abs(stft_data.fftbuf);
    stft_phase = angle(stft_data.fftbuf);

    % multiply complete magnitude
    stft_mag = stft_mag .* 2;

    % do a simple low pass by setting all magnitudes starting with bin
    % 10 to zero
    stft_mag(10:end,:) = 0;

    % put magnitude and phase back together and convert to complex
    stft_data.fftbuf=stft_mag.*exp(1i.*stft_phase);
end

% plot for every 50th frame, if the filter is currently active
% NOTE: in octave plotting in a plugin blocks everything, thus it must
% NEVER be done
if mod(counter, 50) == 0
    if userdata(1,1) == 1
        disp('filter is active');
    else
        disp('filter is inactive');
    end
    drawnow;
end





% increment function counter
counter = counter + 1;