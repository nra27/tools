function input = Read_Input_File;
%
% input = Read_Input_File
%
% A funtion to read the input.dat file that controls
% hydra.  This function must be run from the directory
% containing the file.
%
% The output is a structure containing:
% input
%   +- grid_file
%   +- flow_file
%   +- R
%   +- gamma
%   +- omega