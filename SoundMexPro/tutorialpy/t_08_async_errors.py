#
#                    Example for usage of SoundMexPro
# Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2021, written by Daniel Berg
#
#
# This example shows how check for and handle 'asynchroneous errors'. These
# errors are errors that do _not_ occur as immediate result of calling a
# SoundMexPro command e.g. due to a syntax error. Such errors are reported
# directly and can be checked for by evaluating the first return value of
# every SoundMex Pro command. 'Asynchroneous errors' occur while a sound
# device is running during the sound processing. They can occur at every
# time, but since no SoundMexPro command is called to force this error,
# SoundMexPro cannot report such an error immediately to MATLAB. Therefore
# such errors are stored and usually the device is stopped. After an
# asynchroneus error occurred, every command called afterwards will
# plot the error description, additionally all commands except ''exit',
# 'stop', 'resetasyncerror' and 'asyncerror' will fail. Usually such errors
# should not occur (if no hardware error occurs), except if a plugin
# (script plugin or VST plugin) returns an error during signal processing.
#
# Since script plugins ar not supported (yet) for Python this example is
# not available for Python. You may check the corresponding MATLAB/Octave
# example to get an idea how to handle asynchroneous errors
