function ADFI_Abort(error_string)
% ADFI_Abort(error_code)
% Do any clean up and then shut down.
% error_code - Error which caused the abort.

disp('ADF Aborted: Exiting')
disp(['Error Code: ' error_string])

fclose('all'); % Close all files
clear all   % Clear variables
pause

% exit

