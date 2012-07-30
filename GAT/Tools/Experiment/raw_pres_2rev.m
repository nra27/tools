%%%% To extract heat transfer rate during 2 revolution

%%%% AUTO AVERAGING PROGRAM (heat transfer rate) %%%%
%clear
%file=['../r7765/r7765'
%      '../r7766/r7766'
%      '../r7768/r7768'
%      '../r7770/r7770'
%      '../r7771/r7771'
%      '../r7772/r7772'
%      '../r7773/r7773'];

% Automatic stuff
auto = 1;
RelImportance=[1 1]; 

% Establish directory
directory = pwd;
run_number = directory(end-3:end);
file = ['../run_' run_number '/r' run_number];

file_num=length(file(:,1));
   
%load Tr_c7790b %load design adiabatic wall temperature
%Tr=Tr_c7790b;

save_string1 = [];
save_string2 = [];

for f=1:file_num;
   
  eval(['load ' file(f,1:12) 'pressC' file(f,14:17)])
  %eval(['load 'file(f,1:14) 'a'])
  eval(['load ' file(f,1:17) 'b'])
  eval(['load ' file(f,1:17) 'eu'])
  eval(['load ' file(f,1:12) 'Good_Channels_' file(f,14:17)])
   
t=eu.time(1).t;
t2=decimate(t,20);

rpm=eu.data{57};
rpm2=decimate(rpm,20,'FIR');

r=1.34;
T00=eu.data{56};
To=mean(T00(1:50));
Pbar=eu.data{61};
Pbaro=mean(Pbar(1:50));
T01=To*(Pbar/Pbaro).^(1-1/r); % NGV Inlet Total Temperature

speed=rpm./sqrt(T01);
speed2=decimate(speed,20,'FIR');

P01=eu.data{62}; %P01_wa   NGV Inlet Total Pressure

%FI1 :20, FI2 :11, FI3 :23, FI4 :14, FI5 :50, FI6 :4, FI7 :47, FI8 :35
Pfi = eu.data{Channels.Fi(1)}*0;
for i = 1:length(Channels.Fi)
    Pfi = Pfi + eu.data{Channels.Fi(i)};
end
Pfi = Pfi/length(Channels.Fi);

%FO1 :32, FO2 :26, FO3 :39, FO4 :5, FO5 :44, FO6 :45, FO7 :2, FO8 :28
Pfo = eu.data{Channels.Fo(1)}*0;
for i = 1:length(Channels.Fo)
    Pfo = Pfo + eu.data{Channels.Fo(i)};
end
Pfo = Pfo/length(Channels.Fo);

P3=(Pfi+Pfo)/2;
PresR=P01./P3;
PresR2=decimate(PresR,20,'FIR');

close all
figure(1)
  set(1,'menubar','none','position',[14 195 626 397]);
  set(1,'NumberTitle','off','Name','Speed');
  plot(t,rpm,'k',t2,rpm2,'c');
  xlabel('Time (s)')
  ylabel('Speed')
  title('Speed')  
  axis([-0.15 0.15 7000 9500])
  grid

figure(2)
  set(2,'menubar','none','position',[19 190 626 397]);
  set(2,'NumberTitle','off','Name','Reduced Speed');
  plot(t,speed,'k',t2,speed2,'c');
  xlabel('Time (s)')
  ylabel('Speed')
  title('Speed')  
  axis([-0.15 0.15 400 500])
  grid
  
figure(3)
  set(3,'menubar','none','position',[24 185 626 397]);
  set(3,'NumberTitle','off','Name','Pressure Ratio');
  plot(t,PresR,'k',t2,PresR2,'c');
  xlabel('Time (s)')
  ylabel('Pressure Ratio')
  title('Pressure Ratio')  
  axis([-0.15 0.15 2 4])
  grid
  
  speed2=speed2/460.48;
  PresR2=PresR2/3.1654;
figure(4)
  set(4,'menubar','none','position',[13 624 626 397]);
  set(4,'NumberTitle','off','Name','Operating Point');
  plot(t2,speed2,'k',t2,PresR2,'r');
  xlabel('Time (s)')
  ylabel('N/sqrt(T) or P01/P3')
  title('Operating Point')  
  axis([-0.15 0.15 0.8 1.2])
  grid
   
edist = (RelImportance(1)*(speed2-1)).^2 + (RelImportance(2)*(PresR2-1)).^2;
minp = find(edist == min(edist)); % this is position of operating point in slow data

figure(4)
  hold on
  plot(t2(minp),speed2(minp),'*c',t2(minp),PresR2(minp),'*c')
  hold off


%%%%%%%%%%%%%%% Reynolds number calculation%%%%%%%%%%%%%%%%%%%

k=1.396;
klog=(k-1)/k;
R=287.04;

%#######
Cx=0.02435; %0.0312;
%#######

Cp=1010;
%t=eu.time(1).t;

%%%calculate Re number %%%%

  %CI1 :27, CI2 :29, CI3 :30, CI4 :40, CI5 :53, CI6 :49, CI7 :16, CI8 :31
  Pci = eu.data{Channels.Ci(1)}*0;
  for i = 1:length(Channels.Ci)
    Pci = Pci + eu.data{Channels.Ci(i)};
  end
  Pci = Pci/length(Channels.Ci);
  
  %CO1 :1, CO2 :25, CO3 :52, CO4 :41, CO5 :42, CO6 :43, CO7 :7, CO8 :8
  Pco = eu.data{Channels.Co(1)}*0;
  for i = 1:length(Channels.Co)
    Pco = Pco + eu.data{Channels.Co(i)};
  end
  Pco = Pco/length(Channels.Co);
  
  P2=abs((Pci+Pco)/2); % NGV Exit Static Pressure
  
  %###########
  %T01=eu.data{58};
  %###########
  
  TR=(P01./P2).^klog;
  
  T2=T01./TR; % NGV Exit Static Temperature
  
  M=sqrt((TR-1)*2/(k-1)); %NGV Exit Mach Number
  M=abs(M);
  a=sqrt(k*R*T2); %NGV Exit Local Acoustic Velocity
  
  v2=M.*a; %NGV Exit Velocity
  
  myu=1.7235E-5*((273+110)./(T2+110)).*(T2/273).^1.55; %############1.55
  
  Re=P2.*M./myu.*sqrt(1./T2)*Cx*sqrt(k/R); %Re Number based on blade chord
  
  
  opt_p1=findel(t2(minp),t); %sampling number for slow data

  figure(5)
  set(5,'menubar','none','position',[658 624 626 397]);
  set(5,'NumberTitle','off','Name','Reynold''s Number');
  plot(t,Re*0.0312/0.02435,'k',t(opt_p1),Re(opt_p1)*0.0312/0.02435,'*c');
  xlabel('Time (s)')
  ylabel('Reynolds Number')
  title('Reynolds Number based on NGV Chord')  
  axis([-0.15 0.15 2.5E6 2.9E6])
  grid
  
  disp(file(f,:))
  if auto
      opt_p2 = opt_p1;
      opt_time(f) = t(opt_p2);
  else
      points=ginput(1); %ginput(t value, Re value)
      opt_time(f)=points(1,1);
      opt_p2=findel(opt_time(f),t); %sampling number for slow data
  end
    
  alpha2=d2r(70); %NGV Exit angle deg --> rad
  U2 = rpm*(2*pi*0.255/60); %blade rotation speed (m/s)
  v2rel2 = (v2*cos(alpha2)).^2 + (v2*sin(alpha2) + U2).^2; %
  % incidence
  tanalf2 = (v2*sin(alpha2) - U2)./(v2*cos(alpha2)); 
  alf2 = r2d(atan(tanalf2));
  
  figure(4)
  opt_p2t2=findel(opt_time(f),t2);
  hold on
  plot(t2(opt_p2t2),speed2(opt_p2t2),'*r',t2(opt_p2t2),PresR2(opt_p2t2),'*r')
  hold off
  
  figure(5)
  hold on
  plot(t(opt_p2),Re(opt_p2)*0.0312/0.02435,'*r');
  hold off
  
  figure(6)
  set(6,'menubar','none','position',[658 195 626 397]);
  set(6,'NumberTitle','off','Name','Operating Point');
  plot(t,alf2,'k',t(opt_p1),alf2(opt_p1),'c*',t(opt_p2),alf2(opt_p2),'r*')
  xlabel('Time (s)')
  ylabel('Deg')
  title('Relative Blade Inlet Incidence')  
  axis([-0.1 0.1 30 60])
  grid
  
  ave_time=0.007; % 0.007s is 1 revolution time.
  pointf1=findel(opt_time(f)-ave_time,FTime); %sampling number of fast data
  pointf2=findel(opt_time(f)+ave_time,FTime); %sampling number of fast data
  points1=findel(opt_time(f)-ave_time,t); %sampling number of slow data
  points2=findel(opt_time(f)+ave_time,t); %sampling number of slow data

  opt.time(f)=opt_time;
  opt.T01(f)=mean(T01(points1:points2));
  opt.P01(f)=mean(P01(points1:points2));
  opt.Re(f)=mean(Re(points1:points2))*0.0312/0.02435;
  opt.rpm(f)=mean(rpm(points1:points2));
  opt.speed(f)=mean(speed(points1:points2));
  opt.PresR(f)=mean(PresR(points1:points2));
  opt.alf2(f)=mean(alf2(points1:points2));
   
  
  %%%% extraction of laser one revolution line signal %%%%%%
   rev1=FData(:,2);
   t_len=length(FTime);
   a1=rev1(1:t_len-1)-0.4; 
   a2=rev1(2:t_len)-0.4;   
   b=a1.*a2;
   change_pt_rev=find(b<0); %change_pt : tuning point from negative to positive
                        %            or from positive to negative in one revolution signal
                        %            That means one revolution passing 
   clear a1 a2 b
   
     %############ remove the noise of 1 revolution line signal P41, P45 Vol. 5 ############## 
      kk=change_pt_rev(2:length(change_pt_rev))-change_pt_rev(1:length(change_pt_rev)-1);
      bb=find(kk>1300); %normal sampling interval of 1 revolution in 1 rev data is about 1500 sampling points
      change_pt_rev=change_pt_rev(bb); %absolute sampling number for one revolution
     %##############         end          #################
     
   FTime2=FTime(change_pt_rev);
   start_pt=findel(opt_time(f),FTime2); %sampling number for FTime2 = sampling number for change_pt_rev
   pointf1=change_pt_rev(start_pt); %new pointf1

  %%%% splitting each revolution %%%%%%
  % Before executing this program, heat_cal should be executed. 
   line60=FData(:,4);
   
   t_len=length(FTime);

   a1=line60(pointf1:t_len-1)+0.00001; % 0.00001 : prevent a1 from being zero
   a2=line60(pointf1+1:t_len)+0.00001; % 0.00001 : prevent a2 from being zero
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
   change_pt=change_pt(zz); %relative sampling number  against pointf1
  %##############         end          #################
   
  %wholespeed :speed vector
   wholespeed=interp1(t2,rpm2,FTime,'linear');  
  %sampling interval
    tau=2.0E-6; %sampling time tau should be constant 500kHz --> 2.0E-6(second)

  %change time vector to fit design speed
   wholetau=tau*wholespeed/8910; % 8910rpm : design speed
   wholetime=cumsum(wholetau);
   wholetime=[0;wholetime(1:length(wholetime)-1)];
  
   ave_num=120;
   blade_num=2;
   for n=0:ave_num;
      passing(n+1)=change_pt(2*(blade_num-1)*n+1)+pointf1-1; % absolute sampling number in each blade passing
   end    
   lenpass=length(passing);
   L=passing(lenpass)-passing(1)+1;

   eval(['C' file(f,14:17) '=pressC' file(f,14:17) '(passing(1):passing(lenpass),:);'])
   eval(['t_vec' file(f,14:17) '=(wholetime(passing(1):passing(lenpass),:)-wholetime(passing(1)))/(wholetime(passing(lenpass))-wholetime(passing(1)))*120;'])
   del_p = 27;
   %load blade_HTR
   eval(['C' file(f,14:17) '=[C' file(f,14:17) '(del_p+1:L,:);C' file(f,14:17) '(1:del_p,:)];'])    
      
      %clear data        
  
      eval(['line' num2str(f) '_pres = C' file(f,14:17) ';']); 
      eval(['line' num2str(f) '_pass = t_vec' file(f,14:17) ';']);
      
      save_string1 = [save_string1 ' line' num2str(f) '_pres'];
      save_string2 = [save_string2 ' line' num2str(f) '_pass'];
      
  end %end of for f=1:file_num 
  
  
%   line1_qdot=Q7765;
%   line2_qdot=Q7766;
%   line3_qdot=Q7768;
%   line4_qdot=Q7770;
%   line5_qdot=Q7771;
%   line6_qdot=Q7772;
%   line7_qdot=Q7773;
%   
%   line1_pass=t_vec7765;
%   line2_pass=t_vec7766;
%   line3_pass=t_vec7768;
%   line4_pass=t_vec7770;
%   line5_pass=t_vec7771;
%   line6_pass=t_vec7772;
%   line7_pass=t_vec7773;
  
  eval(['save rawPres_2rev' save_string1 save_string2 ' opt']);