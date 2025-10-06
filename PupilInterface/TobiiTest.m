close all
clear all
clc
restoredefaultpath

Fs = 44100;
TrigLength = 0.1;

% 
% try
%     pyversion('C:\Python27\python.exe')
% catch
%     warning('Python already running') 
% end

Basepath = cd;
addpath([Basepath '\Tools'])
SaveDir = ['Your path to safe a file'];
cd(Basepath)
S = repmat([ones(round(TrigLength*Fs),1); zeros(round((1-TrigLength)*Fs),1)],5,1);

pupil = PupilInterface.getInstance;

temp_str = datestr(datetime);
temp_str = replace(temp_str,':','_');
temp_str = ['TobiiTest_' temp_str '.csv'];
set_savefilename(pupil,temp_str);

setModel('TobiiSpectrum',pupil);
[network, port] = loadOptionEyeTracker([], getModel(pupil));
setNetwork('', pupil);
setPort([], pupil);
setSavepath(SaveDir, pupil);

connect(pupil)
pause(2)
send_msg('record',pupil)
pause(2)
send_msg('Start_Baseline',pupil)
pause(5)
send_msg('Start_Sound',pupil)
sound(S,Fs)
pause(5)
send_msg('Stop_Sound',pupil)
pause(2)
send_msg('stop', pupil)
pause(2)
disconnect(pupil)

clear pupil



