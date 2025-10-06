%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2008, written by Daniel Berg
%
%
% This script is used as plugin processing script in the example
% sine_genarator.m. It writes a sine of variable frequency to the first
% output channel
function [proc_indata, proc_outdata, proc_inuserdata, proc_outuserdata] = ...
            sine_generator_plugin_proc(indata, outdata, inuserdata, outuserdata)

% NOTE: in this example the record data are empty. We copy them unchanged
% anyway ...
proc_indata  = indata;
proc_inuserdata = inuserdata;
% copy back user data (we only want to read them
proc_outuserdata = outuserdata;

% initialize a persistant variable for the phase
persistent phase;
if isempty(phase)
    phase = 0;
end

% 'frequency' is stored in the first value of the channels user data.
% calculate phase incremement per sample
% IMPORTANT NOTE: here we have hard coded the sample frequency of 44100 Hz.
% This may be passed via user data as well! 
phaseincrement = outuserdata(1,1)/44100;

% Create the sine 
proc_outdata(:,1) = 0.5.*sin(([0:length(outdata)-1]'* phaseincrement + phase) .*2*pi);
% update phase
phase = phase + phaseincrement*length(proc_outdata);

% copy second channel unchanged
proc_outdata(:,2) = outdata(:,2);
