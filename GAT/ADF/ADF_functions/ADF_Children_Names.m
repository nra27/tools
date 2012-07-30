function [D,inum_ret,names,error_return] = ADF_Children_Names(PID,istart,imax_num,imax_name_length,D);
%
% [inum_ret,names,error_return] = ADF_Children_Names(PID,istart,imax_num,imax_name_length)
% Get the Names of the Child Nodes
% See ADF_USERGUIDE.pdf for details
%
%Get Children names of a Node.  Return the name of children nodes 
%directly associated with a parent node.  The names of the children 
%are NOT guaranteed to be returned in any particular order.  If a new 
%child is added, it is NOT guaranteed to be returned as the last child.
%
%Null-terminated names will be written into the names array and thus
%there needs to be room for the null character.  As an example,
%the array can be defined as:
%
%   char  names[IMAX_NUM][IMAX_NAME_LENGTH+1];
%
%where IMAX_NUM and IMAX_NAME_LENGTH are defined by the using application
%and correspond to this function's "imax_num" and "imax_name_len" parameters
%respectively.  "imax_name_len" is the maximum length of a name to be copied
%into the names array.  This value can be equal to ADF_NAME_LENGTH but does
%not have to be.  However, the name dimension of the array MUST be declared
%to be "imax_name_len" + 1.  The name will be returned truncated (but still
%null-terminated) if the actual name is longer than "imax_name_len" and
%if "imax_name_len" is less than ADF_NAME_LENGTH.
%
%Note that the names array parameter is declared as a single dimension
%character array inside this function.  Therefore, use a (char *) cast to
%cast a two dimensional array argument.
%
%input:  const double PID          The ID of the Node to use.
%input:  const int istart          The Nth child's name to start with (first is 1).
%input:  const int imax_num        Maximum number of names to return.
%input:  const int imax_name_len   Maximum Length of a name to return.
%output: int *inum_ret             The number of names returned.
%output: char *names               The returned names (cast with (char *)).
%output: int *error_return         Error return.
%
%   Possible errors:
%NO_ERROR
%NULL_STRING_POINTER
%NULL_POINTER
%NUMBER_LESS_THAN_MINIMUM

error_return = -1;

if istart <= 0 | imax_num <= 0 | imax_name_length <= 0
    error_return = 1;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

inum_ret = 0;

[D,LID,file_index,block_offset,node,error_return] = ADFI_Chase_Link(PID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Check for zero children, return if 0
if node.num_sub_nodes == 0
    return
end

% Point to the first child wanted/
block_offset.block = node.sub_node_table.block;
block_offset.offset = node.sub_node_table.offset + (D.Tag_Size+D.Disk_Pointer_Size+(D.ADF_Name_Length+D.Disk_Pointer_Size)*(istart-1));

% Return the data for teh requested children
for i = (istart):min(istart+imax_num,node.num_sub_nodes)
    [D,block_offset,error_return] = ADFI_Adjust_Disk_Pointer(block_offset,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    % Read the sub-node entry table
    [D,sub_node_table_entry,error_return] = ADFI_Read_Sub_Node_Table_Entry(file_index,block_offset,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    names{i} = sub_node_table_entry.child_name;
    
    % Increment the disk-pointer and the number of names returned
    block_offset.offset = block_offset.offset + (D.ADF_Name_Length+D.Disk_Pointer_Size);
    inum_ret = inum_ret+1;
end