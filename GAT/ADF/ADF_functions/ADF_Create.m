function [D,ID,error_return] = ADF_Create(PID,name,D);
%
% [ID,error_return] = ADF_Create(PID,name)
% Create a Node
% See ADF_USERGUIDE.pdf for details
%
%Create a Node.  Create a new node (not a link-node) as a child of a 
%given parent.  Default values in this new node are:
%	label=blank,
%	number of sub-nodes = 0,
%	data-type = "MT",
%	number of dimensions = 0,
%	data = NULL.
%
%ADF_Create( PID, name, ID, error_return )
%input:  const double PID	The ID of the parent node, to whom we 
%				are creating a new child node.
%input:  const char *name	The name of the new child.
%output: double *ID		The ID of the newly created node.
%output: int *error_return	Error return.
%
%   Possible errors:
%NO_ERROR
%NULL_STRING_POINTER
%NULL_POINTER

error_return = ADFI_Check_String_Length(name,D.ADF_Name_Length);
[D,error_return] = Check_ADF_Abort(error_return,D);

error_return = -1;

[D,LID,file_index,parent_block_offset,parent_node,error_return] = ADFI_Chase_Link(PID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Initialize node header
[D,child_node,error_return] = ADFI_Fill_Initial_Node_Header(D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Skip any leading blanks in the name
name_start = 1;
while name(name_start) == ' '
    name_start = name_start + 1;
end
name_length = length(name(name_start:end));
if name_length > D.ADF_Name_Length
    error_return = 4;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

% Check for uniqueness and legality of the name
[D,found,sub_node_entry_location,sub_node_entry,error_return] = ADFI_Check_4_Child_Name(file_index,parent_block_offset,name(name_start:end),D);
[D,error_return] = Check_ADF_Abort(error_return,D);
if found == 1
    error_return = 26;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

for i = 0:name_length-1
    if ischar(name(name_start+i)) ~= 1 | name(name_start+i) == '/'
        error_return = 56;
        [D,error_return] = Check_ADF_Abort(error_return,D);
    end
end

% Assign the name to the new node
child_node.name = ADFI_Blank_Fill_String(name(name_start:end),32);

% Allocate disk space for the new node
[D,child_block_offset,error_return] = ADFI_File_Malloc(file_index,D.Node_Header_Size,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Write out the new node header
[D,error_return] = ADFI_Write_Node_Header(file_index,child_block_offset,child_node,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% OK, new node is on disk.  Now update the list of children for the parent
[D,error_return] = ADFI_Add_2_Sub_Node_Table(file_index,parent_block_offset,child_block_offset,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Return the ID of the new child
[D,ID,error_return] = ADFI_File_Block_Offset_2_ID(file_index,child_block_offset.block,child_block_offset.offset,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Finally update modification date
[D,error_return] = ADFI_Write_Modification_Date(file_index,D);
[D,error_return] = Check_ADF_Abort(error_return,D);