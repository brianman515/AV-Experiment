%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
%
% This script is used as plugin processing script in the example
% t_07a_realtime_plugin.m shipped with SoundMexPro. Do NOT call it directly.
% It is called for every I/O-buffer of the soundcard with input data,
% output data and user data. Matrices of the same dimensionm must be returned.
%


function [proc_indata, proc_outdata, proc_inuserdata, proc_outuserdata] = ...
            plugin_proc(indata, outdata, inuserdata, outuserdata)

% NOTE: in this example the record data are empty. We copy them unchanged
% anyway
proc_indata  = indata;
proc_inuserdata = inuserdata;
proc_outuserdata = outuserdata;


% 'processing' is a simple scaling with the first values of the channels user data.
proc_outdata = [outuserdata(1,1).*outdata(:,1) outuserdata(1,2).*outdata(:,2)];


