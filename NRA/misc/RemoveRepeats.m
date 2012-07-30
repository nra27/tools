%
% Remove repeated data points from a vector ready for interp1
%
% data_out = RemoveRepeats(data)
%
% 

function data_out = RemoveRepeats(data)

reps = [];
for i=1:length(data)-1,
    if data(i)==data(i+1), 
        reps = [reps i];
    else
    end
end

data(reps) = data(reps)+1e-6;

data_out = data;