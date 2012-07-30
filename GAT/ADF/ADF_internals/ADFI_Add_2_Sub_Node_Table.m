function [D,error_return] = ADFI_Add_2_Sub_Node_Table(file_index,parent,child,D);
%
% [D,error_return] = ADFI_Add_2_Sub_Node_Table(file_index,parent,child,D)
%
% Add a child to a parent's sub-node table
%
% D - Declaration space
% error_return - Error return
% file_index - The ADF file to write to
% parent - Location of the parent
% child - Location of the child
%
% Possible errors:
% NO_ERROR, NULL_POINTER, ADF_FILE_NOT_OPENED, SUB_NODE_TABLE_ENTRIES_BAD,
% MEMORY_ALLOCATION_FAILED

if D.File_in_Use(file_index) == 0
	error_return = 9;
	return
end

error_return = -1;

% Get node-header for the node (parent)
[D,parent_node,error_return] = ADFI_Read_Node_Header(file_index,parent,D);
if error_return ~= -1
	return
end

% Get node-header for the node (child)
[D,child_node,error_return] = ADFI_Read_Node_Header(file_index,child,D);
if error_return ~= -1
	return
end

% Check current length of sub-node_table, add space if needed
if parent_node.entries_for_sub_nodes <= parent_node.num_sub_nodes
	old_num_entries = parent_node.entries_for_sub_nodes;
	
	% Increase the table space (double it)
	if parent_node.entries_for_sub_nodes == 0
		parent_node.entries_for_sub_nodes = D.List_Chunk;
	else
		parent_node.entries_for_sub_nodes = floor(parent_node.entries_for_sub_nodes * D.List_Chunk_Grow_Factor);
	end
	
	if parent_node.entries_for_sub_nodes <= parent_node.num_sub_nodes
		error_return = 24;
		return
	end
	
	% If sub-node table exists, get it
	if old_num_entries > 0
		[D,sub_node_table,error_return] = ADFI_Read_Sub_Node_Table(file_index,parent_node.sub_node_table,D);
		if error_return ~= -1
			return
		end
	end
	
	% Blank out the new part of the sub-node table
	for i = parent_node.num_sub_nodes:parent_node.entries_for_sub_nodes-1
		sub_node_table(i+1).child_name = 'unused entry in sub-node-table  ';
		sub_node_table(i+1).child_location.block = 0;
		sub_node_table(i+1).child_location.offset = D.Disk_Block_Size;
	end
	
	% Allocate memory for the required table space on disk
	if parent_node.num_sub_nodes > 0 % delete old table from file
		[D,error_return] = ADFI_Delete_Sub_Node_Table(file_index,parent_node.sub_node_table,old_num_entries,D);
		if error_return ~= -1
			return
		end
	end
	
	[D,tmp_disk_ptr,error_return] = ADFI_File_Malloc(file_index,(D.Tag_Size+D.Disk_Pointer_Size+D.Tag_Size+parent_node.entries_for_sub_nodes*(D.ADF_Name_Length+D.Disk_Pointer_Size)),D);
	if error_return ~= -1
		return
	end
	
	parent_node.sub_node_table.block = tmp_disk_ptr.block;
	parent_node.sub_node_table.offset = tmp_disk_ptr.offset;
	
	% Write out modified sub-node table
	[D,error_return] = ADFI_Write_Sub_Node_Table(file_index,parent_node.sub_node_table,parent_node.entries_for_sub_nodes,sub_node_table,D);
	clear sub_node_table
	if error_return ~= -1
		return
	end
end

% Insert new entry in sub-node table
tmp_disk_ptr.block = parent_node.sub_node_table.block;
tmp_disk_ptr.offset = parent_node.sub_node_table.offset + D.Tag_Size + D.Disk_Pointer_Size + parent_node.num_sub_nodes*(D.ADF_Name_Length+D.Disk_Pointer_Size);

[D,tmp_disk_ptr,error_return] = ADFI_Adjust_Disk_Pointer(tmp_disk_ptr,D);
if error_return ~= -1
    return
end

% Write the child's name
[D,error_return] = ADFI_Write_File(file_index,tmp_disk_ptr.block,tmp_disk_ptr.offset,0,D.ADF_Name_Length,child_node.name,D);
if error_return ~= -1
	return
end

% Write out new sub_node table entry
tmp_disk_ptr.offset = tmp_disk_ptr.offset + D.ADF_Name_Length;
[D,error] = ADFI_Write_Disk_Pointer_2_Disk(file_index,tmp_disk_ptr.block,tmp_disk_ptr.offset,child,D);
if error_return ~= -1
	return
end

% Write out modified parent node-header
parent_node.num_sub_nodes = parent_node.num_sub_nodes +1;
[D,error_return] = ADFI_Write_Node_Header(file_index,parent,parent_node,D);
if error_return ~= -1
	return
end