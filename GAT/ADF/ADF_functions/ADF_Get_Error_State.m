function [D,error_state,error_return] = ADF_Get_Error_State(D);
%
% [error_state,error_return] = ADF_Get_Error_State()
% Get the Error State Flag
% See ADF_USERGUIDE.pdf for details
%
%ADF Get Error State:
%
%Get Error State.  Return the current error state.
%
%ADF_Get_Error_State( error_state, error_return )
%output: int *error_state	Flag for ABORT on error (1) or return error
%				status (0).
%output: int *error_return	Error return

error_return = -1;

if D.ADF_Abort_on_Error == D.True
    error_state = 1;
else
    error_state = 0;
end