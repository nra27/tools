function [D,found,sub_node_entry_location,sub_node_entry,error_return] = ADFI_Check_4_Child_Name(file_index,parent,name,D);
%
% [found,sub_node_entry_location,sub_node_entry,error_return] =
%								ADFI_Check_4_Child_Name(file_index,parent,name,D);
%
% Cbecks for the name of a child in a parent's sub-node-table
%
% found - Flag for success, 0 if NOT found, else 1
% sub_node_entry_location - Disk pointer
% sub_node_entry - sub node table entry
% error_returb - Error return
% file_index - Index of ADF file
% parent - Location of parent
% name - The name of the new child
% D - Declaration space
%
% Possible errors:
% NO_ERROR, NULL_POINTER, ADF_FILE_NOT_OPENED, MEMORY_ALLOCATION_FAILED

if isempty(parent) | isempty(file_index)
	error_return = 32;
	return
end

if isempty(name)
	error_return = 12;
	return
end

if D.File_in_Use(file_index) == 0
	error_return = 9;
	return
end

error_return = -1;
found = 0; % default to not found
sub_node_entry_location.block = 0;
sub_node_entry_location.offset = 0;
sub_node_entry.child_name = ' ';
sub_node_entry.child_location.block = 0;
sub_node_entry.child_location.offset = 0;

% Get node_header for the node
[D,parent_node,error_return] = ADFI_Read_Node_Header(file_index,parent,D);
if error_return ~= -1
	return
end

% Check for valid node name
% If the parent has no children, then the new name MUST be NOT found
if parent_node.num_sub_nodes == 0
	found = 0;
	return
end

if parent_node.entries_for_sub_nodes > 0
	[D,sub_node_table,error_return] = ADFI_Read_Sub_Node_Table(file_index,parent_node.sub_node_table,D);
	if error_return ~= -1
		return
	end
	for i = 1:parent_node.num_sub_nodes
		[found,error_return] = ADFI_Compare_Node_Names(sub_node_table(i).child_name,name,D);
		if error_return ~= -1
			break
		end
		if found == 1 % Name was found, save off addresses
			sub_node_entry_location.block = parent_node.sub_node_table.block;
			sub_node_entry_location.offset = parent_node.sub_node_table.offset + ...
				D.Tag_Size + D.Disk_Pointer_Size + (D.ADF_Name_Length + D.Disk_Pointer_Size)*(i-1);
			
			[D,sub_node_entry_location,error_return] = ADFI_Adjust_Disk_Pointer(sub_node_entry_location,D);
			if error_return ~= -1
				return
			end
			
			% Also save off the child's name
			sub_node_entry.child_name = sub_node_table(i).child_name;
			sub_node_entry.child_location.block = sub_node_table(i).child_location.block;
			sub_node_entry.child_location.offset = sub_node_table(i).child_location.offset;
		
    		% Get out of the for loop as we have found the name
		    break
		end % end if		
	end % end for
end % end if