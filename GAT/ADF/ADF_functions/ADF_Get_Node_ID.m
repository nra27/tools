function [D,ID,error_return] = ADF_Get_Node_ID(PID,name,D);
%
% [ID,error_return] = ADF_Get_Node_ID(PID,name)
% Get the ID of a Child Node
% See ADF_USERGUIDE.pdf for details
%
%Get Unique-Identifier of a Node.  Given a parent node ID and a name of
%a child node, this routine returns the ID of the child.  If the child
%node is a link, the ID of the link node is returned (not the ID of the
%linked-to node) - otherwise there would be no way to obtain the ID
%of a link node.
%
%The child name may be a simple name or a compound path name.
%If the name is a compound path name and it begins with a '/',
%then the parent node ID may be any valid ID in the same database
%as the first node in the path.  If the name is only "/" and the
%parent ID is any valid ID in the database, the root ID is returned.
%If the name is a compound path name and does not begin with a '/',
%then the parent node ID is the ID of the parent of the first node
%in the path.  If the path name contains a link node (except for
%the ending leaf node), then the link is followed.
%
%
%ADF_Get_Node_ID( PID, name, ID, error_return )
%input:  const double PID    The ID of name's parent.
%input:  const char *name    The name of the node.  Compound 
%    names including path information use a slash "/" notation between
%    node names.  If a leading slash is used, then PID can be any 
%    valid node ID in the ADF database of the first name in the path.
%
%output: double *ID          The ID of the named node.
%output: int *error_return   Error return.
%
%   Possible errors:
%NO_ERROR
%NULL_STRING_POINTER
%NULL_POINTER

name_length = length(name);
if name_length == 0
    error_return = 3;
    return
end

error_return = -1;

ID = PID; % Initialize the ID variable to use in intermediate steps

if strcmp(name(1),'/') % Start at the root node
    % According to user documentation, PID can be any valid node in the
    % database, but we need to use it to get the root ID in order
    % to start at the top
    
    [D,ID,error_return] = ADF_Get_Root_ID(PID,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    % This is the root-node, return the root-ID
    if name_length == 1
        return % Not an error, just done and need to get out.
    end
end

% Split the name up into the component node names
index = findstr(name,'/');
a = 1;
b = 1;

if isempty(index)
    sub_names{1} = name;
else
    if index(1) ~= 1
        sub_names{a} = name(1:index(1)-1);
        a = 2;
        b = 1;
    end

    for i = 1:length(index)-b
        if index(i) == 1
            sub_names{a} = name(index(i)+1:index(i+1)-1);
        else
            sub_names{a} = name(index(i)+1:index(i+1)-1);
        end
        a = a + 1;
    end
    if index(end) < length(string)
        sub_names{a} = name(index(end)+1:end);
    end
end

% Get file-index, etc. to start.  Note: Parent ID may be a link
[D,LID,file_index,parent_block_offset,node_header,error_return] = ADFI_Chase_Link(ID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);
ID = LID;

% Track through the possible compound name strings
for step = 1:length(sub_names)
    % Find this child under the current parent
    [D,found,sub_node_entry_location,sub_node_entry,error_return] = ADFI_Check_4_Child_Name(file_index,parent_block_offset,sub_names{step},D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    if found == 0 % Child NOT found
        error_return = 29;
        [D,error_return] = Check_ADF_Abort(error_return,D);
    end
    
    % Create the child ID
    [D,ID,error_return] = ADFI_File_Block_Offset_2_ID(file_index,sub_node_entry.child_location.block,sub_node_entry.child_location.offset,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    if step ~= length(sub_names)
        % Make sure we have a real ID so we can continue the search
        [D,LID,file_index,parent_block_offset,node_header,error_return] = ADFI_Chase_Link(ID,D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        ID = LID;
    end
    
    % This child now becomes the parent.  And we go round agian...
    [D,file_index,parent_block_offset.block,parent_block_offset.offset,error_return] = ADFI_ID_2_File_Block_Offset(ID,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
end