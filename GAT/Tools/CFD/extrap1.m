function YI = extrap1(X,Y,XI,N);
%
% YI = extrap1(X,Y,YI,N)
%
% extrap1: a function very similar to interp1, but with capabilities to work outside of the data.
% Fits a N-degree polynomial to the data and then calculates the required value.

[P,S,Mu] = polyfit(X,Y,N);
YI = polyval(P,XI,S,Mu);