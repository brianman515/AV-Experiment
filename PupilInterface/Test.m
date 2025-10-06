% Initialize

SaveDir = 'YourDataSavePath;
app.Pupil = PupilInterface.getInstance;
[network, port] = loadOptionEyeTracker([], getModel(app.Pupil));
setModel('TobiiSpectrum',app.Pupil);
setNetwork('', app.Pupil);
setPort([], app.Pupil);
setSavepath(SaveDir, app.Pupil);
connect(app.Pupil)

% Start recording
temp_str = ['YourFileName' '.csv'];
set_savefilename(app.Pupil,temp_str);

send_msg('record',app.Pupil); % This message starts the recording

% Send markers
send_msg('YourMarkerMessage',app.Pupil);

% Stop recording
send_msg('stop', app.Pupil) % This message stops the recording and saves the data