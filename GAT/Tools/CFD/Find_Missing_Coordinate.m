function z = Find_Missing_Coordinate(x,y,X,Y,Z);
%
% z = Find_Missing_Coordinate(x,y,X,Y,Z)
%
% A function to return the third coordinate from a 
% surface, when two are specified.  The surface must
% be monotonic in the missing dimension.  This is not
% checked.

error_sum = sqrt((X-x).^2+(Y-y).^2);

[value,index] = min(error_sum);

z = Z(index);