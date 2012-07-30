function out = phase_shift(in,delta);
%
% out = phase_shift(in,delta)
%
% Phase_Shift: a function to shift a vector by given increments.
% eg.
% In = [0 1 2 3 4 5 6 7 8 9]
% Delta =  2 ==> Out = [8 9 0 1 2 3 4 5 6 7]
% Delta = -2 ==> Out = [2 3 4 5 6 7 8 9 0 1]

out = 0*in;
len = length(in);

% Check to see if delta is greater that the length of the vector
if delta == len
	return
elseif abs(delta) > len
	delta = round((delta/len-round(delta/len))*len);
end

if delta >= 0
	out(1:delta) = in(end-delta+1:end);
	out(delta+1:end) = in(1:end-delta);
else
	out(1:end+delta) = in(-delta+1:end);
	out(end+delta+1:end) = in(1:-delta);
end