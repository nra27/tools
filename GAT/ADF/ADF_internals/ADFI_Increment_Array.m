function [D,current_position,element_offset,error_return] = ADFI_Increment_Array(ndim,dimms,dim_start,dim_end,dim_stride,current_possition,D);
%
% [D,current_position,element_offset,error_return] = ADFI_Increment_Array(ndim,dimms,dim_start,dim_end,dim_stride,current_possition,D)
%
% D - Declaration Space
% current_position - The position in the N-D space
% element_offset - Number of elements to jump to next (1 to N)
% error_return - Error return
% ndims - The numner of dimensions to use (1 to 12)
% dims - The dimensional space
% dim_start - The starting dimension of our sub-space, first = 1
% dim_end - The ending dimension of out sub-space, last[n] = dims[n]
% dim_stride - The stride to take in our sub-space (every Nth element)
% 
% Possible errors: (note: and enxtensive error check is NOT done...)
% NO_ERROR, NULL_POINTER, BAD_NUMBER_OF_DIMMENSIONS

if ndim <= 0 | ndim > 12
	error_return = 28;
	return
end

error_return = -1;

offset = 0;
accumulated_size = 1;
for i = 1:ndim
	if current_position(i) + dim_stride(i) < dim_end(i)
		current_position(i) = current_position(i) + dim_stride(i);
		offset = offset + 1 + (dim_stride(i) - 1)*accumulated_size;
		break
	else
		offset = offset + dims(i) - current_position(i) + dim_start(i) -1
		% The -1 above is to let the next loop add its stride
		current_position(i) = dim_start(i);
		accumulated_size = accumulated_size*dims(i);
	end
end

element_offset = offset;