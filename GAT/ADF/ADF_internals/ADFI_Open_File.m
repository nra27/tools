function [D,file_index,error_return] = ADFI_Open_File(file,status,top_file_index,D);
%
% D = ADFI_Open_File(file,status,D)
%
% Track the file used by index
% Also track which files are within a given system so a close for
% the system can close all related files.
%
% D - Declaration space
% file_index - Returned index of the file
% error_return - Error return
% file - The filename to open
% status - The status in which to open the file
%           Allowable values are:
%               READ_ONLY - File must exist. Writing NOT allowed
%               OLD - File nust exist. Reading and writing allowed
%               NEW - File must not exist.
%               SCRATCH - New file. File is ignored
%               UNKNOWN - OLD if the file exists, else NEW is used
% top_file_index - 0 if this is the top file
%
% Possible errors:
% NO_ERROR, NULL_POINTER, NULL_STRING_POINTER, TOO_MANY_ADF_FILES_OPEN,
% ADF_FILE_STATUS_NOT_RECOGNISED, FILE_OPEN_ERROR

error_return = -1;

% Initialize the priority stack if it has not been done
if D.Stack_Init == -1
    [D,a,error_return] = ADFI_Stack_Control(0,0,0,'INIT_STK',0,0,0,D);
end

for index = 1:D.Maximum_Files
    if D.File_in_Use(index) == 0
        break
    end
end

if index > D.Maximum_Files
    error_return = 6;
    return
end

D.ADF_File_Format{index} = D.Undefined_Format_Char;
D.ADF_File_OS_Size{index} = D.Undefined_Format_Char;

% READ_ONLY - File must exist. Writing NOT allowed.
% OLD - File must exist. Reading and writing allowed.
% New - File must not exist.
% SCRATCH - New file. Filename ignored
% UNKNOW - OLD if file exist, else NEW is used

if strcmpi(status,'READ_ONLY')
    fid = fopen(file,'r');
elseif strcmpi(status,'OLD')
    fid = fopen(file,'r+');
elseif strcmpi(status,'NEW')
    fid = fopen(file,'w+');
elseif strcmpi(status,'SCRATCH')
    fid = fopen('scratch_file','w+');
elseif strcmpi(status,'UNKNOWN')
    fid = fopen(file,'a+');
else
    error_return = 7;
    % Clean up
    if D.ADF_File(index) ~= 0
        if fclose(D.ADF_File(index)) ~= 0
            error_return = 43;
        end
        D.File_in_Use(index) = 0;
        D.First_File_in_System(index) = -1;
        D.ADF_File(index) = -1;
        D.File_Version_Update{index} = [];
        return
    end
end

if isempty(fid)
    error_return = 62;
    % Clean up
    if D.ADF_File(index) ~= 0
        if fclose(D.ADF_File(index)) ~= 0
            error_return = 43;
        end
        D.File_in_Use(index) = 0;
        D.First_File_in_System(index) = -1;
        D.ADF_File(index) = -1;
        D.File_Version_Update{index} = [];
        return
    end
end
D.File_in_Use(index) = 1;
D.First_File_in_System(index) = top_file_index;
D.ADF_File(index) = fid;
D.File_Version_Update{index} = [];
file_index = index;
D.File_Open_Mode{index} = status;
if strcmpi(status,'SCRATCH')
    D.Name_of_Files{index} = ' ';
else
    D.Name_of_Files{index} = file;
end