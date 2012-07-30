function [D,error_return] = ADFI_Write_File(file_index,file_block,block_offset,data_type,data_length,data,D);
%
% [D,error_return] = ADFI_Write_File(file_index,file_block,block_offset,data_length,data,D)
%
% Write a number of bytes to an ADF file, given the file, block and block offset.
%
% D - Declaration space
% error_return - Error_return
% file_index - The file index to write to
% file_block - The block within the file
% block_offset - The offset within the block
% data_length - The length of the data to write
% data - The data to write
%
% Possible errors:
% NO_ERROR, NULL_STRING_POINTER,ADF_FILE_NOT_OPENED, FWRITE_ERROR

if D.File_in_Use(file_index) == 0
    error_return = 9;
    return
end

error_return = -1;

if data_type == 0
    data_type = 'uchar';
else
    switch data_type
        case 'R4'
            data_type = 'single';
            data_length = data_length/4;
            
        case 'R8'
            data_type = 'double';
            data_length = data_length/8;
            
        case 'I4'
            data_type = 'int32';
            data_length = data_length/4;
			
		case {'C1' 'LK'}
			data_type = 'uchar';
            
        otherwise
            error_return = 31;
            return
    end
end

% If the read buffer overlaps the buffer to be written, then reset it to
% make sure that it is current

end_block = file_block + (block_offset + data_length)/D.Disk_Block_Size + 1;
if D.Last_Rd_File == file_index & D.Last_Rd_Block >= file_block & D.Last_Rd_Block <= end_block
    D.Last_Rd_Block = 0;
    D.Last_Rd_File = 0;
    D.Num_in_Rd_Block = 0;
end

% Check to see if we need to flush the write buffer.  This happens if we are writing to a
% large_chunk or the write moves out of the current block.  If the data length is zero then
% just flush the buffer and return.  Note that the ADF_Modification_Date routine will flush
% the buffer after any write operations!

if ((data_length + block_offset) > D.Disk_Block_Size | D.Last_Wr_Block ~= file_block | D.Last_Wr_File ~= file_index | data_length == 0 | ~strcmp(data_type,'uchar')) & D.Flush_Wr_Block > 0
    % Position the file
    [D,error_return] = ADFI_Fseek_File(D.Last_Wr_File,D.Last_Wr_Block,0,D);
    if error_return ~= -1
        return
    end
    
    % Write the buffer
    iret = fwrite(D.ADF_File(D.Last_Wr_File),D.Wr_Block_Buffer);
    D.Flush_Wr_Block = -1; % Make sure we don't flush twice due to error
    if iret ~= D.Disk_Block_Size
        error_return = 14;
        return
    end
    
    % If the write buffer overlaps the buffer then reset it to make sure
    % it is current, set flush buffer flag to false
    if D.Last_Wr_File == file_index & D.Last_Wr_Block >= file_block & D.Last_Wr_Block <= end_block
        D.Last_Wr_Block = -1;
        D.Last_Wr_File = -1;
    end
end

if data_length == 0
    % Just a buffer flush
    return
end

% No need to buffer large pieces of data or to take special measures to cross
% block boundaries
if (data_length + block_offset) > D.Disk_Block_Size | ~strcmp(data_type,'uchar')
    % Position the file
    [D,error_return] = ADFI_Fseek_File(file_index,file_block,block_offset,D);
    if error_return ~= -1
        return
    end
    
    % Write the data
    iret = fwrite(D.ADF_File(file_index),data,data_type);
    if iret ~= data_length
        error_return = 14;
        return
    end
    % All done here
    return
end

% For smaller pieces of data, write a block at a time.  This will improve
% performance if neighboring data is writen a small piece at a time (strided
% reads, file overhead).
%
% Some assumptions apply to the block size.  With some experimenting, 1K blocks
% do not offer much improvement.  4K blocks (4096 bytes) do improve performace
% remarkably.  This is due to the fact that the file structure is based on 4K
% blocks with offsets.  Also the CRAY loves 4K block writes!!

if file_block ~= D.Last_Wr_Block | file_index ~= D.Last_Wr_File % Different block or different file
    
    % Buffer is not current, re-read
    if file_block == D.Last_Rd_Block & file_index == D.Last_Rd_File
        
        % Copy data from read buffer
        D.Wr_Block_Buffer = D.Rd_Block_Buffer;
        iret = D.Num_in_Rd_Block;
    else
        
        % Position the file
        [D,error_return] = ADFI_Fseek_File(file_index,file_block,0,D);
        if error_return ~= -1
            return
        end
        
        % Read the data from the disk
        [D.Wr_Block_Buffer,iret] = fread(D.ADF_File(file_index),D.Disk_Block_Size);
		D.Wr_Block_Buffer = char(D.Wr_Block_Buffer');
        if iret == 'EOF' | iret < D.Disk_Block_Size
            D.Wr_Block_Buffer(iret+1:D.Disk_Block_Size) = zeros(1,D.Disk_Block_Size-iret);
            if iret < 0
                iret = 0;
            end
        end
    end
    
    % Remember buffer information
    D.Last_Wr_Block = file_block;
    D.Last_Wr_File = file_index;
end

% Write into the buffer and set flush buffer flag
D.Wr_Block_Buffer(block_offset+1:block_offset+data_length) = data;
D.Flush_Wr_Block = 1;