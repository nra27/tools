function output = Array_to_Strip(input,width);
%
% output = Array_to_Strip(input,width)
%
% Fit an array to interleaved multi array

[f,old_length] = size(input);
new_length = old_length*width;

% initialize array
output = zeros(1,new_length);

count = [1:width:new_length-1];

for j = 1:width
    output(count+(j-1)) = input(j,:);
end