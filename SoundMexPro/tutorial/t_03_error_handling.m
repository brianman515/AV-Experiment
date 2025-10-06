% 
%                    Example for usage of SoundMexPro
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
% 
%    This example shows user defined error handling in SoundMexPro.  
% 
% NOTE: the command 'reseterror' is not handled here. It deals with
% asynchroneous errors occurred in SoundMexPro, i.e. errors, that did not
% occur while executing a SoundMexPro command, but during running
% playback/recording. Such 'asynchroneous errors' are stored and will
% return this error on every command that is called after such an error.
% Handling asynchroneous errors is shown in one of the advanced examples.
% 
% SoundMexPro commands introduced in this example:
%   showerror
%   getlasterror


% call tutorial-initialization script
t_00b_init_tutorial

% initialize SoundMexPro
if 1 ~= soundmexpro('init', ... % command name
        'driver', smpcfg.driver ...  % driver index
        )
    error(['error calling ''init''' error_loc(dbstack)]);
end

smp_disp('standard error handling:');
% set error switch to 'on'
if 1 ~= soundmexpro('showerror', ...    % command name
        'value', 1 ...                  % turn showerror on by value 1
        )
    error(['error calling ''showerror''' error_loc(dbstack)]);
end

% call an unknown. NOTE: we don't check succes flag here, 
% because we want to continue in every case!
soundmexpro('unknown_command');

smp_disp(' ');
smp_disp('user defined error handling:');

% set error switch to 'off'
if 1 ~= soundmexpro('showerror', ...    % command name
        'value', 0 ...                  % turn showerror off by value 0
        )
    error(['error calling ''showerror''' error_loc(dbstack)]);
end

% again call an unknown command
if 1 ~= soundmexpro('unknown_command')
   % retrieve the error string
   [success, original_error] = soundmexpro('getlasterror');
   % this is really bad: error showing is switched off, but 'getlasterror'
   % fails: there's nothing we can do about it ...
   if 1 ~= success
       % display user defined error string...
       error(['error calling ''getlasterror''' error_loc(dbstack)]);
   end
   % now show display user defined error string containig the 'original'
   % error as well
   smp_disp(['An error occurred: ' original_error]);
end

clear soundmexpro;
