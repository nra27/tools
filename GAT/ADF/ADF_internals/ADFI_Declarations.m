function D = ADFI_Declarations;
%
% declarations = ADFI_Declarations
% Provide declarations for the internal ADF-Core routines
% and sets up most of the Matlab variable sizes

% Library and Database versions
D.ADF_L_Identification = '@(#)ADF Library Version E01>    ';
D.ADF_D_Identification = '@(#)ADF Database Version A02011>';

% The length of items in a sub_node_list is a multiple of List_Chunk
D.List_Chunk = 8;
D.List_Chunk_Grow_Factor = 1.5;

% File prarameters
D.Disk_Block_Size = 4096;
D.Maximum_Files = 128;
D.Maximum_32_Bits = 429496795;
D.Blank_File_Block = 0;
D.Blank_Block_Offset = D.Disk_Block_Size;

% Size of things on disk
D.File_Header_Size = 186;
D.Free_Chunk_Table_Size = 80;
D.Free_Chunk_Entry_Size = 32;
D.Node_Header_Size = 246;
D.Disk_Pointer_Size = 12;
D.Tag_Size = 4;
D.What_String_Size = 32;
D.Date_Time_Size = 28;
D.ADF_Name_Length = 32;
D.ADF_Lable_Length = 32;
D.ADF_Data_Type_Length = 32;
D.ADF_Max_Dimensions = 12;

% Smallest amount of data (chunk) to be allocated.  Mimimum size corresponds to the
% free-chunk minimum size for the free-chunk linked lists.
D.Smallest_Chunk_Size = D.Node_Header_Size;
D.Small_Chunk_Maximum = 1024;
D.Medium_Chunk_Maximum = D.Disk_Block_Size;
D.Free_Chunk_Block = 0;
D.Free_Chunk_Offset = D.File_Header_Size;
D.Root_Node_Block = 0;
D.Root_Node_Offset = D.Free_Chunk_Offset + D.Free_Chunk_Table_Size;

D.Root_Node_Name = 'ADF MotherNode                  ';
D.Root_Node_Label = 'Root Node of ADF File           ';

% Machine formats
D.Undefined_Format = '0';
D.IEEE_Big_32_Format = '1';
D.IEEE_Little_32_Format = '2';
D.IEEE_Big_64_Format = '3';
D.IEEE_Little_64_Format = '4';
D.Cray_Format = '5';
D.Native_Format = '99';

D.Undefined_Format_Char = 'U';
D.IEEE_Big_Format_Char = 'B';
D.IEEE_Little_Format_Char = 'L';
D.Cray_Format_Char = 'C';
D.Native_Format_Char = 'N';
D.OS_64_Bit = 'B';
D.OS_32_Bit = 'L';

D.IEEE_Big_32_Format_String = 'IEEE_BIG_32';
D.IEEE_Little_32_Format_String = 'IEEE_LITTLE_32';
D.IEEE_Big_64_Format_String = 'IEEE_BIG_64';
D.IEEE_Little_64_Format_String = 'IEEE_Little_64';
D.Cray_Format_String = 'CRAY';
D.Native_Format_String = 'NATIVE';

% Character strings defining the data tags
D.File_Header_Tags(1,:) = 'AdF0';
D.File_Header_Tags(2,:) = 'AdF1';
D.File_Header_Tags(3,:) = 'AdF2';
D.File_Header_Tags(4,:) = 'AdF3';
D.File_Header_Tags(5,:) = 'AdF4';
D.File_Header_Tags(6,:) = 'AdF5';
D.Node_Start_Tag = 'NoDe';
D.Node_End_Tag = 'TaiL';
D.Free_Chunk_Table_Start_Tag = 'fCbt';
D.Free_Chunk_Table_End_Tag = 'Fcte';

D.Free_Chunk_Start_Tag = 'FreE';
D.Free_Chunk_End_Tag = 'EndC';
D.Sub_Node_Start_Tag = 'SNTb';
D.Sub_Node_End_Tag = 'snTE';
D.Data_Chunk_Table_Start_Tag = 'DCtb';
D.Data_Chunk_Table_End_Tag = 'dcTE';
D.Data_Chunk_Start_Tag = 'DaTa';
D.Data_Chunk_End_Tag = 'dEnD';

D.False = 0;
D.True = -1;

% File_in_Use: Used to track the files currently in use.
% 0 if file is NOT in use.
% 1 if file IS in use.
D.File_in_Use = zeros(1,D.Maximum_Files);

% First_File_in_System: If a file is opened which is a sub-tree
% of a parent ADF structure, this is the index of the top parent file.
D.First_File_in_System = zeros(1,D.Maximum_Files);

% ADF_File: The system-returned descriptor of an opened file.
D.ADF_File = zeros(1,D.Maximum_Files);

% Name_of_Files: Names of opened files
D.Name_of_Files = cell(1,D.Maximum_Files);

% File_Open_Mode: The mode the file was opened in.
D.File_Open_Mode = cell(1,D.Maximum_Files);

% File_Version_Update: If library file verison is greater than file version,
% library file version (what-string) is temporarily stored in this array to update
% to the file.
D.File_Version_Update = cell(1,D.Maximum_Files);

% Track the format of this machine as well as the format of each of the files.
% This is used for reading and writing numeric data associated with the nodes,
% which may inlude numeric-format translations.
D.ADF_File_Format = cell(1,D.Maximum_Files);
D.ADF_File_OS_Size = cell(1,D.Maximum_Files);
D.ADF_This_Machine_Format = D.Undefined_Format_Char;
D.ADF_This_Machine_OS_Size = D.Undefined_Format_Char;

% Define a block of 'zz'-bytes for dead space
D.Block_of_ZZ = zeros(1,D.Smallest_Chunk_Size);
D.Block_of_ZZ_Initialized = D.False;

% Define a block of 'xx'-bytes for free blocks
D.Block_of_XX = zeros(1,D.Disk_Block_Size);
D.Block_of_XX_Initialized = D.False;

% Define a block of null-bytes for disk conditioning
D.Block_of_00 = zeros(1,D.Disk_Block_Size);
D.Block_of_00_Initialized = D.False;

% Assumed machine variable sizes for the currently supported machines.
% For ordering of data, see the Figure_Machine_Format function.  Note
% that when opennign a new file not in the machine format these are the
% sizes used.
D.Number_Known_Machines = 5;
D.Machine_Sizes =  [1 1 1 2 2 4 4 4 4 4 8 4 4 4 4 4;  % IEEE BIG 32
                    1 1 1 2 2 4 4 4 4 4 8 4 4 4 4 4;  % IEEE SMALL 32
                    1 1 1 2 2 4 4 8 8 4 8 8 8 8 8 8;  % IEEE BIG 64
                    1 1 1 2 2 4 4 8 8 4 8 8 8 8 8 8;  % IEEE SMALL 64
                    1 1 1 8 8 8 8 8 8 8 8 8 8 8 8 8]; % CRAY 64
                
% Powers of 16
D.Pows = [1 16 256 4096 65536 1048576 16777216 268435456];

% ASCII_Hex
D.ASCII_Hex = {'0' '1' '2' '3' '4' '5' '6' '7' '8' '9' 'A' 'B' 'C' 'D' 'E' 'F'};

% Read/Write conversion buffer
D.Conversion_Buffer_Size = 100000;
D.From_to_Data = zeros(1,D.Conversion_Buffer_Size);

% Read/Write buffering variables
D.Rd_Block_Buffer = zeros(1,D.Disk_Block_Size);
D.Last_Rd_Block = 0;
D.Last_Rd_File = 0;
D.Num_in_Rd_Block = 0;
D.Wr_Block_Buffer = zeros(1,D.Disk_Block_Size);
D.Last_Wr_Block = -1;
D.Last_Wr_File = -1;
D.Flush_Wr_Block = -1;
D.Max_Stack = 50;
for i = 1:D.Max_Stack
    D.PRISTK(i).file_index = -1;
    D.PRISTK(i).file_block = 0;
    D.PRISTK(i).block_offset = 0;
    D.PRISTK(i).stack_type = -1;
    D.PRISTK(i).priority_level = -1;
    D.PRISTK(i).stack_data = [];
end
D.Stack_Init = 0;

% ADF Function variables
D.ADF_Abort_on_Error = D.False;
D.Link_Separator = zeros(D.Maximum_Files,2);

% String length settings
D.ADF_Data_Type_Length = 32;
D.ADF_Date_Length = 32;
D.ADF_File_Name_Length = 1024;
D.ADF_Format_Length = 20;
D.ADF_Label_Length = 32;
D.ADF_Maximum_Link_Depth = 100;
D.ADF_Maximum_Dimensions = 12;
D.ADF_Max_Error_String_Length = 80;
D.ADF_Max_Link_Data_Size = 4096;
D.ADF_Name_Length = 32;
D.ADF_Status_Length = 32;
D.ADF_Version_Length = 32;