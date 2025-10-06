%
%             Setup script for the SoundMexPro tutorial
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
%
% Helper script for the SoundMexPro tutorials to select a sound card and
% sound card channels to be used for the tutorials
%

clear soundmexpro;
clc;


% create full filename of confirguration file
[folder, name, ext] = fileparts(mfilename('fullpath'));
cfgfile = [folder '\t_smpcfg.mat'];





showinitialdlg = 0;

% if config file already exists load it
if exist(cfgfile, 'file')
    load(cfgfile);
    % now check if these settings are valid, i.e. if the driver and the
    % channels are within range. If so, we don't need to show the initial
    % describing dialog
    if ( (isempty(smpcfg.driver)) || (length(smpcfg.output) ~= 2) || (length(smpcfg.input) ~= 2) )
        showinitialdlg = 1;
    else
        [success, drivers] = soundmexpro('getdrivers');
        if success ~= 1
            clear soundmexpro
            error(['error calling ''getdrivers''' error_loc(dbstack)]);
        end
        % if driver is NOT a number it is a driver name. Check if it is known
        if ~isnumeric(smpcfg.driver)
            if isempty(find(ismember(drivers, smpcfg.driver)))
                showinitialdlg = 1;
            end
            % otherwise index must be within range
        else
            if smpcfg.driver >= length(drivers)
                showinitialdlg = 1;
            end
        end
        % if ok up to here, check channel indices
        if showinitialdlg == 0
            [success, outch, inch] = soundmexpro('getchannels', 'driver', smpcfg.driver);
            if success ~= 1
                clear soundmexpro
                error(['error calling ''getchannels''' error_loc(dbstack)]);
            end
            if ( (smpcfg.output(1) >= length(outch)) || (smpcfg.output(2) >= length(outch)) || (smpcfg.input(1) >= length(inch)) || (smpcfg.input(2) >= length(inch)) )
                showinitialdlg = 1;
            end
        end
    end
else
    showinitialdlg = 1;
end

% setup structure with default values and show initial 'what-to-do'-message
if showinitialdlg
    smpcfg.driver = 0;
    smpcfg.output = [0 1];
    smpcfg.input  = [0 1];
    % NOTE: syntax of msgbox is slightly different inoctave and MATLAB,
    % additionally MATLAB has to wait /at least in older versions)
    if exist('OCTAVE_VERSION')
        msgbox('Please select a driver, two output and two input channels to be used in the tutorials');
    else
        uiwait(msgbox('Please select a driver, two output and two input channels to be used in the tutorials','Info','modal'));
    end
end


% loop for optional repeating of selection in case of invalid selection
while 1
    % call soundmexpro_showdevs from soundmexpro/bin directory
    [smpcfg.driver, smpcfg.output, smpcfg.input] = soundmexpro_showdevs(smpcfg.driver, smpcfg.output, smpcfg.input);

    % now check, if new settings are valid
    % 1. driver and two output channels are mandatory
    if ((isempty(smpcfg.driver)) || (length(smpcfg.output) ~= 2))
        Selection = questdlg('Please select a driver, two output and two input channels', ...
            'Warning', ...
            'Retry', 'Abort', ...
            'Retry');

        switch Selection
            case 'Abort'
                % break while loop and end script
                break;
            case 'Retry'
                % if even no driver ws selected, then load config again, if
                % it exists
                if ( (isempty(smpcfg.driver)) && exist(cfgfile, 'file'))
                    load(cfgfile);
                end
        end
        % 2. inputs 'optional': recording tutorials will NOT run
    elseif (length(smpcfg.input) ~= 2)
        Selection = questdlg('You have not selected two input channels. Recording tutorials will not be usable', ...
            'Warning', ...
            'Retry', 'Ignore', 'Abort', ...
            'Retry');

        switch Selection
            case 'Abort'
                % break while loop and end script
                break;
            case 'Ignore'
                % save config even with incorrect number of input channels
                save(cfgfile, 'smpcfg');
                % break while loop and end script
                break;
        end
        % 3. everything is fine: save config
    else
        % save config and break while loop
        save(cfgfile, 'smpcfg');
        % show selection
        smpcfg;
        break;
    end
end

