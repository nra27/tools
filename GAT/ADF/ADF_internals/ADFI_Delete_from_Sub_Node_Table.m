function [D,error_return] = ADFI_Delete_from_Sub_Node_Table(file_index,parent,child,D);
%
% [D,error_return] = ADFI_Delete_from_Sub_Node_Table(file_index,parent,child,D)
%
% Delete a child from a parent's sub-node table
%
% Possible errors:
% NO_ERROR, NULL_POINTER, ADF_FILE_NOT_OPENED

if D.File_in_Use(file_index) == 0
    error_return = 9;
    return
end

[D,parent_node,error_return] = ADFI_Read_Node_Header(file_index,parent,D);
if error_return ~= -1
    return
end

[D,sub_node_table,error_return] = ADFI_Read_Sub_Node_Table(file_index,parent_node.sub_node_table,D);
if error_return ~= -1
    return
end

found = -1;
% Find the child in the parent's sub-node table
for i = 1:parent_node.num_sub_nodes
    if child.block == sub_node_table(i).child_location.block & child.offset == sub_node_table(i).child_location.offset
        found = i;
        break
    end
end

if found == -1
    error_return = 24;
    return
end

% Move the rest of the table up to fill the hole
for i = found:(parent_node.num_sub_nodes - 1)
    sub_node_table(i).child_location.block = sub_node_table(i+1).child_location.block;
    sub_node_table(i).child_location.offset = sub_node_table(i+1).child_location.offset;
    sub_node_table(i).child_name = sub_node_table(i+1).child_name;
end

i = parent_node.num_sub_nodes;
sub_node_table(i).child_location.block = 0;
sub_node_table(i).child_location.offset = 0;
sub_node_table(i).child_name = 'unused entry in sub-node-table  ';

% Re-write the parent's sub-node table
[D,error_return] = ADFI_Write_Sub_Node_Table(file_index,parent_node.sub_node_table,parent_node.entries_for_sub_nodes,sub_node_table,D);
if error_return ~= -1
    return
end

% Update the sub-node count and write the parent's node-header
parent_node.num_sub_nodes = parent_node.num_sub_nodes - 1;
[D,error_return] = ADFI_Write_Node_Header(file_index,parent,parent_node,D);
if error_return ~= -1
    return
end

% Clear all subnode/disk entries of the priority stack for file
[D,a,error_return] = ADFI_Stack_Control(file_index,0,0,'CLEAR_STK_TYPE','SUB_NODE_STK',0,0,D);
[D,a,error_return] = ADFI_Stack_Control(file_index,0,0,'CLEAR_STK_TYPE','DISK_PTR_STK',0,0,D);
if error_return ~= -1
    return
end

clear sub_node_table