function [D,to_data,error_return] = ADFI_Little_Endian_to_Cray(from_format,from_os_size,to_format,to_os_size,data_type,delta_from_bytes,delta_to_bytes,from_data,D);
%
% [D,to_data,error_return] = ADFI_Little_Endian_to_Cray(from_format,from_os_size,to_format,to_os_size,data_type,delta_from_bytes,delta_to_bytes,from_data,D)
%
% D - Delcaration space
% to_data - The converted data
% error_return - Error return
% from_format - Format to convert from. 'B', 'L', 'C', 'N'
% from_os_size - OS to convert from. 'B', 'L'
% to_format - Format to convet to.
% to_os_size - OS to convert to.
% data_type - The type of data to convert
%               MT I4 I8 U4 U8 R4 R8 X4 X8 C1 B1
% delta_from_bytes - Number of bytes used
% delta_to_bytes - Number of bytes used
% from_data - The data to convert
%
%  Recognized data types:
%					Machine representations
%        Type		  Notation     IEEE_BIG	  IEEE_LITTLE   Cray
%	                               32    64   32    64
%  No data                   MT
%  Integer 32                I4         I4    I4    I4   I4       I8
%  Integer 64                I8         --    I8    --   I8       I8
%  Unsigned 32               U4         I4    I4    I4   I4       I8
%  Unsigned 64               U8         --    I8    --   I8       I8
%  Real 32                   R4         R4    R4    R4   R4       R8
%  Real 64                   R8         R8    R8    R8   R8       R8
%  Complex 64                X4         R4R4  R4R4  R4R4 R4R4     R8R8
%  Complex 128               X8         R8R8  R8R8  R8R8 R8R8     R8R8
%  Character (unsigned byte) C1         C1    C1    C1   C1       C1
%  Byte (unsigned byte)      B1         C1    C1    C1   C1       C1
%
%Machine Numeric Formats:
%***IEEE_BIG (SGI-Iris Assembly Language Programmer's Guide, pages 1-2, 6-3)
% I4:	Byte0	Byte1	Byte2	Byte3
%   	MSB---------------------LSB
% R4:	Byte0	Byte1	Byte2	Byte3
%    Bits: sign-bit, 8-bit exponent, 23-bit mantissa
%    The sign of the exponent is:  1=positive, 0=negative (NOT 2's complement)
%    The interpreation of the floating-point number is:
%	>>> 2.mantissia(fraction) X 2^exponent. <<<
%
% R8:	Byte0	Byte1	Byte2	Byte 3	Byte 4	Byte5	Byte6	Byte7
%    Bits: sign-bit, 11-bit exponent, 52-bit mantissa
%
% ***Cray (Cray CFT77 Reference Manual, pages G-1 G-2)
% I8:	Byte0	Byte1	Byte2	Byte 3	Byte 4	Byte5	Byte6	Byte7
%       MSB-----------------------------------------------------LSB
% R8:	Byte0	Byte1	Byte2	Byte 3	Byte 4	Byte5	Byte6	Byte7
%    Bits: sign-bit, exponent-sign, 14-bit exponent, 48-bit mantissa
% Note: Exponent sign:  1 in this bits indicates a positive exponent sign,
%   thus bit 62 is the inverse of bit 61 (the sign in the exponent).
%   The exception to this is a zero, in which all 64 bits are zero!
%    The interpreation of the floating-point number is:
%	>>> .mantissia(fraction) X 2^exponent. <<<
%   The mantissia is left justified (the leftmost bit is a 1).
%     This MUST be done!
%
% Posible errors:
% NO_ERROR, NULL_STRING_POINTER, NULL_POINTER

if strcmp(from_format,'N') | strcmp(to_format,'N')
    error_return = 40;
    return
end

error_return = -1;

switch data_type
    case 'MT'
        error_return = 33;
        return
        
    case {'C1' 'B1'}
        to_data(1) = from_data(1);
        
    case 'I4'
        if bitand(double(from_data(4)),128) == 128 % 2s complement negative
            to_data(1:4) = char(255);
        else
            to_data(1:4) = char(0);
        end
        to_data(5:8) = fliplr(from_data(1:4));
        
    case 'U4'
        to_data(1:4) = char(0);
        to_data(5:8) = fliplr(from_data(1:4));
        
    case 'I8'
        if bitand(double(from_data(4)),128) == 128 % 2s complement negative
            to_data(1:4) = char(255);
        else
            to_data(1:4) = char(0);
        end
        for i = 1:delta_from_bytes
            to_data(9-delta_from_bytes+i) = from_data(delta_from_bytes-i);
        end
        
    case 'U8'
        to_data(1:4) = char(0);
        for i = 1:delta_from_bytes
            to_data(9-delta_from_bytes+i) = from_data(delta_from_bytes-i);
        end
        
    case 'R4'
        to_data(1:8) = char(0);
            
        % Check for zero: a special case on the Cray (exponent sign)
        if strcmp(from_data(1:4),[char(0) char(0) char(0) char(0)])
            return
        end
           
        % Convert the sign
        to_data(1) = bitand(double(from_data(4)),128)
         
        % Convert the exponent
        % 8 bits to 14 bits.  Sign extent from 8 to 14
        % Cray exponent is 2 greater than the Iris
        exp = bitshift(bitand(double(from_data(4)),63),1);
          
        if bitand(double(from_data(3),128)) == 128 % Set sign
            exp = exp + 1;
        end
        if bitand(double(from_data(4),64)) == 0
            exp = exp - 128;
        end
        exp = exp + 2;
        
        to_data(2) = bitand(exp,255);
        if exp < 0
            to_data(1) = bitor(to_data(1),60); % exponent sign 0, sign extend exponent
        else
            to_data(1) = bitor(to_data(1),64); % exponent sign 1
        end
        
        % Convert the mantissia
        % 23 bits to 48 bits.  Use 48, drop last 4 bits
        to_data(3) = bitor(double(from_data(3)),128);
        to_data(4) = from_data(2);
        to_data(5) = from_data(1);
        
    case 'R8'
        to_data(1:8) = char(0);
            
        % Check for zero: a special case on the Cray (exponent sign)
        if strcmp(from_data(5:8),[char(0) char(0) char(0) char(0)])
            return
        end
           
        % Convert the sign
        to_data(1) = bitand(double(from_data(8)),128)
         
        % Convert the exponent
        % 11 bits to 14 bits.  Sign extent from 11 to 14
        % Cray exponent is 2 greater than the Iris
        exp = bitshift(bitand(double(from_data(8)),63),4)+bitand(bitshift(double(from_data(7)),-4),15);
          
        if bitand(double(from_data(8),16)) == 0 % Set sign
            exp = exp - 1024;
        end
        exp = exp + 2;
        
        to_data(2) = bitand(exp,255);
        to_data(1) = bitor(to_data(1),bitand(bitshift(exp,-8),3));
        if exp < 0
            to_data(1) = bitor(to_data(1),60); % exponent sign 0, sign extend exponent
        else
            to_data(1) = bitor(to_data(1),64); % exponent sign 1
        end
        
        % Convert the mantissia
        % 52 bits to 48 bits.  Use 48, drop last 4 bits
        to_data(3) = bitor(bitor(bitand(bitshift(from_data(7),3),120),bitand(bitshift(from_data(6),-5),7)),128);
        for i = 4:8
            to_data(i) = bitor(bitand(bitshift(from_data(9-i),3),248),bitand(bitshift(from_data(8-i),-5),7));
        end
        
    case 'X4'
        [D,to_data,error_return] = ADFI_Little_Endian_to_Cray(from_format,from_os_size,to_format,to_os_size,'R4',delta_from_bytes,delta_to_bytes,from_data,D);
        if error_return ~= -1
            return
        end
        
        [D,to_data(9:16),error_return] = ADFI_Little_Endian_to_Cray(from_format,from_os_size,to_format,to_os_size,'R4',delta_from_bytes,delta_to_bytes,from_data(5:8),D);
        if error_return ~= -1
            return
        end
        
    case 'X8'
        [D,to_data,error_return] = ADFI_Little_Endian_to_Cray(from_format,from_os_size,to_format,to_os_size,'R8',delta_from_bytes,delta_to_bytes,from_data,D);
        if error_return ~= -1
            return
        end
        
        [D,to_data(9:16),error_return] = ADFI_Little_Endian_to_Cray(from_format,from_os_size,to_format,to_os_size,'R8',delta_from_bytes,delta_to_bytes,from_data(9:16),D);
        if error_return ~= -1
            return
        end
        
    otherwise
        error_return = 31;
        return
end
