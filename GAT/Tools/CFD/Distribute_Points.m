function dist = Distribute_Points(n_points);
%
% dist = Distribute_Points(n_points)
% A function to distribute n_points using double clustering

x1 = linspace(0,0.5^(1/3),floor(n_points/2));
x2 = linspace(-0.5^(1/3),0,floor(n_points/2));

dist1 = x1.^3-0.5;
dist2 = x2.^3+0.5;

dist = [dist1(1:end-1) dist2]+0.5;
