function [network, port] = loadOptionEyeTracker(struct, model)
    % function to prepare parameters for pupil interface object if
    % something is loaded. 
    %
    % HARDCODED LOCAL NETWORK FOR PUPIL LABS -- is not present in
    % oTest.Pupillometry
    
    if strcmp(model,'PupilLabs')
        port = struct.PupilLabsPort;
        network = 'tcp://localhost';
    elseif max(strcmp(model,{'SMI500', 'SMIXX'}))
        network = {struct.SMINetworkSendIP, struct.SMINetworkReceiveIP};
        port = [struct.SMISendPort; struct.SMIReceivePort];
    else
        port = [];
        network = '';
    end
    
