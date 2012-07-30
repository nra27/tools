function [D,error_string] = ADF_Error_Message(error_code,D);
%
% error_string = ADF_Error_Message(error_code)
% Get a Description of the Error
% See ADF_USERGUIDE.pdf for details

% Check Error_Code and return relevant string
if error_code == 1
    error_string = 'Integer number is less than a given minimum value';
elseif error_code == 2
    error_string = 'Integer value is greater than given maximum';
elseif error_code == 3
    error_string = 'String length of zero or blank string detected';
elseif error_code == 4
    error_string = 'String length longer than maximum allowable length';
elseif error_code == 5
    error_string = 'String length is not an ASCII-Hex string';
elseif error_code == 6
    error_string = 'Too many ADF files opened';
elseif error_code == 7
    error_string = 'ADF file status was not recognized';
elseif error_code == 8
    error_string = 'ADF file open error';
elseif error_code == 9
    error_string = 'ADF file not currently opened';
elseif error_code == 10
    error_string = 'ADF file index out of legal range';
elseif error_code == 11
    error_string = 'Block/offset out of legal range';
elseif error_code == 12
    error_string = 'A string pointer is null';
elseif error_code == 13
    error_string = 'FSEEK error';
elseif error_code == 14
    error_string = 'FWRITE error';
elseif error_code == 15
    error_string = 'FREAD error';
elseif error_code == 16
    error_string = 'Internal error: Memory boundary tag bad';
elseif error_code == 17
    error_string = 'Internal error: Disk boundary tag bad';
elseif error_code == 18
    error_string = 'File Open Error: NEW - File already exists';
elseif error_code == 19
    error_string = 'ADF file format was not recognized';
elseif error_code == 20
    error_string = 'Attempt to free the RootNode disk information';
elseif error_code == 21
    error_string = 'Attempt to free the FreeChunkTable disk information';
elseif error_code == 22
    error_string = 'File Open Error: OLD - File does not exist';
elseif error_code == 23
    error_string = 'Entered area of unimplemented code';
elseif error_code == 24
    error_string = 'Subnode entries are bad';
elseif error_code == 25
    error_string = 'Memory allocation failed';
elseif error_code == 26
    error_string = 'Duplicate child name under a parent node';
elseif error_code == 27
    error_string = 'Node has no dimensions';
elseif error_code == 28
    error_string = 'Node''s dimensions are not in legal range';
elseif error_code == 29
    error_string = 'Specified child is not a child of the specified parent';
elseif error_code == 30
    error_string = 'Data-Type is too long';
elseif error_code == 31
    error_string = 'Invalid Data-Type';
elseif error_code == 32
    error_string = 'A pointer is null';
elseif error_code == 33
    error_string = 'Node has no data associated with it';
elseif error_code == 34
    error_string = 'Error zeroing out of memory';
elseif error_code == 35
    error_string = 'Requested data exceeds actual data available';
elseif error_code == 36
    error_string = 'Bad end value';
elseif error_code == 37
    error_string = 'Bad stride values';
elseif error_code == 38
    error_string = 'Minimum value is greater than maximum value';
elseif error_code == 39
    error_string = 'The format of this machine does not match a know signature';
elseif error_code == 40
    error_string = 'Cannot convert to or from an unknown native format';
elseif error_code == 41
    error_string = 'The two conversion formats are equal; no conversion done';
elseif error_code == 42
    error_string = 'The data format is not supported on a particular machine';
elseif error_code == 43
    error_string = 'File close error';
elseif error_code == 44
    error_string = 'Numeric overflow/underflow in data conversion';
elseif error_code == 45
    error_string = 'Bad start value';
elseif error_code == 46
    error_string = 'A value of zero is not allowable';
elseif error_code == 47
    error_string = 'Bad dimension value';
elseif error_code == 48
    error_string = 'Error state must be either a 0 (zero) or a 1 (one)';
elseif error_code == 49
    error_string = 'Dimensional specifications for the disk and memory are unequal';
elseif error_code == 50
    error_string = 'Too many link levels are used; may be caused by a recursive link';
elseif error_code == 51
    error_string = 'The node is not a link.  It was expected to be a link';
elseif error_code == 52
    error_string = 'The linked-to node does not exist';
elseif error_code == 53
    error_string = 'The ADF file of a linked node is not accessible';
elseif error_code == 54
    error_string = 'A node ID of 0.0 is not valid';
elseif error_code == 55
    error_string = 'Incomplete data when reading multiple data blocks';
elseif error_code == 56
    error_string = 'Node name contains invalid charaters';
elseif error_code == 57
    error_string = 'ADF file version incompatible with this library version';
elseif error_code == 58
    error_string = 'Nodes are not from the same file';
elseif error_code == 59
    error_string = 'Priority stack error';
elseif error_code == 60
    error_string = 'Machine format and file format are incomplete';
elseif error_code == 61
    error_string = 'Flush error';
elseif error_code == 62
    error_string = 'File open error';
else
    error_string = 'Unknown error #nnn';
end