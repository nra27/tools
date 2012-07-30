function [D,data,error_return] = ADFI_Read_File(file_index,file_block,block_offset,data_type,data_length,D);
%
% [D,data_out,error_return] = ADFI_Read_File(file_index,file_block,block_offset,tokenized_data_type,data_length,data,D)
%
% Read a number of bytes from an open ADF file from a given file, block and offset.  Buffering is done
% in an attempt to improve performance of repeatedly reading small pieces of contiguous data.
% Note: read buffering also affects the write function, ie. all writes must reset the read buffer
%
% D - Declaration space
% data - Data
% error_return - Error return
% file_index - the adf file to read
% file_block - block within the file
% block_offset - offset within the block
% data_length - length of the data
%
% Possible errors:
% NO_ERROR, NULL_STRING_POINTER, ADF_FILE_NOT_OPENED, FREAD_ERROR

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

% No need to buffer large pieces of data or to take special measures to
% cross block boundaries
% We will make an assumption that long reads are for data, while short
% reads are for moving 'round the file.

if data_length + block_offset > D.Disk_Block_Size | ~strcmp(data_type,'uchar')
       
    % Position the file
    [D,error_return] = ADFI_Fseek_File(file_index,file_block,block_offset,D);
    if error_return ~= -1
        error_return = 13;
        return
    end
    
    % Read the data from disk
    [data,iret] = fread(D.ADF_File(file_index),data_length,data_type);
    data = data';
    if iret ~= data_length
        error_return = 15;
        return
    end    
    return
end

% For smaller pieces of data, read a block at a time.  This will improve performance
% if neighbouring data is requested a small piece at a time (strided reads, file overhead).
%
% Some assumptions apply to the block size.  With some experimenting, 1K blocks do not
% offer much improvement.  4K blocks (4096) do improve performance remarkably.  This
% is fue to the fact that the file structure is based on 4K blocks with offset.
    
if D.Num_in_Rd_Block < D.Disk_Block_Size | ... % buffer is not full
    file_block ~= D.Last_Rd_Block | ... % a different block
    file_index ~= D.Last_Rd_File % entirely differnet file
   
    % Buffer is not current, re-read
    if file_block == D.Last_Wr_Block & file_index == D.Last_Wr_File
        % Copy data from write buffer
        D.Rd_Block_Buffer = D.Wr_Block_Buffer;
        iret = D.Disk_Block_Size;
    else
        % Position the file
        [D,error_return] = ADFI_Fseek_File(file_index,file_block,0,D);
        if error_return ~= -1
            error_return = 13;
            return
        end
            
        % Read the data from disk
        [D.Rd_Block_Buffer,iret] = fread(D.ADF_File(file_index),D.Disk_Block_Size);
        D.Rd_Block_Buffer = char(D.Rd_Block_Buffer');
        if iret == 'EOF' | iret == 0
            error_return = 15;
            return
        end
    end
            
    % Remember buffer information
    D.Last_Rd_Block = file_block;
    D.Last_Rd_File = file_index;
    D.Num_in_Rd_Block = iret;       
end        

% Copy from buffer
data = D.Rd_Block_Buffer(block_offset+1:block_offset+data_length);