function [ID,error_return] = ADF_Link(PID,name,file,name_in_file)
%
% [ID,error_return] = ADF_Link(PID,name,file,name_in_file)
% Create a Link to a Node
% See ADF_USERGUIDE.pdf for details
%
%Create a link.  Note:  The Node linked to does not have to exist when the 
%link is created (but it may exist and that is OK).  However, when 
%the link is used, an error will occur if the linked to node does not 
%exist.
%
%ADF_Link( PID, name, file, name_in_file, ID, error_return )
%input:  const double PID	The ID of the Node's parent.
%input:  const char *name	The name of the link node.
%input:  const char *file	The filename to use for the link (directly 
%	usable by a C open() routine).  If blank (null), 
%	the link will be within the same file.
%
%input:  const char *name_in_file The name of the node which 
%	the link will point to.  This can be a simple or compound name.
%
%output: double ID		The returned ID of the link-node.
%output: int *error_return	Error return

error_return = -1;
null_filename = D.False;

error_return = ADFI_Check_String_Length(name,D.ADF_Name_Length);
[D,error_return] = Check_ADF_Abort(error_return,D);

[D,linked_to_length,error_return] = ADF_Is_Link(PID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

if linked_to_length > 0
    error_return = 50;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

% Create the node in the normal way.
[D,ID,error_return] = ADF_Create(PID,name);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Get the file, block and offset numbers from the ID
[D,file_index,block_offset.block,block_offset.offset,error_return] = ADFI_ID_2_File_Block_Offset(ID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Add the file and linked-to name as data in the child
error_return = ADFI_Check_String_Length(file,D.ADF_Filename_Length);
if error_return ~= -1
    null_filename = D.True;
    filename_length = 0;
else
    filename_length = length(file);
end

linked_to_length = length(name_in_file);
data_length = filename_length+linked_to_length+1;
if data_length > D.ADF_Max_Link_Data_Size;
    error_return = 4;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

if null_filename == D.True
    link_data = [link_separator(file_index) name_in_file];
else
    link_data = [file link_separator(file_index) name_in_file];
end

% We must use a datatype of 'C1' to put the data into this node.
% With a datatype of 'LK' (a link), the written data will go into
% the linked-to node (that's the whole point).  To set this up
% we must be careful...

dim_vals = data_length;
[D,error_return] = ADF_Put_Dimension_Information(ID,'C1',1,dim_vals,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

[D,error_return] = ADF_Write_All_Data(ID,link_data,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Change the datatype to be 'LK', without deleting the data.
% We can't use ADF_Put_Dimension_Information since the change
% of datatype will delete the data.  We must do this manually.

[D,node_header] = ADFI_Read_Node_Header(file_index,block_offset,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

if strcmp(node_header.data_type,'C1')
    error_return = 31;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

node_header.data_type = 'LK';
[D,error_return] = ADFI_Write_Node_Header(file_index,block_offset,node_header,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Finally, update modification date
[D,error_return] = ADFI_Write_Modification_Date(file_index,D);
[D,error_return] = Check_ADF_Abort(error_return,D);