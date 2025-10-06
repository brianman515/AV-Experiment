classdef (Abstract = true) ComInterface < handle
    %     Abstract class for communication with modules
    methods(Abstract)
        connect()
    %     Connect to said hardware.
        send_msg(string)
    %     Send message to the hardware.
        disconnect()
    %     Disconnect from hardware and delete all socket instances.
    end
end