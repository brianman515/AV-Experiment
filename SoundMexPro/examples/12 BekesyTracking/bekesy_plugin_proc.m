%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2010, written by Daniel Berg
%
%
% This script is used as plugin processing script in the example
% bekesy.m. It writes a sine of variable frequency to one output
% channel
function [proc_indata, proc_outdata, proc_inuserdata, proc_outuserdata] = ...
    sine_generator_plugin_proc(indata, outdata, inuserdata, outuserdata)

global cfg;

% NOTE: in this example the record data are empty. but return values must
% be set anyway!
proc_indata  = indata;
proc_inuserdata = inuserdata;
% copy back output user data 
proc_outuserdata = outuserdata;

% initialize persistant variables for phase and frequency and 'started-flag'
persistent phase;
if isempty(phase)
    phase = 0;
end
persistent freq;
if isempty(freq)
    freq = cfg.settings.startfreq;
end


% calculate current phase increment
phaseincrement = freq/cfg.settings.samplerate;
% set sweep speed from settings (e.g. five minutes from 125Hz to 8
% kHz). NOTE: we start the sweep not before main script bekesy.m has set 
% proc_outuserdata(1,2) to '1'
if proc_outuserdata(1,2) == 1
    freqincrement = (cfg.settings.stopfreq-cfg.settings.startfreq) / (cfg.settings.sweeptime*cfg.settings.samplerate/length(outdata));
else
    freqincrement = 0;
end

% Write sine to both channels (level and/or muting handled in main script)
% Here you may implement a pulsed sine as well
if (freq ~= -1)
    proc_outdata(:,1) = 0.99.*sin(([0:length(outdata)-1]'* phaseincrement + phase) .*2*pi);
    proc_outdata(:,2) = proc_outdata(:,1);
    freq = freq + freqincrement;
else
    proc_outdata = outdata; % if we're done simply copy data unchanged
end
% update phase
phase = phase + phaseincrement*length(proc_outdata);
% if stopfreq reached set frequency to -1 to signal "we are done"
if (freq > cfg.settings.stopfreq)
    freq = -1;
end
% write current frequency to userdata. It is read by main script bekesy.m
proc_outuserdata(1,1) = freq;
