function [D,root_ID,error_return] = ADF_Database_Open(filename,status,format,D);
%
% [root_ID,error_return] = ADT_Database_Open(filename,status_in,format)
% Open a Database
% See ADF_USERGUIDE.pdf for details
%
%Open a database.  Open either a new or an existing ADF file.  If links to
%other ADF files are used, these additional file will be opened
%automatically as required.
%
%ADF_Database_Open( filename, status, format, root_ID, error_return)
%input:  const char *filename	Not used if status SCRATCH is used.
%	Filename must be a legal name and may include a relative or
%	absolute path.  It must be directly usable by the C fopen()
%	system routine.
%
%input:  const char *status_in	Like FORTRAN OPEN() status.  
%	Allowable values are:
%		READ_ONLY - File must exist.  Writing NOT allowed.
%		OLD - File must exist.  Reading and writing allowed.
%		NEW - File must not exist.
%		SCRATCH - New file.  Filename is ignored.
%		UNKNOWN - OLD if file exists, else NEW is used.
%
%input:  const char *format	Specifies the numeric format for the 
%		file.  If blank or NULL, the machine's native format is 
%		used.  This field is only used when a file is created.
%	NATIVE - Determine the format on the machine.  If the 
%		native format is not one of the formats 
%		supported, the created file cannot be used on 
%		other machines.
%	IEEE_BIG - Use the IEEE big ENDIAN format.
%	IEEE_LITTLE - Use the IEEE little ENDIAN format.
%	CRAY - Use the native Cray format.
%
%output:  double *root_ID	Root-ID of the opened ADF database.
%output:  int *error_return	Error return.
%
%   Possible errors:
%NO_ERROR
%NULL_STRING_POINTER
%ADF_FILE_STATUS_NOT_RECOGNIZED
%REQUESTED_NEW_FILE_EXISTS
%FILE_OPEN_ERROR

file_header.tag0 = [];

% Don't check yet for filename, as it may not be needed
error_return = -1;

% Get this machine's numeric format
[D,machine_format,format_to_use,os_to_use,error_return] = ADFI_Figure_Machine_Format(format,D);

if strcmp(status,'SCRATCH') ~= 1
    error_return = ADFI_Check_String_Length(filename,D.ADF_File_Name_Length);
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

error_return = ADFI_Check_String_Length(status,D.ADF_Status_Length);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Determine the requested STATUS
if strcmp(status,'UNKNOWN')
    % Determine the assessability of the filename
    iret = fopen(filename,'r');
    if iret < 1 % File doesn't exist
        status = 'NEW';
    else
        fclose(iret);
        status = 'OLD';
    end
elseif strcmp(status,'READ_ONLY') | strcmp(status,'OLD')
    % Determine the assessability of the filename
    iret = fopen(filename,'r');
    if iret < 1 % File doesn't exist, this is BAD for OLD
        error_return = 22;
        [D,error_return] = Check_ADF_Abort(error_return,D);
    else
        fclose(iret);
    end
    
    % Open the file properly!
    [D,file_index,error_return] = ADFI_Open_File(filename,status,-1,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
elseif strcmp(status,'NEW') | strcmp(status,'SCRATCH')
    % Determine the assessability of the filename
    if strcmp(status,'NEW')
        iret = fopen(filename,'r');
        if iret > 0 % File exists, this is BAD for NEW
            error_return = 18;
            [D,error_return] = Check_ADF_Abort(error_return,D);
        end
    end
    
    % Compose the file header
    [D,file_header,error_return] = ADFI_Fill_Initial_File_Header(format_to_use,os_to_use,D.ADF_D_Identification,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    % Open the new file
    [D,file_index,error_return] = ADFI_Open_File(filename,status,-1,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    % Write out the header file
    [D,error_return] = ADFI_Write_File_Header(file_index,file_header,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    % Compose initial root-node header
    [D,node_header,error_return] = ADFI_Fill_Initial_Node_Header(D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    node_header.name = D.Root_Node_Name;
    node_header.label = D.Root_Node_Label;
    
    % Write out the root-node header
    [D,error_return] = ADFI_Write_Node_Header(file_index,file_header.root_node,node_header,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    % Compose initial free-chunk table
    [D,free_chunk_table,error_return] = ADFI_Initial_Free_Chunk_Table(D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    % Write out Free-Chunk table
    [D,error_return] = ADFI_Write_Free_Chunk_Table(file_index,free_chunk_table,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
else
    error_return = 7;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

% Initialise the link separator for the file.
D.Link_Separator(file_index,1) = '>';

% Read the header of the ADF file
if isempty(file_header.tag0)
    [D,file_header,error_return] = ADFI_Read_File_Header(file_index,D);
    if error_return ~= -1
        [D,error_return] = Open_Error(file_index,error_return,D);
    end
    
    % Check Database version numbers for compatibility
    if file_header.what(26) ~= D.ADF_D_Identification(26);
        % Look at major revision leter: version in file must equal what
        % this library would write unless there is a policy decision
        % to support both versions.
        
        error_return = 57;
        if error_return ~= -1
            [D,error_return] = Open_Error(file_index,error_return,D);
        end
    end
    if file_header.what(29) == '>'
        % We have an old version created before this version numbering scheme
        % was instituted - probably will not work
        error_return = 57;
        [D,error_return] = Open_Error(file_index,error_return,D);
    else
        % Check version number for file compatability
        % Look at minor revision number: version in file must be less that or
        % equal to what this library would write.
           
        [D,file_minor_version,error_return] = ADFI_ASCII_Hex_2_Unsigned_Int(0,255,2,file_header.what(27:28),D);
        if error_return ~= -1
            [D,error_return] = Open_Error(file_index,error_return,D);
        end
            
        [D,lib_minor_version,error_return] = ADFI_ASCII_Hex_2_Unsigned_Int(0,255,2,D.ADF_D_Identification(27:28),D);
        if error_return ~= -1
            [D,error_return] = Open_Error(error_return,D);
        end
            
        if file_minor_version > lib_minor_version
            error_return = 57;
            [D,error_return] = Open_Error(error_return,D);
        end
        if file_minor_version < lib_minor_version
            % If a new feature is added which requires that the file version
            % be changed then it is done here.  Care must be taken not to
            % break forward compatibility by changing the file version.  Thus
            % new features may not be available for older file versions.
            % For instance version A1 files cannot be upgraded to version A2
            % and above since a change was made to how links were stored and the
            % file version is used to decide how to treat links
            if strcmp(D.ADF_D_Identification(26),'A') & file_minor_version > 1
                [D,error_return] = ADFI_Remember_Version_Update(file_index,D.ADF_D_Identification,D);
                if error_return ~= -1
                    [D,error_return] = Open_Error(error_return,D);
                end
            end
            if strcmp(D.ADF_D_Identification(26),'A') & file_minor_version < 2
                D.Link_Separator(file_index,1) = ' ';
            end
        end
    end
end

% Get the root ID for the user
[D,root_ID,error_return] = ADFI_File_Block_Offset_2_ID(file_index,file_header.root_node.block,file_header.root_node.offset,D);
if error_return ~= -1
    [D,error_return] = Open_Error(error_return,D);
end

% Remember the file's data format
[D,error_return] = ADFI_Remember_File_Format(file_index,file_header.numeric_format,file_header.os_size,D);
if error_return ~= -1
    [D,error_return] = Open_Error(error_return,D);
end

% Check machine modes, if machine is native then the file must be!!
[D,formats_compare,error_return] = ADFI_File_and_Machine_Compare(file_index,D);
if error_return ~= -1
    [D,error_return] = Open_Error(error_return,D);
end

% ================================================================================================================================
function [D,error_return] = Open_Error(file_index,error_return,D);
%
% Close ADF file and free its index

[D,error_dummy] = ADFI_Close_File(file_index,D);
[D,error_return] = Check_ADF_Abort(error_return,D);