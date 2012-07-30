function [D,node_header,error_return] = ADFI_Fill_Initial_Node_Header(D);
%
% [D,node_header,error_return] = ADFI_Fill_Initial_Node_Header(D)
%
% To fill out a new node header
%
% D - Declaration space
% node_header - The resulting node header information
% error_return - Error return
%
% Possibl errors:
% NO_ERROR, NULL_POINTER

error_return = -1;

node_header.start_tag = D.Node_Start_Tag;
node_header.end_tag = D.Node_End_Tag;

% Blank out the name
node_header.name(1:D.ADF_Name_Length) = ' ';

% Blank out the label
node_header.label(1:D.ADF_Label_Length) = ' ';

% Set the number of sub nodes to zero
node_header.num_sub_nodes = 0;
node_header.entries_for_sub_nodes = 0;
[D,node_header.sub_node_table] = ADFI_Set_Blank_Disk_Pointer(D);

% Set the data type to eMpTy
node_header.data_type = ADFI_Blank_Fill_String('MT',32);

% Zeros out number of dimensions and set dimension values to zero
node_header.number_of_dimensions = 0;
node_header.dimension_values(1:D.ADF_Max_Dimensions) = 0;

% Set number of data chunks to zero, zero out data chunk pointer
node_header.number_of_data_chunks = 0;
[D,node_header.data_chunks] = ADFI_Set_Blank_Disk_Pointer(D);