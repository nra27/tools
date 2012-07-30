% Establish directory
directory = pwd;
run_number = directory(end-3:end);

% Load data
eval(['load r' run_number 'b']);
eval(['load r' run_number 'c']);
eval(['load KU_DATA_' run_number]);

%calibration factor
  %Pressure sensitivity (V/Pa)
 p=[9.9895E-8
     9.3359E-8
     10.0327E-8
     8.8979E-8
     9.1711E-8
     11.7127E-8
     0
     11.1056E-8
     8.9353E-8
     10.2171E-8];
 
 % compare raw data with data compensated for g
 close all
 
 for gauge=1:length(kulites)
    press(:,gauge)=((FData(:,gauge)-mean(FData(1:1000,gauge))).*FData(:,end)/5)/p(kulites(gauge))/gain+0.5*6.895E3;
    figure(gauge)
    plot(FTime,press(:,gauge),'k')
    axis([-0.3 0.15 0 7E5])
    xlabel('Time (s)')
    ylabel('Pressure (Pa)')
    grid   
 end
 
 drawnow
 pause(1)
 
eval(['pressC' run_number '=press;']);
eval(['save pressC' run_number ' pressC' run_number ' FTime']);
 