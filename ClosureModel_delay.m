%
% Function to implement a delayed unity step
%
% function [output] = ClosureModel_delay(input,delay);
%
% delay is in samples

function [output] = ClosureModel_delay(input,delay);

% initialise the vector
step = zeros(1,length(input));

% add the step funciton with the delay
step(delay:end) = 1;

output = input.*step;


