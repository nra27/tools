%%%% AUTO SUBTRACTION PROGRAM (heat transfer rate) %%%%

% Establish directory
directory = pwd;
run_number = directory(end-3:end);

eval(['load r' run_number 'a']);
eval(['load r' run_number 'b']);
eval(['load ACout' run_number]);

%%%% making a speed data %%%%%
   speed=SData(:,57);

  %speed data rpmjan97
  % Calibration 22/1/97 by Rob using a signal generator and speed box.
  % vol is voltage, fr is frequency (same as rpm since using 60 line disk);
  %fr=[3.648 4.16 4.828 5.288 5.822 6.201 6.661 6.893 7.643 8.058 8.474 8.778 9.047 9.416 10.123 10.649 11.138 11.613 12.135]*1000;
  %vol=[.4878 .55 .6446 .7062 .7742 .827 .8869 .9188 1.0173 1.0728 1.1284 1.1703 1.203 1.2524 1.3455 1.4128 1.4786 1.5400 1.6106];
  %p = polyfit(vol, fr, 1);
 
  %speed data rpmjan05
   data = [0.146247 1060;
       0.103781 1503;
       0.269853 2011;
       0.33720 2528;
       0.40040 3000;
       0.46917 3518;
       0.53360 4012;
       0.59915 4513;
       0.66383 5012;
       0.72811 5512;
       0.79363 6018;
       0.86893 6595;
       0.92770 7066;
       0.98880 7521;
       1.05365 8039;
       1.13393 8646;
       1.18690 9055;
       1.24875 9544;
       1.31913 10084];
   vol=data(:,1);
   fr=data(:,2);

   rpm=interp1(vol,fr,speed,'linear');
   figure(17)
   plot(STime,rpm)
   grid
   hold on
   axis([-0.4 0.4 6800 9800])

  %remove noise
   rpm2=decimate(rpm,100,200,'FIR');
   time2=decimate(STime,100,200,'FIR');
   plot(time2,rpm2,'c')
   hold off
   
   
%%%% splitting each revolution %%%%%%
  % Before executing this program, heat_cal should be executed. 
   line60=FData(:,4);
   
   
%for gauge=1:1   
   figure(18)
   %plot(FTime,fastHTR7753(gauge))
   eval(['plot(FTime,ACout' run_number '(:,1));']);
   grid
   hold on
     %'Click a firing point'
       %pointf=ginput(1)
       %pointf=findel(pointf(1,1),FTime)
       %h_data=h_data-mean(h_data(1:pointf)); %remove DC shift
   plot(FTime,line60/5000,'k')
    'Click a beginning point of 1 revolution before fire'
   point1=ginput(1)  %select starting point of 1 revolution before fire
   point1=findel(point1(1,1),FTime)
   t_len=length(FTime);

   a1=line60(point1-5:t_len-1)+0.00001; % 0.00001 : prevent a1 from being zero
   a2=line60(point1-4:t_len)+0.00001; % 0.00001 : prevent a2 from being zero
   b=a1.*a2;
   change_pt=find(b<0); %change_pt : tuning point from negative to positive
                        %            or from positive to negative in line60
                        %            That means one blade passing 
   clear a1 a2 b
   
  %############ remove the noise of 60 line signal P41, P45 Vol. 5 ############## 
   kk=change_pt(2:length(change_pt))-change_pt(1:length(change_pt)-1);
   bb=find(kk<15); %minimum interval between each crossing in normal 60 line data is 15 sampling points
   xx=bb(2:length(bb))-bb(1:length(bb)-1);
   cc=find(xx==1);
   mm=bb(cc+1);
   change_pt(mm)=0;
   zz=find(change_pt);
   change_pt=change_pt(zz);
  %##############         end          #################

   
   n=0;
   line60_pt=[];
   while  120*n+1<length(change_pt)
      revolv=change_pt(120*n+1)+point1-6; % absolute sampling number in each revolution 
      line60_pt=[line60_pt,revolv]; %sanmling number vector in each resolution
        if n==0 
          plot(FTime(revolv-4:revolv+4),line60(revolv-4:revolv+4)/100,'r')
            else
              plot(FTime(revolv-4:revolv+4),line60(revolv-4:revolv+4)/100,'g')
        end
    n=n+1;      
   end
   hold off
   clear change_pt
  %data before fire
   %bfdata=qdot1(line60_pt(1):line60_pt(2)); % voltage data of the first 1 revolution before fire
      %bftime=FTime(line60_pt(1):line60_pt(2));     % time data of the first 1 revolution before fire

      %     %data after fire
      %'Click two points of a beginning point and an end point of 1 revolution after fire'      
      %point2=ginput(2) % select 1 revolution after fire
      %point2=sort(findel(point2(:,1),FTime))
      %afdata=h_data(point2(1):point2(2));
      %aftime=FTime(point2(1):point2(2));
      
   
  %wholespeed :speed vector
   %wholespeed=interp1(Points(:,1),Points(:,2),FTime(:,1),'linear'); % use rpmyoshi1
   wholespeed=interp1(time2,rpm2,FTime,'linear');  % use rpmyoshi2

          
  %bfspeed :speed before fire
   bfspeed=wholespeed(line60_pt(1):line60_pt(2)); 

  %sampling interval
   tau=2.0E-6; %sampling time tau should be constant 500kHz --> 2.0E-6(second)

  %change time vector to fit design speed
   wholetau=tau*wholespeed/8910.0; % 8910.0rpm : design speed
   wholetime=cumsum(wholetau);
   wholetime=[0;wholetime(1:length(wholetime)-1)];
  
  %bftime : fitted time vector before fire
   bftime=wholetime(line60_pt(1):line60_pt(2))-wholetime(line60_pt(1));
   
%for gauge=1:16;   
  %data before fire
   eval(['bfdata=ACout' run_number '(line60_pt(1):line60_pt(2),:);']); % voltage data of the first 1 revolution before fire

  %Do subtraction
   whole_subtract=[];
     for n=1:length(line60_pt)-1
      %change time vector before fire to fit nearly design speed
       aftime=wholetime(line60_pt(n):line60_pt(n+1))-wholetime(line60_pt(n));
       afspeed=wholespeed(line60_pt(n):line60_pt(n+1));
       eval(['afdata=ACout' run_number '(line60_pt(n):line60_pt(n+1),:);']);
       rpmb=aftime(length(aftime))/bftime(length(bftime)) %rpmb:error compensation factor
                                                          %aftime length should be the length of bftime, but
                                                          %aftime length is a little differenf from bftime
                                                          %length because speed data is not accurate. 
       bftime2=bftime*rpmb; %matching the time length of both aftime and bftime.    

            %figure(1)
            %plot(aftime2,afdata);hold on; plot(bftime2,bfdata,'c');
            %title('Comparison of before fire and after fire') 
            %xlabel('Time(s)')
            %ylabel('Heat Transfer Rate(W/m^2)')
            %hold off
   
      %data interpolation(match the time vector) 
       bfdata2=interp1(bftime2,bfdata,aftime,'linear');
       bfspeed2=interp1(bftime2,bfspeed,aftime,'linear');
      %modification by rotor speed, assumed that magnetic pickup is proportional to rotor speed.
       bfdata3=bfdata2.*repmat(afspeed,1,16)./repmat(bfspeed2,1,16);
  
      %data subtraction 
       % figure(3); plot(afdata,'k'); hold on; plot(bfdata3,'c'); hold off     
       subtract_data=afdata-bfdata3; 
       % figure(4); plot(subtract_data)
       
      %remove a data connection point from each revolution.
       subtract_data=subtract_data(1:length(subtract_data)-1,:);  
       whole_subtract=[whole_subtract;subtract_data]; %data after subtraction
       
    end %end of n=1:length(line60_pt)-1 loop
    
   eval(['ACout' run_number '_subt=[zeros(line60_pt(1)-1,16);whole_subtract;zeros(t_len-(line60_pt(length(line60_pt))-1),16)];']);  
   %Time7753(:,gauge)=FTime(line60_pt(1):line60_pt(length(line60_pt)));
   
 for gauge=1:16  
   figure(gauge)
   eval(['plot(FTime,ACout' run_number '_subt(:,gauge))']);
   title('Result of Subtraction')
   xlabel('Time(s)')
   ylabel('AC Gauge Voltage (Volt)')
   grid
 end  
  
   % save subtract7753 subtract7753 Time7753
 eval(['save ACout' run_number '_subt ACout' run_number '_subt name' run_number]);
 clear all
 