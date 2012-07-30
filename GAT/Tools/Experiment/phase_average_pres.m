function Phase_Average_Press

% Small script to give the phase averaged 2run data, and also to
% peak search and set to point 1.


% HT data
load rawPres_2rev

[len,gauges] = size(line1_pres);

base = [1:144]/144;
pres = zeros(144,gauges);

for i = 0:119
    pres = pres+interp1(line1_pass,line1_pres,base+i,'spline');
end

pres = pres/120;

save phaseavv_pres base pres opt