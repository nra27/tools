function [D,total_points,starting_offset,error_return] = ADFI_Count_Total_Array_Points(ndim,dims,dim_start,dim_end,dim_stride,D);
%
% [D,total_points,starting_offset,error_return] = ADFI_Count_Total_Array_Points(ndim,dims,dim_start,dim_end,dim_stride,D)
%
% D - Declaration space
% total_points - Total points defined in our sub space
% starting_offset - Number of elements skipped before first element
% error_return - Error return
% ndim - Number of dimensions to use (1 to 12)
% dims - The dimensional space
% dim_start - The starting dimension of our sub-space, first = 1
% dim_end - The ending dimension of our sub-space, last[n] = dims[n]
% dim_stride - The stride to take in our sub-space (every Nth element)
%
% Possible errors:
% NO_ERROR, NULL_POINTER, BAD_NUMBER_OF_DIMENSIONS, BAD_DIMENSION_VALUE, START_OUT_OF_DEFINIED_RANGE,
% END_OUT_OF_DEFINED_RANGE, BAD_STRIDE_VALUE, MINIMUM_GT_MAXIMUM

if ndim <= 0 | ndim > 12
    error_return = 47;
    return
end

error_return = -1;

% Check the inputs
for i = 1:ndim
    
    % Check dims[] >= 1
    if dims(i) < 1
        error_return = 47;
        return
    end
    
    % Check starting values are >= 1 and <= dims
    if dim_start(i) < 1 | dim_start(i) > dims(i)
        error_return = 45;
        return
    end
    
    % Check ending values are >= 1 and <= dims and >= dim_start
    if dim_end(i) < 1 | dim_end(i) > dims(i)
        error_return = 36;
        return
    end
    if dim_end(i) < dim_start(i)
        error_return = 38;
        return
    end
    
    % Check stride >= 1
    if dim_stride(i) < 1
        error_return = 37;
        return
    end
end

total = 1;
offset = 0;
accumulated_size = 1;
for i = 1:ndim
    total = total*(dim_end(i) - dim_start(i) + dim_stride(i))/dim_stride(i);
    offset = offset + (dim_start(i) - 1)*accumulated_size;
    accumulated_size = accumulated_size*dims(i);
end

total_points = total;
starting_offset = offset;