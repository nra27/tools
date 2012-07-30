% Establish directory
directory = pwd;
run_number = directory(end-3:end);

% Load data
eval(['load r' run_number 'b']);
eval(['load ACout' run_number '_subt']);
eval(['load HT_DATA_' run_number]);

%%%%% Time-resolved Heat Transfer Calculation using AC signals %%%%%%%%

  %determination of vo
 I0 = Vsense./Rsense;
 
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
  eval(['data=ACout' run_number '_subt(:,kk);']);
  
  %calcuration of temperaure rise
  temp=data/I0(gauge)/R20(gauge)/alpha(gauge);
  
  eval(['subtract' run_number '_temp(:,gauge)=temp;']);
  
  %plot temperature rise
  %figure(1)
  %plot(FTime,temp);
  %title('Temperature Rise');
  %xlabel('Time(s)')
  %ylabel('temperature(K)')
  %grid
  
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
      eval(['subtract' run_number '_vol(:,gauge)=qdot1;']);
      %fastHTR7753_vol(:,gauge)=qdot1;
      
      figure(gauge)
      eval(['plot(FTime,subtract' run_number '_vol(:,gauge));']);
      title('Qdot');
      xlabel('Time(s)')
      ylabel('Heat Transfer Rates(W/m^2)')
      axis([-0.2 0.2 -3E5 5E5])
      grid

   end
   
   eval(['save subtract' run_number '_vol subtract' run_number '_vol subtract' run_number '_temp name' run_number ' FTime']);
   clear all   
   