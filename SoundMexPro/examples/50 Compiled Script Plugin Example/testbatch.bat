REM Usually a plugin-executable runs invisible and terminates on errors. Thus you cannot see output that
REM would usually end up 
REM
REM call the plugin with the follwing command line parameter:
REM   	%*			pass arguments passed to batch to exe
REM	>plugin_output.txt	pipe standard output (e.g. 'disp') to file
REM	2>&1			pipe standard error to standard output (will end up in file as well!

SMPPLugin.exe %*  >plugin_output.txt 2>&1