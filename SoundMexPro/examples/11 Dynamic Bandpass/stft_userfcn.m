%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2008, written by Daniel Berg
%
%
% This script is used as processing script in the frequency domain in the 
% example bandpass.m shipped with SoundMexPro. It is
% called every time a new short time spectrum is available. The spectrum
% can be manipulated in a global data buffer (this is done rather than a
% funtion call to avoid copying data in the real time environment here!)
%
function stft_userfcn

% we need access to the global data: stft_data.fftbuf contains the current
% short time spectrum! Process the data in place if possible and avoid
% making copies of it!
global userdata;
global stft_data;

% access global buffers for magnitude and phase
global stft_mag stft_phase;


% read userdata:
%   - first value contains first bin to process
%   - second value contains last bin to process
% NOTE: no consistency check done here!!



% extract magnitude and phase
% NOTE: here we use the buffers stft_mag and stft_phase that were
% already initialized in t_07b_x_plugin_start, see commenst there
stft_mag   = abs(stft_data.fftbuf);
stft_phase = angle(stft_data.fftbuf);


stft_mag(1:userdata(1,1)-1,:) = 0;    
stft_mag(userdata(2,1):end,:) = 0;    


% put magnitude and phase back together and convert to complex
stft_data.fftbuf=stft_mag.*exp(1i.*stft_phase);
