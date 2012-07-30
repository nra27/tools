function order = Make_Chain(x_coords,y_coords,z_coords);
%
% order = Make_Chain(x_coords,y_coords,z_coords,i)
% A function to sort a given set of points such that each
% point is preceded and followed by the points closest to it.
% The first point is taken to that with the lowest value of y.

x_coords = x_coords;
y_coords = y_coords;
z_coords = z_coords;

[y_min,i] = min(y_coords);
order = y_coords.*0;
order(1) = i;

for i = 1:length(x_coords)-1
    x_val = x_coords(order(i));
    y_val = y_coords(order(i));
    z_val = z_coords(order(i));
    
    x_coords(order(i)) = 100000000;
    y_coords(order(i)) = 100000000;
    z_coords(order(i)) = 100000000;
    
    x_dist = x_coords-x_val;
    y_dist = y_coords-y_val;
    z_dist = z_coords-z_val;
    
    dist = sqrt(x_dist.^2+y_dist.^2+z_dist.^2);
    [d_min,order(i+1)] = min(dist);
end   