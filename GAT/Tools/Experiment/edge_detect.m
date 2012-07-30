function e = edge_detect(s);
%
% positive_edges = edge_detect(vector)
%
% A routine to extract the position of the positive
% going edges from a speed-encoder signal.
%
% Define a positive going edge at t(n) as a point
% where s(n)<=0 and s(n+1)>0

s_1 = [s(2:end) ; s(end)];

e = (s<=0 & s_1>0);