function [k,mu] = Sutherlands_air(T) 
%
% Hard coded for Prandtl 0.7 and Cp 1005 J kg^-1 K^-1
%
% [k,mu] = Sutherlands_air(T) 
%
% NRA November 2008

mu = 1.458e-6*(T.^(1.5))./(110.4+T);
k = mu*1005/0.7;