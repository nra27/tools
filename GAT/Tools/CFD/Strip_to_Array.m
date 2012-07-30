function output = Strip_to_Array(input,width);
%
% output = Strip_to_Array(input,width)
%
% Fit a single dimension array with interleaved data
% to the specified array

old_length = length(input);
new_length = old_length/width;

% initialize array
output = zeros(new_length,width);

count = [1:width:old_length-1];

for j = 1:width
    output(:,j) = input(count+(j-1))';
end