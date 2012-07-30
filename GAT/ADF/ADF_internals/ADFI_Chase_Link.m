function [D,LID,file_index,block_offset,node_header,error_return] = ADFI_Chase_Link(ID,D);
%
% [D,LID,file_index,block_offset,node_header,error_return] = ADFI_Chase_Link(ID,D)
%
% Given an ID, return the ID, file, block/offset and node header of the
% node.  If the ID is a link, traverse the link(s) until a non-link node
% is found.  This is the data returned.
%
% D - Declaration space
% LID - ID of the non-link node (may == ID)
% file_index - File index for LID
% block_offset - Block and offset for LID
% node_header - The node header for LID
% error_return - Error return
% ID - ID of the start node

done = D.False;
link_depth = 0;

Link_ID = ID;
while done == D.False
    % Get the file, block and offset numbers from the ID
    [D,file_index,block_offset.block,block_offset.offset,error_return] = ADFI_ID_2_File_Block_Offset(Link_ID,D);
    if error_return ~= -1
        return
    end
    
    % Get node header for node
    [D,node_header,error_return] = ADFI_Read_Node_Header(file_index,block_offset,D);
    if error_return ~= -1
        return
    end
    
    if strcmp(node_header.data_type,'LK')
        % node is a link, get file and path data
        [D,link_file,link_path,error_return] = ADF_Get_Link_Path(Link_ID);
        if error_return ~= -1
            return
        end
        
        if link_file ~= ''; % A filename is specified, open it.
            % Link_ID = root-node of the new file
            % note: the file could already be opened, and may be the current file!
            
            [D,found,link_file_index,Link_ID,error_return] = ADFI_Get_File_Index_from_Name(link_file,D);
            if found == 0
                % File not found, try to open it
                status = D.File_Open_Mode(file_index);
                if strcmp(status,'READ_ONLY') ~= 1
                    status = 'OLD';
                end
                [D,Link_ID,error_return] = ADF_Database_Open(link_file,statis,'',D);
                if error_return ~= -1
                    error_return = 53;
                    return
                end
            end
        end
        
        % Get the node ID of the link to node (may be other links)
        [D,temp_ID,error_return] = ADF_Get_Node_ID(Link_ID,link_path,D);
        if error_return == 29
            error_return = 52; % A better error message
        end
        if error_return ~= -1
            return
        end
        
        Link_ID = temp_ID;
        link_depth = link_depth + 1;
        if link_depth > D.ADF_Maximum_Link_Depth
            error_return = 50;
            return
        end
    else % node is not a link
        done = D.True;
    end
end

LID = Link_ID;