function Phase_average

% Small script to give the phase averaged 2run data, and also to
% peak search and set to point 1.


% HT data
load rawQdot_2rev

base = [1:144]/144;
qdot = zeros(144,16);

for i = 0:119
    qdot = qdot+interp1(line1_pass,line1_qdot,base+i,'spline');
end

qdot = qdot/120;

save phaseavv_qdot base qdot opt Tw