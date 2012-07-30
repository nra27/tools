function [D,stack_data,error_return] = ADFI_Stack_Control(file_index,file_block,block_offset,stack_mode,stack_type,data_length,stack_data,D);
%
% [D,stack_data,error_return] = ADFI_Stack_Control(file_index,file_block,block_offset,stack_mode,stack_type,data_length,stack_data,D)
%
% D - Declaration space
% stack_data - The character string buffered, is input for mode 'SET' and output for mode 'GET'
% error_return - Error return
% file_index - The ADF file index
% file_block - Block within the file
% block_offset - Offset within the block
% stack_mode - Control mode: 'INIT', 'GET' or 'SET'
% stack_type - Type of stack entry to process: 'FILE', 'NODE', etc...
% data_length - Length of data to buffer
%
% Possible errors:
% NO_ERROR, NULL_STRING_POINTER, ADF_FILE_NOT_OPENED, PRISTK_NOT_FOUND
% Note: errors are only important for GET mode since you must then go
% ahead and read the data from the file.  The stack is only meant to
% speed things up, not stop the process!

if D.File_in_Use(file_index) == 0 & stack_mode ~= 'INIT_STK'
    error_return = 9;
    return
end

error_return = -1;

% Process depending on the mode
switch stack_mode
    case {'INIT_STK','CLEAR_STK','CLEAR_STK_TYPE'}
        % Clear all entries with current file_index and or type,
        % if file_index is 0 then clear all the entries!!
        for i = 1:D.Max_Stack
            if strcmp(stack_mode,'INIT_STK')
                D.PRISTK(i).priority_level = -1;
            elseif file_index ~= D.PRISTK(i).file_index & file_index ~= 0
                continue
            elseif strcmp(stack_mode,'CLEAR_STK_TYPE') &  ~strcmp(stack_type,D.PRISTK(i).stack_type)
                continue
            end
            if D.PRISTK(i).priority_level > 0
                D.PRISTK(i).stack_data = [];
                D.PRISTK(i).file_index = -1;
                D.PRISTK(i).file_block = 0;
                D.PRISTK(i).block_offset = 0;
                D.PRISTK(i).stack_type = -1;
                D.PRISTK(i).priority_level = -1;
            end
        end
        if strcmp(stack_mode,'STK_INIT')
            D.Stack_Init = 1;
        end
        
    case 'GET_STK'
        % Try to find the entry in the current stack but matching the
        % file index, block and offset.  If found copy data, else if
        % not found, return with an error
        for i = 1:D.Max_Stack
            % Very time consuming task
            if D.PRISTK(i).file_index ~= file_index | ...
                    D.PRISTK(i).file_block ~= file_block | ...
                    D.PRISTK(i).block_offset ~= block_offset
                continue
            elseif D.PRISTK(i).stack_type == stack_type
                % Found the entry, so copy it into the return string
                stack_data = D.PRISTK(i).stack_data;
                % Up its priority to number one
                D.PRISTK(i).priority_level = 1;
                return
            else
                % Type doesn't match, so delete the bad entry
                D.PRISTK(i).stack_data = ' ';
                D.PRISTK(i).file_index = -1;
                D.PRISTK(i).file_block = 0;
                D.PRISTK(i).block_offset = 0;
                D.PRISTK(i).stack_type = -1;
                D.PRISTK(i).priority_level = -1;
            end
        end
        % Didn't find it, so return and error
        error_return = 59;
        
    case 'DEL_STK_ENTRY'
        % Try and find the entry and delete it from the stack
        for i = 1:D.Max_Stack
            if D.PRISTK(i).file_index == file_index & ...
                    D.PRISTK(i).file_block == file_block & ...
                    D.PRISTK(i).block_offset == block_offset
                D.PRISTK(i).stack_data = '';
                D.PRISTK(i).file_index = -1;
                D.PRISTK(i).file_block = 0;
                D.PRISTK(i).block_offset = 0;
                D.PRISTK(i).stack_type = -1;
                D.PRISTK(i).priority_level = -1;
                return
            end
        end
        
    case 'SET_STK'
        % Try and find the entry or an empty slot or the lowest priority
        % slot.  If it exists then it has its priority bumped to number 1
        found = 'f';
        low_priority = -1;
        for i = 1:D.Max_Stack
            % Very time consuming task
            if D.PRISTK(i).file_index == file_index & ...
                    D.PRISTK(i).file_block == file_block & ...
                    D.PRISTK(i).block_offset == block_offset
                found = 't';
                % it exists, so up it priority level
                D.PRISTK(i).priority_level = 1;
                % Copy possibley new stack data
                D.PRISTK(i).stack_data = stack_data;
                
            elseif D.PRISTK(i).stack_type >= 0 
                % Existing entry so lower its priority, if it is the
                % lowest then save its index for possible replacement
                if D.PRISTK(i).priority_level > low_priority
                    low_priority = D.PRISTK(i).priority_level;
                    insert_index = i;
                end
                D.PRISTK(i).priority_level = D.PRISTK(i).priority_level+1;
                
            elseif strcmp(found,'f')
                % An empty entry set pointer for possible insertion
                low_priority = D.Max_Stack*D.Max_Stack;
                insert_index = i;
                found = 'e';
            end
        end
        
        % If the item was already on the stack, then we are done.
        if strcmp(found,'t')
            return
        end
        % Insert the data onto the stack at teh index_insert location
        i = insert_index;
        D.PRISTK(i).stack_data = stack_data;
        D.PRISTK(i).file_index = file_index;
        D.PRISTK(i).file_block = file_block;
        D.PRISTK(i).block_offset = block_offset;
        D.PRISTK(i).stack_type = stack_type;
        D.PRISTK(i).priority_level = 1;
end            
            