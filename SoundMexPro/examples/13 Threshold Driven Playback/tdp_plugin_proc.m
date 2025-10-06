%
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2016, written by Daniel Berg
%
%
% This script is used as plugin processing script in the example
% threshold_driven_playback.m. It checks for a threshold in recording data
% and copies audio data to the output after threshld is exceeded. This
% example contains a fake: if outuserdata are set then this script
% simulates an exceed threshold by writeing a 1 manually to the recording
% data
function [proc_indata, proc_outdata, proc_inuserdata, proc_outuserdata] = ...
            sine_generator_plugin_proc(indata, outdata, inuserdata, outuserdata)

% access global variables initialized in tdp_plugin_start.m       
global audiodata;
global datapos;        
global threshold;

% first: copy ALL data unchanged to return values
proc_indata         = indata;
proc_inuserdata     = inuserdata;
proc_outuserdata    = outuserdata;
proc_outdata        = outdata;

% in this fake we CLEAR all record data: to be removed if real record data
% are available !
proc_indata(:) = 0;

numsamples = length(proc_outdata);
% loop through channels 
for channel = 1:size(proc_outdata,2)
 
    % here we do a fake for this example: if first value in user data for 
    % this channel is set, then we manually write a one into first sample 
    % of the recording buffer (as if the threshold was reached!)
    if (proc_outuserdata(1, channel) ~= 0)
        proc_indata(1, channel) = 1;
        % reset value in returned userdata
        proc_outuserdata(1, channel) = 0;
    end

   pos = datapos(channel);
    % do we have to check for threshold in this channel at all (if datapos
    % of this channel is NOT 0, then we are currently playing the audiodata
    % on this channel and don't want to check for threshold, until playback
    % is complete (datapos will be 0 again)
    if pos == 0
       % check for exceeded threshold
       if (max(abs(proc_indata(:,channel))) > threshold(channel))
          % advance data pos to first sample!
          datapos(channel) = 1;
       end
    end
    % if NOW datapos is > 0, than we have to copy data to output
    if pos ~= 0
        % get number of samples available 
        num = length(audiodata(:,channel)) - pos;
        % if we have more samples left in signal than room in buffer,
        % copy part and advance datapos
        if (num > numsamples)
            num = numsamples;
            datapos(channel) = datapos(channel) + num;
        % otherwise reset datapos to 0: we are in 'look-for-threshold'-mode
        % again!
        else
            datapos(channel) = 0;
        end
        proc_outdata(1:num,channel) = audiodata(pos:pos+num-1,channel);   
    end
end

