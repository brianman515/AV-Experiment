classdef PupilInterface < ComInterface
    %     Object class to control pupillometry, is compatible with SMI500,
    %     SMIXX and PupilLabs glasses. Other glasses can be implemented in
    %     this class.
    %     The object created is a singleton stored in a persistent
    %     variable. to create the object you call 'name' = PupilInterface.getInstance
    %     to delete such object you have to use the command delete('name').
    
    properties(Access = private)
        socket      = [];
        context     = [];
        address     = [];
        subport     = [];
        libraryname = '';
        includename = '';
        dllname     = '';
        pointer     = [];
        subaddress  = '';
        subsocket   = [];
        connected   = 0;
        savepath    = '';
        savefile    = 'Data.csv';
        pupil       = [];
        data        = []; % data = struct;
        nsamples    = 0;
        annotations = [];
        LSL_inlet   = []; % LSL inlet for TobiiGlasses
    end
    
    properties(SetAccess = protected, GetAccess = protected)
        network     = ''
        port        = [];
        model       = '';
    end
    
    methods (Access = private)
        % Constructor
        function obj = PupilInterface
        end
    end
    
    methods (Static)
        % Ensure singleton design model
        function singleObj = getInstance
            % Get the instance if it exists otherwise it creates it.
            persistent localObj
            if isempty(localObj) || ~isvalid(localObj)
                localObj = PupilInterface;
            end
            singleObj = localObj;
        end
    end
    
    methods
        % Get/Set functions
        function socket = getSocket(obj)
            socket = obj.socket;
        end
        function context = getContext(obj)
            context = obj.context;
        end
        function address = getAddress(obj)
            address = obj.address;
        end
        function subport = getSubport(obj)
            subport = obj.subport;
        end
        function model = getModel(obj)
            model = obj.model;
        end
        function port = getPort(obj)
            port = obj.port;
        end
        function network = getNetwork(obj)
            network = obj.network;
        end
        function subsocket = getSubsocket(obj)
            subsocket = obj.subsocket;
        end
        function subaddress = getSubaddress(obj)
            subaddress = obj.subaddress;
        end
        function save = getSavepath(obj)
            save = [obj.savepath];
        end
        function setModel(value, obj)
            checkModel(value);
            obj.model = value;
            if ismember(obj.model,{'SMI500', 'SMIXX'})
                setPort([4444; 5555],obj) % Never mentioned in the SI_Test program, needs to be loaded by oTest
            elseif ismember(obj.model, {'Interacoustics', 'TobiiSpectrum', 'TobiiGlasses'})
                defaultSavepath(obj);
            end
        end
        function setNetwork(value,obj)
            checkNetwork(value,obj.model);
            obj.network = value;
        end
        function setPort(value,obj)
            checkPort(value);
            obj.port = value;
        end
        function setSavepath(value,obj)
            obj.savepath = value;
            if ismember(obj.model, {'Interacoustics', 'TobiiSpectrum', 'TobiiGlasses'})
                defaultSavepath(obj);
            end
        end
        function setSavefile(value,obj)
            obj.savefile = value;
        end
        function defaultSavepath(obj)
            c = fileparts(which('PupilInterface'));
            p = regexp(c,filesep,'split');
            for i = 1:length(p)
                if strcmp(p{i},'tool')
                    pa = p{1};
                    for j = 2:(i-1)
                        pa = [pa filesep p{j}];
                    end
                    % Make sure that this function can get the participant
                    % name in the folder name
                    pa = [pa filesep 'recordings_' obj.model];
                    obj.savepath = pa;
                    break
                end
            end
        end
        
        % Functional methods
        function connect(obj)
            
            % Connect to hardware.
            if ~obj.isConnected % don't try to connect twice and init only once
                if strcmp(obj.model,'PupilLabs')
                    obj.context = zmq.core.ctx_new();
                    obj.socket = zmq.core.socket(obj.context, 'ZMQ_REQ');
                    
                    % Subscribe to notification from pupillabs notification center
                    % address = sprintf('tcp://192.168.1.2:%d', port);
                    obj.address = sprintf([obj.network,':%d'], obj.port);
                    zmq.core.setsockopt(obj.socket, 'ZMQ_LINGER', 0);
                    zmq.core.connect(obj.socket, obj.address);
                    
                    zmq.core.send(obj.socket,uint8('SUB_PORT'));
                    pause(1e-2)
                    obj.subport = char(zmq.core.recv(obj.socket, 'ZMQ_DONTWAIT'));
                    if strcmp(char(-1), obj.subport)
                        disp('Device not connected, launch PupilCapture')
                        zmq.core.close(obj.socket);
                        zmq.core.ctx_term(obj.context);
                    else
                        disp('Connection with device done, initializing...')
                        obj.connected = 1;
                    end
                elseif ismember(obj.model,{'SMI500', 'SMIXX'})
                    warning('off', 'all');
                    
                    % HARDCODED ABSOLUT PATH
                    addpath C:\Program' Files (x86)'\SMI\iView' X SDK'\bin\
                    addpath C:\Program' Files (x86)'\SMI\iView' X SDK'\include\
                    
                    if computer('arch') == 'win32'
                        obj.includename = 'iViewXAPI.h';
                        obj.dllname = 'iViewXAPI.dll';
                        obj.libraryname = 'iViewXAPI';
                    else
                        obj.includename = 'iViewXAPI.h';
                        obj.dllname = 'iViewXAPI64.dll';
                        obj.libraryname = 'iViewXAPI64';
                    end
                    
                    try
                        loadlibrary(obj.dllname, obj.includename);
                    
                        [obj.pointer.pSystemInfoData, obj.pointer.pSampleData,...
                            obj.pointer.pEventData, obj.pointer.pAccuracyData,...
                            CalibrationData] = InitiViewXAPI();

                        % see the User Manual for detailed information due to setting up calibration
                        CalibrationData.method = int32(5);
                        CalibrationData.visualization = int32(1);
                        CalibrationData.displayDevice = int32(0);
                        CalibrationData.speed = int32(0);
                        CalibrationData.autoAccept = int32(1);
                        CalibrationData.foregroundBrightness = int32(250);
                        CalibrationData.backgroundBrightness = int32(230);
                        CalibrationData.targetShape = int32(2);
                        CalibrationData.targetSize = int32(20);
                        CalibrationData.targetFilename = int8('');
                        obj.pointer.pCalibrationData = libpointer('CalibrationStruct', CalibrationData);

                        disp('Define Logger')
                        calllib(obj.libraryname, 'iV_SetLogger', int32(1), 'iViewXSDK_Matlab_GazeContingent_Demo.txt')

                        disp('Connect to iViewX (eyetracking-server)')
                        ret = calllib(obj.libraryname, 'iV_Connect', obj.network{1}, int32(obj.port(1)),...
                            obj.network{2}, int32(obj.port(2)));


                        switch ret
                            case 1
                                obj.connected = 1;
                            case 104
                                msgbox('Could not establish connection. Check if Eye Tracker is running', 'Connection Error', 'modal');
                            case 105
                                msgbox('Could not establish connection. Check the communication Ports', 'Connection Error', 'modal');
                            case 123
                                msgbox('Could not establish connection. Another Process is blocking the communication Ports', 'Connection Error', 'modal');
                            case 200
                                msgbox('Could not establish connection. Check if Eye Tracker is installed and running', 'Connection Error', 'modal');
                            otherwise
                                msgbox('Could not establish connection', 'Connection Error', 'modal');
                        end
                    catch
                    end
                    warning('on', 'all');
                elseif strcmp(obj.model, 'Interacoustics')
                    file = 'PupillometryInterface.dll';
                    path = fileparts([which(file), filesep, file]);
                    NET.addAssembly(path);
                    
                    obj.pupil = PupillometryInterface.Pupillometry();
%                     obj.pupil.ShowVideo();
                    obj.connected = 1;
                elseif strcmp(obj.model, 'TobiiSpectrum')
                    
                    try
                        obj.pupil = py.TobiiSpectrumRecorder.TobiiSpectrum();
                    catch
                        
                        % Make sure system has correct version of Python
                        % and Tobii Spectrum SDK; install if necessary
                        [v, e, ~] = pyversion;
                        v = str2double(v);
                        if isnan(v) || v < 2.7 || (v >= 2.8 && v > 3.5) || v >= 3.6 % must be 2.7 or 3.5
                            error(sprintf('\nThis script requires Python 2.7 or 3.5.\nMake sure one of these Python versions is installed and is the current interpreter for MATLAB.\n\t(1) Close and reopen Matlab:\n\t(2) Before doing anything else, specify the Python interpreter to use by typing e.g. "pyversion 2.7" or "pyversion C:\\ProgramData\\Anaconda2\\python.exe" depending on your Python distribution.\n\t(3) Run HINT again.\nSuggestion: use a distribution like Anaconda to ensure the proper packages are installed:\n\thttps://www.anaconda.com/distribution/#download-section'));
                        end
                        try
                            SDKdir = fullfile('C:\Psychopy\PupilInterface\Tobii Spectrum SDK');
                            pypath = fullfile(fileparts(e),filesep,'Lib');
                            
                            % Custom-built recorder class for Tobii Spectrum
                            file = fullfile(pypath, filesep, 'TobiiSpectrumRecorder.py');
                            if exist(file, 'file') ~= 2, copyfile(fullfile(SDKdir, filesep, 'TobiiSpectrumRecorder.py'), pypath); end
                            file = fullfile(pypath, filesep, 'TobiiSpectrumRecorder.pyc');
                            if exist(file, 'file') ~= 2, copyfile(fullfile(SDKdir, filesep, 'TobiiSpectrumRecorder.pyc'), pypath); end
                            
                            pypath = fullfile(pypath, filesep, 'site-packages');
                            
                            % Tobii Spectrum Python SDK
                            file = fullfile(pypath, filesep, 'tobii_research.py');
                            if exist(file, 'file') ~= 2, copyfile(fullfile(SDKdir, filesep, 'tobii_research.py'), pypath); end
                            file = fullfile(pypath, filesep, 'tobii_research.pyc');
                            if exist(file, 'file') ~= 2, copyfile(fullfile(SDKdir, filesep, 'tobii_research.pyc'), pypath); end
                            file = fullfile(pypath, filesep, 'tobiiresearch');
                            if exist(file, 'file') ~= 7, copyfile(fullfile(SDKdir, filesep, 'tobiiresearch'), file); end
                        catch
                            error('Missing Tobii Spectrum Python SDK files, or cannot locate the proper Python path.');
                        end
                    end
                    
                    try
                        obj.pupil = py.TobiiSpectrumRecorder.TobiiSpectrum();
                        obj.connected = obj.pupil.init_eyetracker(); % returns 1 if successful, 0 if not
                    catch
                        error(sprintf('\nTobii Spectrum Recorder Python binding requires Pandas and NumPy Python packages.\nSuggestion: use a distribution like Anaconda to ensure all necessary packages are installed:\n\thttps://www.anaconda.com/distribution/#download-section\nTo make sure Matlab is using the correct Python interpreter:\n\t(1) Close and reopen Matlab.\n\t(2) Before doing anything else, specify the Python interpreter to use by typing e.g. "pyversion 2.7" or "pyversion C:\\ProgramData\\Anaconda2\\python.exe" depending on your Python distribution.\n\t(3) Run HINT again.'))
                    end
                    
                elseif strcmp(obj.model, 'TobiiGlasses')
                    
                    % Run Python LSL in background
                    pyScript = 'py -2.7 tool\TobiiGlassesAPI\TobiiProGlasses2toLSL\main.py &';
                    [status, err] = system(pyScript);
                    if status ~= 0, error('\nCould not connect to Python LSL:\n\t%s', err); end
                    
                    % Load LSL library
                    lib = lsl_loadlib();
                    
                    % Resolve gaze stream
                    result = {};
                    while isempty(result)
                        result=lsl_resolve_byprop(lib,'type','Tobii-EyeTracker-All');
                    end
                    
                    % Open gaze inlet stream
                    obj.LSL_inlet = lsl_inlet(result{1});
                    
                    % Effectively pause program until Tobii Glasses starts collecting data
                    samples = [];
                    tic
                    while isempty(samples)
                        % Report error if cannot collect samples within 30 seconds
                        if toc > 30
                            success = 0;
                            [~, ~] = system('Taskkill /IM python.exe /F'); % kill python
                            [~, ~] = system('Taskkill /IM cmd.exe'); % kill cmd prompt
                            warning('Problem connecting to Tobii Glasses or Python LSL. Check that glasses are turned on and connected and try again.');
                            break
                        else
                            [samples,~] = obj.LSL_inlet.pull_chunk(); % request data from LSL
                            success = 1;
                        end
                    end
    
                    obj.connected = success; % 1 if success, 0 if not
                end
                if obj.connected
                    init(obj)
                elseif ~isempty(obj.model)
                    %warning('%sdevice not connected.\n', [obj.model ' '])
                end
            end
        end
        
        function ack = send_msg(msg, obj)
            % Send message to the hardware.
            if obj.connected
                switch msg
                    case 'record'
                        if strcmp(obj.model,'PupilLabs')
                            unused = 1;
                            [ack] = StartRecordingPupilLabs(unused, obj.socket);
                        elseif ismember(obj.model,{'SMI500', 'SMIXX'})
                            StartRecordingEyeTracker;
                        elseif strcmp(obj.model,'Interacoustics')
                            obj.pupil.StartSampling();
                        elseif strcmp(obj.model,'TobiiSpectrum')
                            obj.pupil.start_recording();
                        elseif strcmp(obj.model, 'TobiiGlasses')
                            % DO NOTHING.
                            % Should have started recording upon establishing connection
                            % See Connect()
                        end
                    case 'stop' % at the end of HINT list
                        
                        pause(0.1) % Let time for the hardware to write the different message from before if needed.
                        if strcmp(obj.model,'PupilLabs')
                            [ack] = StopRecordingPupilLabs(obj.socket);
                        elseif ismember(obj.model,{'SMI500', 'SMIXX'})
                            StopRecordingEyeTracker(msg);
                        elseif strcmp(obj.model,'Interacoustics')
                            obj.pupil.StopSampling();
%                             obj.pupil.Data;
                            path = createDirSave(obj.savepath);
                            obj.pupil.SaveCSV([path, filesep, obj.savefile]);
                        elseif strcmp(obj.model,'TobiiSpectrum')
                            obj.pupil.stop_recording();
                            fpath = createDirSave(obj.savepath);
                            obj.pupil.save(obj.savefile, string(fpath));  
                            obj.pupil = [];
                            obj.connected = 0;
                        elseif strcmp(obj.model,'TobiiGlasses')
                            
                            % Stop recording
                            [~, ~] = system('Taskkill /IM python.exe /F'); % kill python
                            [~, ~] = system('Taskkill /IM cmd.exe'); % kill cmd prompt
                            obj.connected = 0;
                            
                            % Remove trailing nans from pre-allocated data matrix
                            obj.data        = obj.data(1:obj.nsamples,:);
                            triggers = strings(obj.nsamples,1);
                            for t = 1:length(obj.annotations)
                                triggers(obj.annotations{t,1}) = obj.annotations{t,2};
                            end
%                             obj.annotations = obj.annotations(1:obj.nsamples);
                            
                            % Column titles (see TobiiGlassesAPI readme.md)
                            columnTitles = ['Pupil center x' ...
                                      'Pupil center y' ...
                                      'Pupil center z' ...
                                      'Pupil diameter left' ...
                                      'Pupil diameter right' ...
                                      'Gaze direction left x' ...
                                      'Gaze direction left y' ...
                                      'Gaze direction left z' ...
                                      'Gaze direction right x' ...
                                      'Gaze direction right y' ...
                                      'Gaze direction right z' ...
                                      'Index since device start' ...
                                      'Timestamp (ms)' ...
                                      'Trigger'];
                            
                            % Save data to csv
                            fprintf('Saving pupil data. This may take a while.');
                            
                            path = createDirSave(obj.savepath);
                            fp = [path filesep obj.savefile];
                            fid = fopen(fp, 'w');
                            
                            formatheader = [repmat('%s,',1,14) '\n'];
                            fprintf(fid, formatheader, columnTitles);
                            
                            formatdata   = [repmat('%s,',1,14) '\n'];
                            fprintf(fid, formatdata, horzcat(obj.data, triggers)');
                            
                            fclose(fid);
                            disp([newline 'Data saved successfully. Program completed.']);
                        end
                        
                    otherwise % for annotation and other purposes.
                        if strcmp(obj.model,'PupilLabs')
                            [ack] = SendMessagePupilLabs(msg, obj.socket);
                        elseif ismember(obj.model,{'SMI500', 'SMIXX'})
                            SendMessageEyeTracker(msg);
                        elseif strcmp(obj.model,'Interacoustics')
                            obj.pupil.AddMessage(msg);
                        elseif strcmp(obj.model,'TobiiSpectrum')
                            obj.pupil.send_trigger(msg);
                        elseif strcmp(obj.model, 'TobiiGlasses')
                            
%                             fprintf('%s\n', msg);
                            
                            % Retrieve and store new data chunk at every trigger
                            
                            % Retrieve data from LSL
                            [samples,~] = obj.LSL_inlet.pull_chunk();

                            % If there is new data (and there should be...)
                            if ~isempty(samples)
                                samples = samples';
                                
                                % Add current data (samples) to main data matrix (obj.data)
                                chunkSize = size(samples,1);
                                obj.data(obj.nsamples+1:obj.nsamples+chunkSize,:) = samples;
                                obj.nsamples = obj.nsamples+chunkSize;
                                
                                % Add annotation to last sample
                                obj.annotations(length(obj.annotations)+1,:) = ...
                                    {obj.nsamples, strcat('TRIGGER - ', string(msg))};
                                
                            else
                                warning(['%s %s: No data retrieved from LSL.\nMake sure Tobii power/connection were not lost during recording, ', ...
                                    'or that the ''TIME RECORDING'' variable in configTobii.ini is suitable for your setup.'], datestr(now), msg);
                            end
                        end
                end
                pause(0.05)  % Second pause to make sure it is written.
            elseif ~isempty(obj.model) % Eye tracker not connected
                if ~strcmp(msg, 'List_completed') % don't try to connect if 'Finish measurement' button clicked
                    connect(obj); % otherwise, try to connect.
                end
            end
        end
        
        function disconnect(obj)
            
            %     Disconnect from hardware and delete all socket instances.
            if obj.connected
                if strcmp(obj.model,'PupilLabs')
                    zmq.core.close(obj.socket);
                    zmq.core.close(obj.subsocket);
                    zmq.core.ctx_term(obj.context);
                elseif ismember(obj.model,{'SMI500', 'SMIXX'})
                    calllib(obj.libraryname, 'iV_Disconnect')
                    unloadlibrary(obj.libraryname);
                elseif strcmp(obj.model,'Interacoustics')
                    obj.pupil.Dispose();
                elseif strcmp(obj.model, 'TobiiSpectrum')
                    obj.pupil.stop_recording();
                    py.del(obj.pupil);
                end
                obj.connected = 0;
                disp('Device disconnected.')
            end  
        end
        
        function init(obj)
            if strcmp(obj.model,'PupilLabs')
                % initalze device, start the two eyes, set detection mode to
                % 3D, subscribe to the pupil data stream and start the
                % annotation capture
                topic = uint8(char('notify.meta.should_doc'));
                payload = containers.Map({'subject'},{'meta.should_doc'});
                msgpackpayload = dumpmsgpack(payload);
                zmq.core.send(obj.socket, topic, 'ZMQ_SNDMORE');
                zmq.core.send(obj.socket, msgpackpayload);
                char(zmq.core.recv(obj.socket)) % client recv
                pause(0.5)
                %
                % Set pupil detection mode to 3D
                topic = uint8(char('notify.set_detection_mapping_mode'));
                payload = containers.Map({'subject','mode'},{'set_detection_mapping_mode','3d'});
                msgpackpayload = dumpmsgpack(payload);
                zmq.core.send(obj.socket, topic, 'ZMQ_SNDMORE');
                zmq.core.send(obj.socket, msgpackpayload);
                char(zmq.core.recv(obj.socket)) % client recv
                pause(0.5)
                
                % Start the pupil0 process (right-eye)
                topic = uint8(char('notify.eye_process.should_start.0'));
                payload = containers.Map({'subject','eye_id'},{'eye_process.should_start.0',uint8(0)});
                msgpackpayload = dumpmsgpack(payload);
                zmq.core.send(obj.socket, topic, 'ZMQ_SNDMORE');
                zmq.core.send(obj.socket, msgpackpayload);
                char(zmq.core.recv(obj.socket)) % client recv
                pause(0.5)
                %
                % Start the pupil1 process (left-eye)
                topic = uint8(char('notify.eye_process.should_start.1'));
                payload = containers.Map({'subject','eye_id'},{'eye_process.should_start.1',uint8(1)});
                msgpackpayload = dumpmsgpack(payload);
                zmq.core.send(obj.socket, topic, 'ZMQ_SNDMORE');
                zmq.core.send(obj.socket, msgpackpayload);
                char(zmq.core.recv(obj.socket)) % client recv
                pause(0.5)
                
                % Subscribe to pupil data stream
                obj.subsocket = zmq.core.socket(obj.context, 'ZMQ_SUB');
                obj.subaddress = sprintf([obj.network,':%d'], str2num(obj.subport));
                zmq.core.connect(obj.subsocket, obj.subaddress);
                zmq.core.setsockopt(obj.subsocket,'ZMQ_SUBSCRIBE','pupil.');
                zmq.core.setsockopt(obj.subsocket, 'ZMQ_LINGER', 0);
                pause(0.5)
                
                % Start the annotation capture
                topic = uint8(char('notify.start_plugin.Annotation_Capture'));
                payload = containers.Map({'subject','name'},{'start_plugin','Annotation_Capture'});
                msgpackpayload = dumpmsgpack(payload);
                zmq.core.send(obj.socket, topic, 'ZMQ_SNDMORE');
                zmq.core.send(obj.socket, msgpackpayload);
                char(zmq.core.recv(obj.socket)) % client recv
                pause(0.5)
                
                disp('Initialized Pupil Labs...')
            elseif ismember(obj.model,{'SMI500', 'SMIXX'})
                % Call the library and the different pointer to the system
                % data
                disp('Get System Info Data')
                calllib(obj.libraryname, 'iV_GetSystemInfo', obj.pointer.pSystemInfoData)
                get(obj.pointer.pSystemInfoData, 'Value')
                disp('Initialized Eye Tracker...')
            elseif strcmp(obj.model, 'TobiiGlasses')
                % pre-allocate a massive data matrix sure to handle any amount of recorded data
                obj.data        = nan(1e7,13);
                obj.annotations = {};
                obj.nsamples    = 0;
            end
            
        end
        function out = isConnected(obj)
            % Get connectivity status.
            out = obj.connected;
        end
        
        function set_savefilename(obj, str)
            obj.savefile = str;
        end
    end
end

function checkPort(value)
    % Check that the value is a double.
    if ~isa(value, 'double')
        error('Port must be a double e.g. 500. If you use SMI glasses put the port in a vector.')
    end
end

function checkNetwork(value, model)
    % Check that the network is a string or a cell.
    if strcmp(model,'PupilLabs')
        if ~(isa(value,'string')||isa(value,'char'))
            error('Network must be a string e.g. ''tcp://localhost''.')
        end
    elseif ismember(model,{'SMI500', 'SMIXX'})
        if ~isa(value, 'cell')
            error(['If glasses use UDP (SMI), adresses are to be in a cell. ', ...
                'The first address being the sender and the second the receiver IP'])
        end
    elseif strcmp(model, '')
        error('Enter the model of the hardware first using the method setModel(value)')
    end
end

function checkModel(value)
    % Check the model specified.
    if ~(isa(value,'string')||isa(value,'char'))
        error('Model must be a string e.g. ''PupilLabs'' or ''SMI''.')
    end
end
