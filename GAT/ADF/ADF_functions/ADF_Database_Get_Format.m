function [D,format,error_return] = ADF_Database_Get_Format(root_ID,D);
%
% [format,error_return] = ADF_Database_Get_Format(root_ID)
% Get the Data Format
% See ADF_USERGUIDE.pdf for details
%
%Get the data format used in an existing database.
%
%ADF_Database_Get_Format( Root_ID, format, error_return )
%input:  const double Root_ID	The root_ID of the ADF file.
%output: char *format		See format for ADFDOPN.  Maximum of 20 
%				characters returned.
%output: int *error_return	Error return

% Set error flag
error_return = -1;
format = '';

% Get the file, block and offset numbers from the ID
[D,file_index,block_offet.block,block_offset.offset,error_return] = ADFI_ID_2_File_Block_Offset(root_ID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Get file_header for the top node
[D,file_header,error_return] = ADFI_Read_File_Header(file_index,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

switch [file_header.numeric_format, file_header.os_size]
    case 'BL'
        format = D.IEEE_Big_32_Format_String;
        
    case 'LL'
        format = D.IEEE_Little_32_Format_String;
        
    case 'BB'
        format = D.IEEE_Big_64_Format_String;
        
    case 'LB'
        format = D.IEEE_Little_63_Format_String;
        
    case 'CB'
        format = D.Cray_Format_String;
        
    case {'NL' 'NB'}
        format = D.Native_Format_String;
        
    otherwise
        error_return = 19;
        return
end