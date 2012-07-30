function [D,version,error_return] = ADF_Library_Version(D);
%
% [version,error_return] = ADF_Library_Version()
% Get the Version Number of the ADF Library that the Application Program is Currently Using
% See ADF_USERGUIDE.pdf for details

error_return = -1;

version = D.ADF_L_Identification(5:end-5);