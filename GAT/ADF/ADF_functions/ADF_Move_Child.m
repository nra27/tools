function [D,error_return] = ADF_Move_Child(PID,ID,NPID,D);
%
% error_return = ADF_Move_Child(PID,ID,NPID)
% Move a Child Node to a different Parent
% See ADF_USERGUIDE.pdf for details
%
%Change Parent (move a Child Node).  The node and the 2 parents must 
%all exist within a single ADF file.  If the node is pointed to by a 
%link-node, changing the node's parent will break the link.
%
%ADF_Move_Child( PID, ID, NPID, error_return )
%input:  double PID		The ID of the Node's parent.
%input:  double ID		The ID of the node to use.
%input:  double NPID		The ID of the Node's New Parent 
%output: int *error_return	Error return.

error_return = -1;

[D,parent_file_index,parent.block,parent.offset,error_return] = ADFI_ID_2_File_Block_Offset(PID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

[D,child_file_index,child.block,child.offset,error_return] = ADFI_ID_2_File_Block_Offset(ID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

if child_file_index ~= parent_file_index
    error_return = 58;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

[D,new_parent_file_index,new_parent.block,new_parent.offset,error_return] = ADFI_ID_2_File_Block_Offset(NPID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

if new_parent_file_index ~= parent_file_index
    error_return = 58;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

file_index = parent_file_index; % Use a shorter, more generic name. File indices should all be the same now.

% Check that child is really a child of parent
[D,child_name,error_return] = ADF_Get_Name(ID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

[D,found,sub_node_entry_location,sub_node_entry,error_return] = ADFI_Check_4_Child_Name(file_index,parent,child_name,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

if found == 0 % Child NOT found
    error_return = 29;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

% Add child to its new parent's sub node table
[D,error_return] = ADFI_2_Sub_Node_Table(file_index,new_parent,child,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Remove child from its old parent's sub node table
[D,error_return] = ADFI_Delete_from_Sub_Node_Table(file_index,parent,child,D);
[D,error_return] = Check_ADF_Abort(error_return,D);