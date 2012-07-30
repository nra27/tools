% Establish directory
directory = pwd;
run_number = directory(end-3:end);

% Load data
eval(['load r' run_number 'c']);
FData_c = FData;
eval(['load r' run_number 'b']);
eval(['load HT_DATA_' run_number]);

% inverse Laplace transformatin of inshaft electronics circuit

R1=[228.94 198.03 193.24 195.31 185.10 195.44 198.68 215.16...
       191.07 198.77 192.79 195.05 198.66 195.48 192.98 184.83];
R2=[1881 1937 1900 1895 1806 1826 1906 1889 1870 1898 1836 1890 1904 1897 1880 1797];
R3=[2262 2316 2260 2259 2157 2174 2274 2253 2232 2267 2202 2253 2272 2259 2246 2158]*10;
R4=[10068 10446 10227 10177 9726 9786 10265 10084 10092 10212 9915 10103 10223 10147 10103 9685]*10;
C2=[52.31 41.53 43.00 45.34 45.09 46.13 47.55 49.19 44.97 46.04 46.20 43.86 43.05 43.88 43.80 45.35]*1.0E-9;
C3=[511.85 427.63 437.62 500.76 512.92 513.91 490.73 493.68...
      504.58 432.18 509.94 432.13 435.40 426.50 426.44 529.95]*1.0E-9;

for gauge=1:16;
   gauge
   
a=R1(gauge)+R4(gauge); b=R1(gauge); m1=R3(gauge); m2=R3(gauge)*C3(gauge); m3=R2(gauge); m4=R2(gauge)*C2(gauge);

%R1=200;
%R2=1800;
%R3=22000;
%R4=100000;
%C2=47.0E-9;
%C3=470.0E-9;
%a=R1+R4; b=R1; m1=R3; m2=R3*C3; m3=R2; m4=R2*C2;

a1=a*m2*m4;
b1=a*m2+a*m4+m1*m4+m2*m3;
c1=a+m1+m3;
a2=b*m2*m4;
b2=b*m2+b*m4+m1*m4+m2*m3;
c2=b+m1+m3;

%solve the equation of the numerator of B(s)
Judge1=b1^2-4*a1*c1;

A=a2/a1;
B=(b2-a2/a1*b1)/a1;
C=(c2-a2/a1*c1)/a1;
alpha1=(-b1+sqrt(Judge1))/2/a1;
alpha2=(-b1-sqrt(Judge1))/2/a1;
difference=sqrt(Judge1)/a1;

%solve the equation of the demominator of B(s)
Judge2=b2^2-4*a2*c2;

alpha3=(-b2+sqrt(Judge2))/2/a2;
alpha4=(-b2-sqrt(Judge2))/2/a2;

%4 breakpoints

f1=-alpha1/2/pi;
f2=-alpha3/2/pi;
f3=-alpha2/2/pi;
f4=-alpha4/2/pi;



   %Caliculation of Inshaft electronics output(transfer function see Vol.3 P73)
w1=-alpha1;  %see note
w2=-alpha3;  %see note
w3=-alpha2;  %see note
w4=-alpha4;  %see note
A=(w1-w2)*(w2-w3)/(w2-w4);  %see note P73 Vol.3
B=(w1-w4)*(w3-w4)/(w2-w4);  %see note P73 Vol.3
C=(w1-w4)*(w2-w1)/(w1-w3);  %see note P157 Vol.3
D=(w3-w4)*(w3-w2)/(w1-w3);  %see note P157 Vol.3
M1=(R1+R2+R3+R4)/(R1+R2+R3)*w2*w4/w1/w3;
M2=1/M1;

%**** Gain **************************************
%ome=[5:10:1000000];
%gain=abs(1+A./(j*ome+w2)+B./(j*ome+w4))*(R1+R2+R3+R4)/(R1+R2+R3)*w2*w4/w1/w3;
%freq=ome/2/pi;
%figure(1)
%plot(freq,gain)
%loglog(freq,gain)
%grid
%hold off
%******************************************

%%%%% Phase %%%%%%%%%%%%%%
%phase=angle((1+A./(j*ome+w2)+B./(j*ome+w4))*(R1+R2+R3+R4)/(R1+R2+R3)*w2*w4/w1/w3);
%figure(2)
%semilogx(freq,phase/pi*180)
%grid
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%tau=1/FastEvents(6); %sampling interval
%m=length(tvec);
%tvec=([1:m]*tau).';
%K=A*exp(-w2*tvec)+B*exp(-w4*tvec); %inverse transfer function
%K=[K;zeros(size(K))];  %zero padding
%data=[data;zeros(size(data))]; %zero padding



%%%%%% Inshaft Electronics DC Output --> Gauge DC Voltage %%%%%%%
kk=gauge;   
data=FData_c(:,kk);
%figure(1)
%plot(data);
%x=ginput(1);
%st_pt=round(x(:,1));
%st_pt=1000;

%%% add signals(0.1 sec) before sampling in order to remove sudden change %%%   
   
    amp=mean(data(1:10000));
    data1=[amp*ones(60000,1);data];


%data1=data1/10; %divided by AC gain
tau=0.000002;  % sampling interval ex. 500kHz = 2E-6
%tau=0.000001; % sampling interval ex. 1000kHz = 1E-6
%tau=0.0000005; % sampling interval ex.2000kHz = 5E-7


m=length(data1);    % data length
%data1=[0;data1(2:m)];
tvec=([0:m-1]*tau)';
J=C*exp(-w1*tvec)+D*exp(-w3*tvec);
%J=[J;zeros(m,1)];
%data1=[data1;zeros(m,1)];

%FFT length
 n=2^19;  %2^19=524288, Use this when data number=200000(500kHz).
% n=2^20; %2^20=1048576, Use this when data number=400000(1000kHz).
% n=2^21; %2^21=2097152, Use this when data number=800000(2000kHz).
 
fftoutput=ifft(fft(J,n).*fft(data1,n));
%output=real(fftoutput(1:m))*tau; %FFT method
%output=(data1+output)*M2;        %FFT method

%modified FFT method (P126-127 Vol.4)
f=data1(1)*J(1:m)+J(1)*data1;
output=real(fftoutput(1:m)-f/2)*tau;
output=(data1+output)*M2;

eval(['DCout' run_number '(:,gauge)=output(60001:285001);']);

end

eval(['save DCout' run_number ' DCout' run_number ' name' run_number]);
      
%%%%% Mean Heat Transfer Calculation using DC Signal Data %%%%%%%%

 %determination of vo
 I0 = Vsense./Rsense;
 %vo=I0.*R20;

 %temperature coefficient of resistance (20C)
 %alpha = alpha/1000;
  
 %thermal product of MACOR
   density=2520; %%% property of MACOR, cited from the manufacturer
   spec_heat=790;
   ramda=1.5;
   rck=sqrt(density*spec_heat*ramda);
  
%%% calculation of heat transfer rates %%%
   
  %remove DC shift 
    %data=data-mean(data(1:20000));
   
  %%curve fitting
    %[b a]=butter(4,0.1);
    %fit1=filter(b,a,data);
    %figure(1)
    %plot(FTime,data);hold on;plot(FTime,fit1,'c')
    %%axis([-0.1 0.2 0 0.025]);
    %%title('Fitting Curve');
    %hold off
    %data=fit1;
    
  for gauge=1:16;
  gauge
  kk=gauge; % column number in the DC voltage file
  eval(['data=DCout' run_number '(:,kk);']);
  
  %calculation of resistance
  Res=data/I0(gauge);
  
  %calcuration of temperaure rise
  eval(['temp' run_number '(:,gauge)=(Res/R20(gauge)-1)/alpha(gauge)+20;']);
  
  %plot temperature rise
    %figure(gauge)
    %plot(FTime,temp7765(:,gauge));
    %title('Temperature Rise');
    %xlabel('Time(s)')
    %ylabel('temperature(K)')
    %grid
  
  %remove desitization error
  eval(['tempR=decimate(temp' run_number '(:,gauge),2000,''FIR'');']);  %reduce sampling rate 500kHz --> 250Hz
  timeR=decimate(FTime,2000,'FIR'); %reduce sampling rate 500kHz --> 250Hz
  timeR=[FTime(1);timeR(2:length(timeR)-1);FTime(length(FTime))]; %remove discrepancy   
  
  %plot temperature rise
    figure(gauge)
    hold on
    plot(timeR,tempR,'c');
    title('Temperature Rise');
    xlabel('Time(s)')
    ylabel('temperature(K)')
    grid
    hold off
    
  temp=interp1(timeR,tempR,FTime,'linear'); %restore original sampling rate
                                            %because of heat transfer calculation
  temp=temp-mean(temp(1:50));
  temp=[0;temp(2:length(temp))]; % for making the summation method easier
  
  %Calcuration of Qdot
      templen=length(temp);
      temp1=temp(1:templen-1);
      temp2=temp(2:templen);
      del_temp=(temp2-temp1);
      clear temp1 temp2
      
      tau=0.000002; %sampling rate 500kHz --> tau=2E-6(s) 
    %FFT length
       n=2^19;  %2^19=524288, Use this when data number=200000(500kHz).
       % n=2^20;%2^20=1048576, Use this when data number=400000(1000kHz).
  
      %del_T=temp(2:templen)-temp(1:templen-1);
      ti=[0:1:templen-2]'*tau;
      ti1=[1:1:templen-1]'*tau;
      fun=1./(sqrt(ti)+sqrt(ti1));
      qdot1=ifft(fft(del_temp,n).*fft(fun,n));
      qdot1=real(qdot1(1:templen-1))*rck/sqrt(pi)*2;
      qdot1=[0;qdot1];
      eval(['meanHTR' run_number '(:,gauge)=qdot1;']);
      
   end
   
      %figure(2)
      %plot(FTime,qdot1);
      %title('Qdot');
      %xlabel('Time(s)')
      %ylabel('Heat Transfer Rates(W/m^2)')
      %grid

     eval(['save temp' run_number ' temp' run_number ' name' run_number]);
     eval(['save meanHTR' run_number ' meanHTR' run_number ' name' run_number]);