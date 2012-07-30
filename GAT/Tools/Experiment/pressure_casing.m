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
     9.3244E-8
     10.0522E-8
     8.8979E-8
     9.5337E-8
     11.4869E-8
     0
     10.9884E-8
     8.9353E-8
     9.9108E-8];
 
 % compare raw data with data compensated for g
  
 for gauge=1:length(kulites)
    press(:,gauge)=(FData(:,gauge)-mean(FData(1:1000,gauge)))/p(kulites(gauge))/gain+0.5*6.895E3;
    figure(gauge)
    plot(FTime,press(:,gauge),'k')
    axis([-0.3 0.15 0 7E5])
    xlabel('Time (s)')
    ylabel('Pressure (Pa)')
    grid   
 end
 
eval(['pressC' run_number '=press;']);
eval(['save pressC' run_number ' pressC' run_number ' FTime']);
 