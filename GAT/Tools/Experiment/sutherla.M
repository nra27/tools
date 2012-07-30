function [mu, k] = sutherla(T);
% function [mu, k] = sutherla(T);   Viscosity and conductivity for air.
% T is Kelvin.   "type sutherla" for more details.
% RWM

% VISCOSITY:
% Original version of Sutherland's law:
% This uses the definition of viscosity in Schlichting p 328:
% mu/mu0 = (T/T0)^1.5 * (T0+S1)/(T+S1)
% which appears to fit well over 100<T<2000K (though absolute
% accuracy at, say, 340 K not specified).
% These values are about 4% less than those from comv.
% S1 = 110;  T0 = 492/1.8;
% mu0 = 0.35e-6 * 4.448/(0.3048 * 0.3048);
% mu = ((T0+S1)*mu0/(T0^1.5))*(T.^1.5)./(S1+T);

% RWM version 12/7/94: use fit.m to get Sutherlands law coefficients
% for Schlicting table 12.1 viscosities; gives better agreement
% over range 223:573 K (see my notebook 10). Using Schlichting as this gives 
% 3 sig fig; HLT is only 2sf.
% Valid 200:1100K, and spot-on for 270:470K.
mu = 1.4915e-006*sqrt(T)./(1+118.98./T);

% CONDUCTIVITY:
% Use curve fit to HLT and RR data: typically fits data to 0.3% or so
% at 250:570 K, and valid up to 2500 K.
k = polyval([-3.6509e-15 3.1971e-11 -7.5043e-8 1.1738e-4 -.0031126],T);

% for mu at higher temperatures, or FAR~=0, see comv.m and my HP42S file.
