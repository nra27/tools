%{
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    Cavity Calibration                 %
%                         v1.1                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Author: nra27                     %
%                   Last mod: 23/3/2011, sss44          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      Input: block structure (b)       %
%                     Output: block structure (b)       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                           __/\__
                          `==/\==`
                ____________/__\____________
               /____________________________\
                 __||__||__/.--.\__||__||__
                /__|___|___( >< )___|___|__\
                          _/`--`\_
                         (/------\)

version hist:
ver 1.1 - loops through points in px_x and px_r in b and creates x and r which
are the correct coordinates.


%} 

%%
function [b]=cavity_calibration(b)
%%
rx_690 = 1e2*[7.786277749482853 8.949332449824913];
rx_930 = 1e2*[1.354124760628758  0.939761505420214];

m = 240/(rx_930(:,2)-rx_690(:,2));
a = rx_930(:,2)*240/(rx_930(:,2)-rx_690(:,2));
c = (930 - a);
 
 %%
for i=1:length(b)
     b(i).r = (b(i).px_r(:).*m+c)./1000; 
     b(i).x = ((b(i).px_x(:).*-1.*m)-329.6072.*-1.*m)./1000;
end
end