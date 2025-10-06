%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
%
% This script is used as plugin processing script in the example
% t_07a_realtime_plugin.m shipped with SoundMexPro. It is called for every
% I/O-buffer of the soundcard with input data, output data and user data.
% Do not call this script directly.
% Matrices of the same dimensionm must be returned.

function [proc_indata, proc_outdata, proc_inuserdata, proc_outuserdata] = ...
            plugin_proc_error(indata, outdata, inuserdata, outuserdata)


% initialize a persistant variable that simply counts the calls to this
% script
persistent counter;
if isempty(counter)
    counter = 1;
else
    counter = counter + 1;
end

% NOTE: in this example we copy all data unchanged
proc_indata  = indata;
proc_inuserdata = inuserdata;
proc_outdata  = outdata;
proc_outuserdata = outuserdata;

% if more than 100 times called, return with and empty matrrix for
% proc_outdata
% an error!
if (counter > 100)
   proc_outdata = [];
end
