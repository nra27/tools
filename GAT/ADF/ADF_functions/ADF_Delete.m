function [D,error_return] = ADF_Delete(PID,ID,D)
%
% error_return = ADF_Delete(PID,ID)
% Delete a Node
% See ADF_USERGUIDE.pdf for details
%
%Delete a Node.   If the node is NOT a link, then the specified node and all 
%sub-nodes anywhere under it are also deleted.  For a link, and also 
%for links farther down in the tree, the link-node will be deleted, 
%but the node which the link is linked to is not affected.  When a 
%node is deleted, other link-nodes which point to it are left 
%dangling.  For example, if N13 is deleted, then L1 and L2 point to a 
%non-existing node.  This is OK until L1 and L2 are used.
%
%ADF_Delete( PID, ID, error_return )
%input:  const double PID	The ID of the node's parent.
%input:  const double ID		The ID of the node to use.
%output: int *error_return	Error return.

% Don't use ADFI_Chase_Link - delete link nodes, but NOT the nodes they are linked too.
[D,file_index,child.block,child.offset,error_return] = ADFI_ID_2_File_Block_Offset(ID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

[D,link_path_length,error_return]  = ADF_Is_Link(ID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

[D,node_header,error_return] = ADFI_Read_Node_Header(file_index,child,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Delete node data
if link_path_length > 0 % This IS a link
    % Delete the link path data for this node
    [D,error_return] = ADFI_Delete_Data(file_index,node_header,D);
    
else % This is NOT a link
    % Recursively delete all sub-nodes (children) of this node
    [D,num_ids,ids,error_return] = ADFI_Get_Direct_Children_IDs(file_index,child,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    if num_ids > 0 % If there are children, recursively delete them
        for i = 1:num_ids
            [D,error_return] = ADF_Delete(ID,ids(i),D);
            [D,error_return] = Check_ADF_Abort(error_return,D);
        end
    end
    
    % Delete all data for this node
    [D,error_return] = ADF_Put_Dimension_Information(ID,'MT',0,0,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

% Disassociate node from parent
[D,parrent.block,parent.offset,error_return] = ADFI_ID_2_File_Block_Offset(PID,D);
% File index should be the same as before, since parent and child should be in the 
% same file
[D,error_return] = Check_ADF_Abort(error_return,D);

[D,error_return] = ADFI_Delete_from_Sub_Node_Table(file_index,parent,child,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Delete this node's sub node table
if node_header.entries_for_sub_nodes > 0
    [D,error_return] = ADFI_Delete_Sub_Node_Table(file_index,node_header.sub_node_table,node_header.entries_for_sub_nodes,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

% Delete node header from disk
[D,error_return] = ADFI_File_Free(file_index,child,0,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Finally, update modification date
[D,error_return] = ADFI_Write_Modification_Date(file_index,D);
[D,error_return] = Check_ADF_Abort(error_return,D);