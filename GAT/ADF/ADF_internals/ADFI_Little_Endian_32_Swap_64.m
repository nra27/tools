function [D,to_data,error_return] = ADFI_Little_Endian_32_Swap_64(from_format,from_os_size,to_format,to_os_size,data_type,delta_from_bytes,delta_to_bytes,from_data,D);
%
% [D,to_data,error_return] = ADFI_Little_Endian_32_Swap_64(from_format,from_os_size,to_format,to_os_size,data_type,delta_from_bytes,delta_to_bytes,from_data,D)
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
% Machine Numeric Formats:
% ***IEEE_BIG (SGI-Iris Assembly Language Programmer's Guide, pages 1-2, 6-3)
% I4:	Byte0	Byte1	Byte2	Byte3
%	    MSB---------------------LSB
% R4:	Byte0	Byte1	Byte2	Byte3
%    Bits: sign-bit, 8-bit exponent, 23-bit mantissa
%    The sign of the exponent is:  1=positive, 0=negative (NOT 2's complement)
%    The interpreation of the floating-point number is:
%	>>> 2.mantissia(fraction) X 2^exponent. <<<
%
% R8:	Byte0	Byte1	Byte2	Byte 3	Byte 4	Byte5	Byte6	Byte7
%    Bits: sign-bit, 11-bit exponent, 52-bit mantissa
%
% Machine Numeric Formats:
% ***IEEE_LITTLE ( The backwards Big Endian )
% I4:	Byte0	Byte1	Byte2	Byte3
%	    LSB---------------------MSB
% R4:	Byte0	Byte1	Byte2	Byte3
%    Bits: 23-bit mantissa, 8-bit exponent, sign-bit
%    The sign of the exponent is:  1=positive, 0=negative (NOT 2's complement)
%    The interpreation of the floating-point number is:
%	>>> 2.mantissia(fraction) X 2^exponent. <<<
%
% R8:	Byte0	Byte1	Byte2	Byte 3	Byte 4	Byte5	Byte6	Byte7
%    Bits:  52-bit mantissa, 11-bit exponent, sign-bit
%
% Note: To convert between these two formats the order of the bytes is reversed
% since by definition the Big endian starts at the LSB and goes to the MSB where
% the little goes form the MSB to the LSB of the word.
% ***
%
% Posible errors:
% NO_ERROR, NULL_STRING_POINTER, NULL_POINTER

if delta_from_bytes == 0 | delta_to_bytes == 0
    error_return = 32;
    return
end

if strcmp(from_format,'N') | strcmp(to_format,'N')
    error_return = 40;
    return
end

error_return = -1;

if delta_to_bytes == delta_from_bytes
    to_data(1:delta_to_bytes) = from_data(1:delta_from_bytes);
elseif delta_from_bytes < delta_to_bytes
    switch data_type
        case 'I8'
            if bitand(double(from_data(4)),128) == 128 % 2s complement negative
                to_data(5:8) = char(255);
            else
                to_data(5:8) = char(0);
            end
            to_data(1:4) = from_data(1:4);
        otherwise
            error_return = 31;
            return
    end
else
    switch data_type
        case 'I8'
            to_data(1:4) = from_data(1:4);
        otherwise
            error_return = 31;
            return
    end
end