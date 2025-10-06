%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
%
% This script is used as plugin processing script in the example
% t_07b_realtime_plugin_spec.m shipped with SoundMexPro. It is called for every
% I/O-buffer of the soundcard with input data, output data and user data.
% Matrices of the same dimensionm must be returned.

function [proc_indata, proc_outdata, proc_inuserdata, proc_outuserdata] = ...
            t_07b_x_plugin_proc(indata, outdata, inuserdata, outuserdata)

% NOTE: in this example the record data are empty. We copy them unchanged
% anyway
proc_indata  = indata;
proc_inuserdata = inuserdata;


% copy outuserdata to global userdata buffer defined in plugin_start_spec.m
global userdata;
userdata = outuserdata;

% here we call smp_stft shipped with SoundMexPro. Usually you don't have to
% change anything here or in smp_stft.m. See t_07b_x_plugin_start.m for hints how
% to implement your processing: there the name of your processing function /
% script is set, in this example it is t_07b_x_stft_userfcn.m
proc_outdata = smp_stft(outdata);

% copy iser data back (maybe your processing has written values to outdata
% that you want to read back to your MATLAB script)!
proc_outuserdata = userdata;
