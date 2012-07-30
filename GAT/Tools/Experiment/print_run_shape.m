function print_run_shape;

directory = pwd;
run_number = directory(end-3:end);

% Load eu file
eval(['load r' num2str(run_number) 'eu.mat']);

% Load fast data
eval(['load r' num2str(run_number) 'b.mat']);

time = eu.time.t;

r=1.34;
T00=eu.data{56};
To=mean(T00(1:50));
Pbar=eu.data{61};
Pbaro=mean(Pbar(1:50));
T01=To*(Pbar/Pbaro).^(1-1/r);

AGV = FData([1:100:end],8);
AGV = [ones(3450,1)*AGV(1); AGV; ones(4300,1)*AGV(end)];

speed = eu.data{57};

P01 = eu.data{62};

T01 = decimate(T01,2,'FIR');
Pbar = decimate(Pbar,2,'FIR');
AGV = decimate(AGV,2,'FIR');
speed = decimate(speed,2,'FIR');
P01 = decimate(P01,2,'FIR');
time = decimate(time,2);

Pbar = Pbar/1E5;
P01 = P01/1E5;
AGV = (AGV-AGV(end))*1.5+0.05;


figure
subplot(3,1,1)

plot(time,AGV,'k')
hold on
plot(time,Pbar,'r')
plot(time,P01,'b')
grid on

subplot(3,1,2)
plot(time,T01)
grid on

subplot(3,1,3)
plot(time,speed)
grid on