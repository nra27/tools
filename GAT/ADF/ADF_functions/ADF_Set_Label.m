function [D,error_return] = ADF_Set_Label(ID,label,D);
%
% error_return = ADF_Get_Label(ID,label)
% Set the String in a Node's Label Field
% See ADF_USERGUIDE.pdf for details

error_return = -1;

[D,LID,file_index,block_offset,node,error_return] = ADFI_Chase_Link(ID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Copy the label
error_return = ADFI_Check_String_Length(label,D.ADF_Label_Length);
[D,error_return] = Check_ADF_Abort(error_return,D);

label = ADFI_Blank_Fill_String(label,D.ADF_Label_Length);

node.label = label;

% Write modeified node header
[D,error_return] = ADFI_Write_Node_Header(file_index,block_offset,node,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Update modification date
[D,error_return] = ADFI_Write_Modification_Date(file_index,D);
[D,error_return] = Check_ADF_Abort(error_return,D);