






%
% Filtering the CFD data
% 



% reshape the data into the virtual gauges

[n,m,t] = size(mov_PLAIN.q);

for i = 1:t,  
q(i,:) = reshape(mov_PLAIN.q(:,:,i),n*m,1);
end



% reshape the data into 56 virtual gauges by 100 time steps

[n,m,t] = size(mov.q);

% Filter the time histories
fs = 933/(2*pi)*60*144;
fcut = 50e3;
wn = fcut/(fs/2);
[B,A] = butter(1,wn);

n = 1;
for j = 1:7,
    for i = 1:8,
        for k = 1:100,
            % virtual time history for each gauge, 
            count = 101 - k;
            t_hist(count) = mov.q(i,j,k);
        end
        
        % Upsample to get 144 points in 6 degrees
        t_hist_144 = resample(t_hist,144,20);
        q_filt = filter(B,A,t_hist_144);
                  
        % Ensemble average
        five_pass = reshape(t_hist_144,144,5);
        five_pass_filt = reshape(q_filt,144,5);
        q_144_filt(:,n) = mean(five_pass_filt');
        q_144(:,n) = mean(five_pass');
        n = n+1;
    end

    % something slightly wrong with the angle definition!
    
end

Q_CFD = Upsample_Casing_Data(q_144);
Q_CFD_filt = Upsample_Casing_Data(q_144_filt);




% phase average each gauge

for k1:100,
    plotq_phase_average
plot