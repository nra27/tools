function [D,found,file_index,ID,error_return] = ADFI_Get_File_Index_from_Name(file_name,D);
%
% [D,found,file_index,ID,error_return] = ADFI_Get_File_Index_from_Name(file_name,D)
%
% Searches file list for given name.  Returns file index and Root ID if name
% is found in list.
%
% D - Declaration space
% found - 1 = name found, 0 = not found
% file_index - ADF file index
% ID - ID of files root node
% error_return - Error return
% file_name - Name of file

error_return = -1;
found = 0;
ID = 0;
file_index = -1;

for i = 1:D.Maximum_Files
    if D.File_in_Use(i) == 1
        if strcmp(file_name,D.Name_of_Files(i))
            % A match!
            [D,ID,error_return] = ADFI_File_Block_Offset_2_ID(i,D.Root_Node_Block,D.Root_Node_Offset,D);
            file_index = i;
            found = 1;
            return
        end
    end
end