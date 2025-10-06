%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2008, written by Daniel Berg
%
%
% This script is used as plugin processing script in the example
% bandpass.m shipped with SoundMexPro. It is called for every
% I/O-buffer of the soundcard with input data, output data and user data.
% Matrices of the same dimensionm must be returned.

function [proc_indata, proc_outdata, proc_inuserdata, proc_outuserdata] = ...
            plugin_proc_spec(indata, outdata, inuserdata, outuserdata)

% NOTE: in this example the record data are empty. We copy them unchanged
% anyway
proc_indata  = indata;
proc_inuserdata = inuserdata;
% we don't use outuserdata here, so copy them back unchanged
proc_outuserdata = outuserdata;

global userdata;
userdata = outuserdata;


% here we call stft shipped with SoundMexPro. Usually you don't have to
% change anything here or in smp_stft.m. See plugin_start_spec.m for hints how
% to implement your processing

% build output data from procssed first and unchanged second channel
proc_outdata = [smp_stft(outdata(:,1))  outdata(:,2)];

proc_outuserdata = userdata;

