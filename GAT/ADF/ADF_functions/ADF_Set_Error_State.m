function [D,error_return] = ADF_Set_Error_State(error_state,D);
%
% error_return = ADF_Set_Error_State(error_state)
% Set the Error State Flag
% See ADF_USERGUIDE.pdf for details
%
%Set Error State.  For all ADF calls, set the error handling convention;
%either return error codes, or abort the program on an error.  The
%default state for the ADF interface is to return error codes and NOT abort.
%
%ADF_Set_Error_State( error_state, error_return )
%input:  const int error_state	Flag for ABORT on error (1) or return error
%				status (0).
%output: int *error_return	Error return.

error_return = -1;
if error_state == 0
    D.ADF_Abort_on_Error = D.False;
elseif error_state == 1
    D.ADF_Abort_on_Error = D.True;
else
    error_return = 48;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end