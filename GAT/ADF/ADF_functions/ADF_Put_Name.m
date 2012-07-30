function [D,error_return] = ADF_Put_Name(PID,ID,name,D);
%
% error_return = ADF_Put_Name(PID,ID,name)
% Put a Name on a Node
% See ADF_USERGUIDE.pdf for details
%
%Put (change) Name of a Node.  Warning:  If the node is pointed to by a 
%link-node, changing the node's name will break the link.
%
%ADF_Put_Name( PID, ID, name, error_return )
%input:  const double PID	The ID of the Node's parent.
%input:  const double ID		The ID of the node to use.
%input:  const char *name	The new name of the node.
%output: int *error_return	Error return.

error_return = ADFI_Check_String_Length(name,D.ADF_Name_Length);
[D,error_return] = Check_ADF_Abort(error_return,D);

error_return = -1;

% Get the file, block and offset numbers from the PID
[D,file_index,parent_block_offset.block,parent_block_offset.offset,error_return] = ADFI_ID_2_File_Block_Offset(PID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Get the file, block and offset numbers from the ID
[D,file_index,child_block_offset.block,child_block_offset.offset,error_return] = ADFI_ID_2_File_Block_Offset(ID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Get node header for the node (parent)
[D,parent_node,error_return] = ADFI_Read_Node_Header(file_index,parent_block_offset,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Get node header for the node (child)
[D,child_node,error_return] = ADFI_Read_Node_Header(file_index,child_block_offset,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Skip any leading blanks in the name
name_start = 1;
while name(name_start) == ' '
    name_start = name_start+1;
end
name_length = length(name(name_start:end));
if name_length > D.ADF_Name_Length
    error_return = 4;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

if name_length == 0
    error_return = 3;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

% Need to check for uniqueness and legality of the name
[D,found,sub_node_entry_location,sub_node_entry,error_return] = ADFI_Check_4_Child_Name(file_index,parent_block_offset,name(name_start:end),D);
[D,error_return] = Check_ADF_Abort(error_return,D);

if found == 1
    error_return = 26;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

for i = 0:name_length-1
    if ischar(name(name_start+i)) ~= 1 | strcmp(name(name_start+i),'/')
        error_return = 56;
        [D,error_return] = Check_ADF_Abort(error_return,D);
    end
end

% Confirm that child is from the parent
[D,found,sub_node_entry_location,sub_node_entry,error_return] = ADFI_Check_4_Child_Name(file_index,parent_block_offset,child_node.name,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

if found == 0
    error_return = 29;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

if child_block_offset.block ~= sub_node_entry.child_location.block | child_block_offset.offset ~= sub_node_entry.child_location.offset
    error_return = 29;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

% Copy the name
name = ADFI_Blank_Fill_String(name(name_start:end),D.ADF_Name_Length);
child_node.name = name;
sub_node_entry.child_name = name;

% Write modified node header
[D,error_return] = ADFI_Write_Node_Header(file_index,child_block_offset,child_node,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Replace the child's name in the parent's sub-node table
[D,error_return] = ADFI_Write_Sub_Node_Table_Entry(file_index,sub_node_entry_location,sub_node_entry,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Finally, update the modification date
[D,error_return] = ADFI_Write_Modification_Date(file_index,D);
[D,error_return] = Check_ADF_Abort(error_return,D);