function out = NGV_Phase_Avverage(in,t_vec);
%
% out = NGV_Phase_Avverage(in,t_vec)
%
% NGV_Phase_Avverage
%
% This is a script designed to take the time history from
% the 7x8xn array of casing gauges signals for one blade
% passing event and collapse them into a 1x8 array.
%
% in - a 7x8xn array of the time histories.
% t_vec - the 1xn time vector
% out - a 8xn array of the collapsed time histories.

% Set up variables
n_samp = length(t_vec);			% Number of points in the time history
delta_t = mean(diff(t_vec));	% Mean time step
delta_theta = 6/(n_samp+1);		% The angle increment each time step
speed = delta_theta/delta_t;	% Mean rotor speed
t_shift = 5/3/speed;			% Time shift required between gauge rows

% Determine the best up-sampling factor
factor = primes(100);			% Use primes for up-sampling
residual = abs(t_shift.*factor./delta_t-round(t_shift.*factor./delta_t));
[y,i] = min(residual);
clear y;
delta = round(t_shift*factor(i)/delta_t);

% Up-sample the data using the best up-sampling factor
t_vec_interp = [t_vec-t_vec(end)-delta_t t_vec t_vec+t_vec(end)+1];
t_vec_new = [t_vec(1):delta_t/factor(i):t_vec(end)+delta_t-delta_t/factor(i)];

% Set up matrices
row_shift = zeros(7,n_samp*factor(i));
out = zeros(8,n_samp);
for row = 1:8	% For each circumferential row
	gauges = squeeze(in(:,row,:));	% Extract line signal
	gauges_interp = [gauges gauges gauges];
	gauges_new = interp1(t_vec_interp,gauges_interp',t_vec_new,'spline')';	% Up-sample
	for line = 1:7	% For each gauge line
		% Phase shift each gauge, using line 7 as the base (t=0)
		row_shift(line,:) = phase_shift(gauges_new(line,:),(line-7)*delta);
	end
	row_mean = mean(row_shift,1);	% Calculate mean over lines
	out(row,:) = row_mean([1:factor(i):n_samp*factor(i)]);
end