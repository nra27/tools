function [D,free_chunk_table,error_return] = ADFI_Fill_Initial_Free_Chunk_Table(D);
%
% [D,free_chunk_table,error_return] = ADFI_Fill_Initial_Free_Chunk_Table(D)
%
% To fill out a new free chunk table
%
% D - Declaration space
% free_chunk_table - Resulting header info
% error_retrun - Error_return
%
% Possible errors:
% NO_ERROR, NULL_POINTER

error_return = -1;

free_chunk_table.start_tag = D.Free_Chunk_Table_Start_Tag;
free_chunk_table.end_tag = D.Free_Chunk_Table_End_Tag;

% Small: First and Last Blocks
[D,free_chunk_table.small_first_block] = ADFI_Set_Blank_Disk_Pointer(D);
[D,free_chunk_table.small_last_block] = ADFI_Set_Blank_Disk_Pointer(D);

% Medium: First and Last Blocks
[D,free_chunk_table.medium_first_block] = ADFI_Set_Blank_Disk_Pointer(D);
[D,free_chunk_table.medium_last_block] = ADFI_Set_Blank_Disk_Pointer(D);

% Large: First and Last Blocks
[D,free_chunk_table.large_first_block] = ADFI_Set_Blank_Disk_Pointer(D);
[D,free_chunk_table.large_last_block] = ADFI_Set_Blank_Disk_Pointer(D);