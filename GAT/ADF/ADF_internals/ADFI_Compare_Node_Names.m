function [names_match,error_return] = ADFI_Compare_Node_Names(name,new_name,D);
%
% [names_match,error_return] = ADFI_Compare_Node_Names(name,new_name,D)
%
% Compares node names
% names_match - 0 is names do NOT match, else 1
% error_returnn - Error return
% name - existing node name
% new_name - new node name
% D - Declaration space
%
% Possible errors:
% NO_ERROR, NULL_STRING_POINTER, NULL_POINTER

error_return = -1;
names_match = 0; % default to NO match

new_length = length(new_name);

for i = 1:min(new_length,D.ADF_Name_Length)
	if name(i) ~= new_name(i)
		names_match = 0;
		return
	end
end

% Names matched for the length of the new name.
% The existing name must only contain blanks from here

for i = i+1:D.ADF_Name_Length
	if name(i) ~= ' '
		names_match = 0; % Not blank, NO match, get out
		return
	end
end

names_match = 1;  % Yup, they match