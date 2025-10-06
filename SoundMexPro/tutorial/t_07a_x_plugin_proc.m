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


% initialize a persistant variable that simply counts the calls to this
% script
persistent counter;
if isempty(counter)
    counter = 1;
else
    counter = counter + 1;
end
% show the counter value here somtimes
if mod(counter, 20) == 0
    counter
end

% 'processing' is a simple scaling with the first value of the channels user data.
proc_outdata = [outuserdata(1,1).*outdata(:,1) outuserdata(1,2).*outdata(:,2)];

% copy user data back ... 
proc_outuserdata = outuserdata;
% and write counter to second user data value of first channel
proc_outuserdata(2,1) = counter;

% special for simulating xruns due to too slow processing: if second user
% data value of the second channel is != 0, we do a pause here
if (outuserdata(2,2) ~= 0)
    pause(0.1);
end