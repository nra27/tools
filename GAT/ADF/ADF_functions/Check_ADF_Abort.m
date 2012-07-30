function [D,error_flag] = Check_ADF_Abort(error_flag,D);
%
% Check_ADF_Abort(error_flag)
%

if error_flag ~= -1
    if D.ADF_Abort_on_Error == D.True
        [D,error_string] = ADF_Error_Message(error_flag,D);
        ADFI_Abort(error_string);
    else
        return
    end
end