% 
%        Initialization script for the SoundMexPro tutorial
% Copyright Hoerzentrum Oldenburg gGmbH Oldenburg 2015, written by Daniel Berg
% 
% Helper script for the SoundMexPro tutorials. Called at the beginning of
% every tutorial script. Loads configuration from t_smpcfg.mat, or - if it
% doesn't exist - calls t_00_setup_tutorial.m to create it
%

clc;
close all;
clear soundmexpro;



% create full filename of confirguration file
[folder, name, ext] = fileparts(mfilename('fullpath'));
cfgfile = [folder '\t_smpcfg.mat'];

% load structure smpcfg from file containing driver, input and output
% channels to be used in tutorial.

% if it doesn't exist, call script t_00_setup.m to create it
if ~exist(cfgfile, 'file')
   t_00_setup_tutorial;
   if ~exist(cfgfile, 'file')
       return;
   end
end

load(cfgfile);
