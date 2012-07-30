function [D,error_return] = ADF_Put_Dimension_Information(ID,data_type,dims,dim_vals,D);
%
% error_return = ADF_Put_Dimension_Information(ID)
% Set or Change the Data Type and Dimensions
% See ADF_USERGUIDE.pdf for details
%
%Set/change the data-type and Dimension Information of a Node.  Valid 
%user-definable data-types are:
%
%No data				    MT
%Integer 32 			    I4
%Integer 64	    		    I8
%Unsigned Int 32		    U4
%Unsigned Int 64    		U8
%Real 32				    R4
%Real 64			    	R8
%Complex 64			        X4
%Complex 128			    X8
%Character (unsigned byte)	C1
%Byte (unsigned byte)		B1
%Compound data-types can be used which combine types 
%("I4,I4,R8"), define an array ("I4[25]"), or a combination of these 
%("I4,C1[20],R8[3]").
%dims can be a number from 0 to 12.
%
%dim_vals is an array of integers.  The number of integers used is
%determined by the dims argument.  If dims is zero, the dim_values
%are not used.  Valid range for dim_values are from 1 to 2,147,483,648.
%The total data size, calculated by the data-type-size times the
%dimension value(s), cannot exceed 2,147,483,648.
%
%Note:  When this routine is called and the data-type or the 
%number of dimensions changes, any data currently associated 
%with the node is lost!!   The dimension values can be changed and 
%the data space will be extended as needed.
%
%ADF_Put_Dimension_Information( ID, data_type, dims, dim_vals, error_return )
%input:  const double ID         The ID of the node.
%input:  const char *data-type   The data-type to use.
%input:  const int dims          The number of dimensions this node has.
%input:  const int dim_vals[]    The dimension values for this node.
%output: int *error_return       Error return.

preserve_data = D.False;

error_return = ADFI_Check_String_Length(data_type,D.ADF_Data_Type_Length);
[D,error_return] = Check_ADF_Abort(error_return,D);

error_return = -1;

[D,LID,file_index,block_offset,node,error_return] = ADFI_Chase_Link(ID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Check new data-type
[D,file_bytes,machine_bytes,tokenized_data_type,file_format,machine_format,error_return] = ADFI_Evaluate_Datatype(file_index,data_type,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Look at old datatype
[D,file_bytes(2),machine_bytes(2),tokenized_data_type,file_format,machine_format,error_return] = ADFI_Evaluate_Datatype(file_index,node.data_type,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Calculate new data size
if dims < 0
    error_return = 1;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end
if dims > D.ADF_Max_Dimensions
    error_return = 28;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

% If the number of dimensions is zero, set data-bytes to zero
if dims == 0
    data_bytes = 0;
else % Calculate the total number of bytes in the data
    data_bytes = file_bytes(1);
    for i = 1:dims
        if dim_vals(i) <= 0
            error_return = 28;
            [D,error_return] = Check_ADF_Abort(error_return,D);
        end
        data_bytes = data_bytes*dim_vals(i);
    end
end

% Calculate old data size
if node.number_of_dimensions == 0
    old_data_bytes = 0;
else
    old_data_bytes = file_bytes(2);
    for i = 1:node.number_of_dimensions
        old_data_bytes = old_data_bytes*node.dimension_values(i);
    end
end

% If the data-types are the same...
if strcmp(node.data_type,data_type)
	if dims == node.number_of_dimensions
    	preserve_data = D.True;
	end
else % If a different datatype, throw-away the data, record new datatype
    datatype_length = length(data_type);
    % Copy datatype
    for i = 1:min(datatype_length,D.ADF_Data_Type_Length)
        node.data_type(i) = data_type(i);
    end
    if i < D.ADF_Data_Type_Length
        for i = i+1:D.ADF_Data_Type_Length
            node.data_type(i) = ' ';
        end
    end
end

% Record the number of dimensions and the dimension values
node.number_of_dimensions = dims;
for i = 1:dims
    node.dimension_values(i) = dim_vals(i);
end % Zero out remaining entries
for i = dims+1:D.ADF_Max_Dimensions
    node.dimension_values(i) = 0;
end

if preserve_data ~= D.True % Free old data
    [D,error_return] = ADFI_Delete_Data(file_index,node,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    node.number_of_data_chunks = 0;
    [D,node.data_chunks] = ADFI_Set_Blank_Disk_Pointer(D);
end

% Write modified mode_header for the node
[D,error_return] = ADFI_Write_Node_Header(file_index,block_offset,node,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Finally, update modification date
[D,error_return] = ADFI_Write_Modification_Date(file_index,D);
[D,error_return] = Check_ADF_Abort(error_return,D);