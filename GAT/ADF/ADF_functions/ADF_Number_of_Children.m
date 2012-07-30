function [D,num_children,error_return] = ADF_Number_of_Children(PID,D);
%
% [num_children,error_return] = ADF_Number_of_Children(PID)
% Get the Number of the Children Nodes
% See ADF_USERGUIDE.pdf for details

error_return = -1;

[D,LID,file_index,block_offset,node,error_return] = ADFI_Chase_Link(PID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Return the number of children
num_children = node.num_sub_nodes;