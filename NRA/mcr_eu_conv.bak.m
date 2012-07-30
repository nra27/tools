%
% engineering unit conversion - version 1
%
% Core build
%
% [MP,r,prt,NI,TC,Px,rpm,t] = mcr_eu_conv(run)
%

function [MP,r, prt,NI,TC,Px,rpm,m250,m110,Ro_,Re_z_,Re_phi_,Gr_b_,t] = mcr_eu_conv(run)

data_root = '~/Documents/research/NEWAC/mcr/data/test_runs';
cal_root = '~/Documents/research/NEWAC/mcr/data/cal_files';

%
% load prt cal
%
load([cal_root '/tel_prt_cal_006_12_10_10_linear.mat'])

%
% load raw telemetry data
%
load([ data_root '/' run '/tel_data.mat'])

len = length(tel_data)-20;
%
% Convert the PRTs to engineering units
%
prt_chans = [1 13 29 45];

%
% Loop over the 4 PRTs
%
for i = 1:4,
    prt(:,i) = polyval(P(:,i),tel_data(:,prt_chans(i)));
end


%%
% Update prt 2 and 3 with reconstructed values if above 42 deg. C

a = find(abs(prt(:,2))>42);
prt(a,2) =  mean( prt(a,[1 4])') +( mean(prt(a,[1 4])') -20 )./(0.96*mean( prt(a,[1 4])'));
 
b = find(abs(prt(:,3))>42);
prt(b,3) =  mean( prt(b,[1 4])') +( mean(prt(b,[1 4])') -20 )./(0.63*mean( prt(b,[1 4])'));

disp('Warning - prt channels reconstructed')

clear P % all calibrations use the same symbols

%
% load the telemetry thermocouple calibration
%
load([cal_root '/tel_tc_cal_001_12_10_10_linear.mat'])

%
% Apply the calibration to each module in turn
%
for i = 2:12,
    tc(:,i) = polyval(P(:,3),tel_data(:,i))+prt(:,1);
end

for i = 14:28,
    tc(:,i) = polyval(P(:,3),tel_data(:,i))+prt(:,1);
end

for i = 30:44,
    tc(:,i) = polyval(P(:,3),tel_data(:,i))+prt(:,1);
end

for i = 46:60,
    tc(:,i) = polyval(P(:,3),tel_data(:,i))+prt(:,1);
end

%
% Convert the drum TCs to MP locations
%
MP(1:len,1:11) = tc(1:len,2:12);
MP(1:len,12:26) = tc(1:len,14:28);
MP(1:len,12:26) = tc(1:len,14:28);
MP(1:len,27:41) = tc(1:len,30:44);
MP(1:len,42:56) = tc(1:len,46:60);

clear P

%
% Load the NI_data
%
load([data_root '/' run '/NI_data'])

%
% correct the length of the NI_data
%
NI = NI_data(1:len,:);
T_exit = NI(:,5);

%
% RPM
%
rpm = NI(:,21);

%
% line 22 - P_atmospheric [bar]
%
P_atm = NI(:,22);

%
% set up a timebase
%
t = [[1:length(NI(:,1))].*(1./NI(:,27))'/60]';

%
% Load the stationary TC data - channel list below
%
load([data_root '/' run '/TC_data.mat'])
TC = TC_data(1:len,:);

%
% All in [deg. C]
%
% 201 TC1 - Inlet air TC 1 - (180 deg. apart)[OK]
% 202 TC2 - Inlet air TC 2 - (180 deg. apart)[OK]
% 203 TC3 - Exit cavity air TC 1 - (180 deg. apart)[OK]
% 204 TC4 - Exit cavity air TC 2 - (180 deg. apart) [OK]
% 205 TC5 - Downstream grease-pack bearing TC upper location (installed near outer race) [OK]
% 206 TC6 - Downstream grease-pack bearing TC lower location (installed near outer race) [OK]
% 207 TC7 - Radial inflow support ceramic bearing TC[OK]
% 208 TC8 - Shaft TC 1 (inlet end)[OK]
% 209 TC9 - Shaft TC 2 [OK]
% 210 TC10 - Shaft TC 3 [OK]
% 211 TC11 - Shaft TC 4[OK]
% 212 TC12 - Shaft TC 5 [OK]
% 213 TC13 - Shaft TC 6 [OK]
% 214 TC14 - Shaft TC 7 (exit end)[OK]
% 215 TC15 - ZR110 mass flow rate TC[OK]
% 216 TC16 - ZT250 mass flow rate TC[OK]
% 217 TC17 - Radial inflow delivery TC (not installed yet)(NC) 
% 218 TC18 - Radial inflow mass flow rate TC, upper (NC)
% 219 TC19 - Radial inflow mass flow rate TC, lower(NC)
%

%
% Load the DSA data and convert to Bar
%
load([data_root '/' run '/DSA_data.mat'])
Px = DSA_data(1:len,:)/1000 + mean(P_atm);

% 
% DSA 3217 100 psi g block (191.30.80.174) Current tube connections
%
% All raw channels in [mbar]
% 
% Px 1 - ZT110 mass flow absolute pressure upstream of the OP [OK] leak checked back to the sensor
% Px 2 - NC  Radial inflow delivery
% Px 3 - NC Radial inflow mass flow absolute pressure OP upper
% Px 4 - NC Radial inflow mass flow absolute pressure OP lower
% Px 5 - ZR250 mass flow absolute pressure upstream of the OP [OK] leak checked back to the sensor (1-2 mbar lost in 10 minutes)
% Px 6 - Rig exit pressure
% Px 7 - Radial inflow seal balance cavity  (i.e. pretty close to the exit static, upstream of the transfer holes) [OK]
% Px 8 - Rotor outer seal balance cavity side (i.e. pretty close to the inlet static at the outer radius) [OK]
% Px 9 - Shaft outer seal balance cavity side (i.e. pretty close to the inlet static at the inner radius) [OK]
% Px 10 - Shaft inner seal balance cavity side (i.e. pretty close to the inlet static on the shaft through the transfer holes) [OK]
% Px 11 - Shaft 1 [OK] NB tbc !!!SLOW response!!!
% Px 12 - Shaft 4 [OK] NB tbc
% Px 13 - Shaft 3 [OK] NB tbc
% - Shaft 2 (NC) NB tbc
% Px 14 - Shaft 5 [OK] NB tbc
% - Shaft 6 (NC) NB tbc
% Px 15 - Shaft 7 [OK] NB tbc
% Px 16 - Shaft 8 [OK] NB tbc
%

%
% Radius versus MP table
%
r = [...
245.65
220.00
70.10
163.00
220.00
245.65
220.00
245.65
233.12
220.00
217.66
212.00
207.15
200.22
191.96
183.33
174.27
164.72
154.58
143.72
131.98
119.08
104.60
96.55
88.38
78.83
70.10
70.10
70.10
70.10
78.83
88.83
96.55
112.07
125.69
137.97
149.25
159.73
169.56
178.86
187.69
196.13
204.22
210.30
217.66
220.00
245.65
220.00
245.65
220.00
159.73
70.10
220.00
245.65];

% %
% % Mass flow rates
% %
% 
% % %
% % % Radial massflow
% % %
% % 
% % % Geometry terms
% % do = 24.000e-3; % [m]
% % D = 48e-3; % [m] MUST BE CHECKED
% % be = do/D; % [-]
% % E =1/sqrt(1-be^4); % [-]
% % EPS = 1;
% % L1 = D/D; % [m] % l1 = D
% % L2 = 0.47; % [m] % l2 = D/2
% % 
% % M2 = 2*L2/(1-be); 
% % 
% % % Measured variables
% % dp = 74.6/1000*1e5; % [Pa]
% % P = Px(:,4); % [Pa]
% % T = TC(:,15); % [K]
% % 
% % % Derived variables
% % rho = P/(287*T); % [kg m^-3]
% % mu = (T^1.5*(0.00000145))./(T+110.33); % [
% % 
% % % Initial guesses for iteration
% % Re = 1000; % [-]
% % m = 100; % [kg s^-1]
% % 
% % A = (19000*be/Re)^0.8;
% % 
% % for i = 1:10,
% %     
% %     % Reynolds No.
% %     Re = (4*m)/(pi*D*mu);
% %     
% %     % Discharge coefficient from the Reader-Harris/Gallagher (1998) Eqn. ISO 5167
% %     Cd =0.5961 ...
% %         + (0.0261*be^2) ...
% %         - (0.216*be^8) ...
% %         + 0.000521*(be*1e6/Re)^0.7 ...
% %         + (0.0188+ 0.0063*A)*be^3.5*(1/Re*1e6)^0.3 ...
% %         + (0.043+0.08*exp(-10*L1)-0.123*exp(-7*L1))*(1-0.11*A)*(be^4)/(1-be^4) ...
% %         - 0.031*(M2-0.8*M2^1.1)*be^1.3 ...
% %         + 0.011*(0.75 - be)*(2.8-D*1e3/25.4);
% %     
% %     % Stolz equation from BS1042
% %     %     Cd =0.5959+(0.0312*be^2.1)-(0.184*be^8)+ ...
% %     %     (0.0029*be^2.5)*(1000000/Re)^0.75+...
% %     %     (0.039*be^4*(1-be^4)^-1)-(0.0337*L2d*be^3);
% %     
% %     % Expansibility coefficient
% %     expans = 1 - (0.351 + 0.256*be^4 + 0.93*be^8)*(1 - (P/(P-dp))^(1/1.4));
% %     
% %     const =Cd/(1-be^4)*expans*pi/4*do^2;
% %     m_rad = const*sqrt(dp*2.*rho);
% %     
% %     % disp(num2str(m(i+1)*1000))
% %     
% %     i = i+1;
% %     
% % end


%
% ZT250 massflow
%

% Geometry terms
do = 43.991e-3; % [m]
D = 78e-3; % [m] MUST BE CHECKED
be = do/D; % [-]
E =1/sqrt(1-be^4); % [-]
EPS = 1;
L1 = 0; % [m] % l1 = D
L2 = 0; % [m] % l2 = D/2

M2 = 2*L2/(1-be); 

% Measured variables
dp = (NI(:,20)-1)/4*1.865*1e5; % [Pa]
P = (Px(:,5))*1e5;; % [Pa]
T = TC(:,16)+273.15; % [K]

% Derived variables
rho = P./(287*T); % [kg m^-3]
mu = (T.^1.5*(0.00000145))./(T+110.33); % [

% Initial guesses for iteration
Re = 1000*ones(length(P),1); % [-]
m = 100*ones(length(P),1); % [kg s^-1]
A = (19000*be./Re).^0.8;

for i = 1:10,
    
   % Reynolds No.
    Re = (4*m)./(pi*D*mu);
    
    % Discharge coefficient from the Reader-Harris/Gallagher (1998) Eqn. ISO 5167
    tmp1 = (0.0188+ 0.0063.*A);
    tmp2 = be.^3.5*(1./Re*1e6).^0.3;
    Cd =0.5961 ...
        + (0.0261*be^2) ...
        - (0.216*be^8) ...
        + 0.000521*(be*1e6./Re).^0.7 ...
        +  tmp1.*tmp2 ...
        + (0.043+0.08*exp(-10*L1)-0.123*exp(-7*L1))*(1-0.11.*A).*(be^4)./(1-be^4) ...
        - 0.031*(M2-0.8.*M2.^1.1)*be.^1.3 ...
        + 0.011*(0.75 - be).*(2.8-D*1e3/25.4);
    
    %     Stolz equation from BS1042
    %     Cd =0.5959+(0.0312*be^2.1)-(0.184*be^8)+ ...
    %     (0.0029*be^2.5)*(1000000/Re)^0.75+...
    %     (0.039*be^4*(1-be^4)^-1)-(0.0337*L2d*be^3);
    
    % Expansibility coefficient
    expans = 1 - (0.351 + 0.256*be^4 + 0.93*be^8).*(1 - (P./(P-dp)).^(1/1.4));
    
    const =Cd/(1-be^4).*expans*pi/4*do^2;
    m = const.*abs(sqrt(dp*2.*rho));
    
    % disp(num2str(m(i+1)*1000))
    
    i = i+1;
    
end

m250 = m;

%
% ZT110 massflow
%

% Geometry terms
do = 40.993e-3; % [m]
D = 78e-3; % [m] MUST BE CHECKED
be = do/D; % [-]
E =1/sqrt(1-be^4); % [-]
EPS = 1;
L1 = 0; % [m] % l1 = D
L2 = 0; % [m] % l2 = D/2
M2 = 2*L2/(1-be); 

% Measured variables
dp = (NI(:,19)-1)/4*0.373*1e5; % [Pa]
P = (Px(:,1))*1e5; % [Pa]
T = TC(:,15)+273.15; % [K]

% Derived variables
rho = P./(287*T); % [kg m^-3]
mu = (T.^1.5*(0.00000145))./(T+110.33); % [

% Initial guesses for iteration
Re = 1000*ones(length(P),1); % [-]
m = 100*ones(length(P),1); % [kg s^-1]
A = (19000*be./Re).^0.8; % Factor used in the discharge equation....

for i = 1:10,
    
    % Reynolds No.
    Re = (4*m)./(pi*D*mu);
    
    % Discharge coefficient from the Reader-Harris/Gallagher (1998) Eqn. ISO 5167
    tmp1 = (0.0188+ 0.0063.*A);
    tmp2 = be.^3.5*(1./Re*1e6).^0.3;
    Cd =0.5961 ...
        + (0.0261*be^2) ...
        - (0.216*be^8) ...
        + 0.000521*(be*1e6./Re).^0.7 ...
        +  tmp1.*tmp2 ...
        + (0.043+0.08*exp(-10*L1)-0.123*exp(-7*L1))*(1-0.11.*A).*(be^4)./(1-be^4) ...
        - 0.031*(M2-0.8.*M2.^1.1)*be.^1.3 ...
        + 0.011*(0.75 - be).*(2.8-D*1e3/25.4);
    
    %     Stolz equation from BS1042
    %     Cd =0.5959+(0.0312*be^2.1)-(0.184*be^8)+ ...
    %     (0.0029*be^2.5)*(1000000/Re)^0.75+...
    %     (0.039*be^4*(1-be^4)^-1)-(0.0337*L2d*be^3);
    
    % Expansibility coefficient
    expans = 1 - (0.351 + 0.256*be^4 + 0.93*be^8).*(1 - (P./(P-dp)).^(1/1.4));
    
    const =Cd/(1-be^4).*expans*pi/4*do^2;
    m = const.*abs(sqrt(dp*2.*rho));
    
    % disp(num2str(m(i+1)*1000))
    
    i = i+1;
    
end

m110 = m;

%
% ND conditions
%

IDLE_MTO  = round(NI(:,15)/0.016-0.25);

bore_mass = IDLE_MTO.*m250 + m110;


% MCR fixed data
r_s = 0.0701; % [m]
a = 0.0802; % [m]
b = 0.2301; % [m]
R = 287.1; %
s = 0.048; % [m] 

p_bore = (Px(:,6))*1e5;
T_bore  = 0.5*(TC(:,1)+TC(:,3))+273.15;
T_shroud = 0.5*(MP(:,10)+MP(:,46))+273.15;

% MCR derived
omega = rpm/60*2*pi; % rad s^-1
rho_bore = p_bore./(R*T_bore);
[k_bore,mu_bore] = Sutherlands_air(T_bore);
axial_area = pi*(a^2 - r_s^2);
W_av = bore_mass ./ ( axial_area * rho_bore);     
DT_sh = (T_shroud - T_bore); 
beta = 1./(T_bore+0.5*DT_sh) % need a better definition??

% Rotational Reynolds Number based on bore fluid conditions
Re_phi = ( rho_bore .* omega .* b^2 ) ./ mu_bore;

% Axial throughflow Reynolds Number based on bore conditions
Re_z = ( rho_bore .* W_av * 2 * (a - r_s) ) ./ mu_bore;

% Rossby Number based on the inner radius - what about outer radius (will
% always be b/a lower
Ro = W_av ./ (omega * a);

% Grashof b
Gr_b = (rho_bore.^2.*omega.^2 * b * (b - a)^3 .* beta .* DT_sh) ./ mu_bore .^2; 

% Grashof sh
Gr_sh = (rho_bore.^2.*omega.^2 * b * (s/2)^3 .*beta .* DT_sh) ./ mu_bore .^2; 

%
% Trent 1000 fixed data
%
r_s = 0.0733; % m
a = 0.0883; % m
b = 0.2426; % m
R = 287.1;
s = 0.048; % m need to check

%           IDLE        MTO     which stage is this?????
bore_mass = [0.29       1.97];
p_bore =    [118.104e3  795.123e3];
T_bore =    [344.5      657.7];
T_shroud =  [443        807];
omega =     [886        1294]; % rad s^-1

% % T1000 derived
rho_bore = p_bore./(R*T_bore);
[k_bore,mu_bore] = Sutherlands_air(T_bore);
axial_area = pi*(a^2 - r_s^2);
W_av = bore_mass ./ ( axial_area * rho_bore);
DT_sh = (T_shroud - T_bore); 
beta = 1./(T_bore+0.5*DT_sh); % need a better definition

% Rotational Reynolds Number
Re_phi_T1000 = ( rho_bore .* omega .* b^2 ) ./ mu_bore;
Re_phi_T1000 = Re_phi_T1000(1)*(1-IDLE_MTO)+Re_phi_T1000(2)*(IDLE_MTO);
Re_phi_= Re_phi./Re_phi_T1000;


% Axial throughflow Reynolds Number
Re_z_T1000 = ( rho_bore .* W_av * 2 * (a - r_s) ) ./ mu_bore;
Re_z_T1000 = Re_z_T1000(1)*(1-IDLE_MTO)+Re_z_T1000(2)*(IDLE_MTO);
Re_z_= Re_z./Re_z_T1000;

% Rossby Number
Ro_T1000 = W_av ./ (omega * a);
Ro_T1000 = Ro_T1000(1)*(1-IDLE_MTO)+Ro_T1000(2)*(IDLE_MTO);
Ro_= Ro./Ro_T1000;

% Grashof b
Gr_b_T1000 = (rho_bore.^2.*omega.^2 * b * (b - a)^3 .* beta .* DT_sh) ./ mu_bore .^2; % mu needs a better treatment
Gr_b_T1000 =Gr_b_T1000(1)*(1-IDLE_MTO)+Gr_b_T1000(2)*(IDLE_MTO);
Gr_b_= Gr_b./Gr_b_T1000;


% Grashof sh
Gr_sh_T1000 = (rho_bore.^2.*omega.^2 * b * (s/2)^3 .*beta .* DT_sh) ./ mu_bore .^2; % mu needs a better treatment
Gr_sh_T1000 =Gr_sh_T1000(1)*(1-IDLE_MTO)+Gr_sh_T1000(2)*(IDLE_MTO);
Gr_sh_T1000_= Gr_sh./Gr_sh_T1000;






