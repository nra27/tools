function k = Kulite_Set(run_number);

eval(['load r' num2str(run_number) 'eu.mat']);
eval(['load Good_Channels_' num2str(run_number) '.mat']);

Gauges = [];

n = length(Channels.Co);
Gauges(end+1:end+n) = Channels.Co;

n = length(Channels.Ci);
Gauges(end+1:end+n) = Channels.Ci;

n = length(Channels.Fo);
Gauges(end+1:end+n) = Channels.Fo;

n = length(Channels.Fi);
Gauges(end+1:end+n) = Channels.Fi;

n = length(Channels.Jo);
Gauges(end+1:end+n) = Channels.Jo;

n = length(Channels.Ji);
Gauges(end+1:end+n) = Channels.Ji;

n = length(Channels.Mo);
Gauges(end+1:end+n) = Channels.Mo;

n = length(Channels.Mi);
Gauges(end+1:end+n) = Channels.Mi;

STime = eu.time.t;
for i = 1:64
SData(:,i) = eu.data{i};
end

Gauges = sort(Gauges);

clear eu 

Pstart = mean(SData(1:1000,Gauges),1);
Pend = mean(SData((end-999:end),Gauges),1);

delta_P = mean(Pend-Pstart);
clear SData STime

eval(['load r' num2str(run_number) 'c.mat']);

Vstart = mean(FData(1:1000,:),1);
Vend = mean(FData((end-99:end),:),1);

k = ((Vend-Vstart)/10)/delta_P;