function [D,label,error_return] = ADF_Get_Label(ID,D);
%
% [label,error_return] = ADF_Get_Label(ID)
% Get the String in a Node's Label Field
% See ADF_USERGUIDE.pdf for details

error_return = -1;

[D,LID,file_index,block_offset,node,error_return] = ADFI_Chase_Link(ID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

label = node.label;