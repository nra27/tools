% Function to calculate the time constant of a first order response
%
% function [t_tau,value] = TimeConstant(t_vect,data,before,after,type)
%
% t_vect    - time vector - unspecified units
% data      - points
% before    - last time point before the change (must be in the same units as t_vect)
% after     - time point after the change (must be in the same units as t_vect)
% 'type'    - either 'rising' or 'falling'
%
%
% NRA Oct 08
%

function [t_tau,value] = FindTimeConstant(t_vect,data,before,after,type)

p1 = max(find(t_vect <= before));
p2 = max(find(t_vect <= after));

tmp = RemoveRepeats(data);

if strcmp(type,'rising'),
    value = data(p1)+(1-exp(-1))*(data(p2)-data(p1));
else value = data(p1)-(1-exp(-1))*(data(p1)-data(p2)); 
end

   
t_tau = interp1(tmp(p1:p2),t_vect(p1:p2),value) - before;

