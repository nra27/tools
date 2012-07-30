%
% Raw Data to Engineering Unit Conversion
% Sussex University TFMRC Multiple Cavity Rig - Fundamental Build 2011
%
% [MP,r, prt,NI,TC,Px,rpm,m250,m110,Ro,Re_z,Re_phi,Gr_b_,t,m_bore,m_rad] = ...
% mcr_eu_conv(run)
%

function [MP,r, prt,NI,TC,Px,rpm,m250,m110,Ro,Re_z,Re_phi,Gr_b,t,m_bore,m_rad,T_rake] = mcr_eu_conv_vasu(run)

data_root = '~/Documents/research/NEWAC/mcr/data/test_runs';
cal_root = '~/Documents/research/NEWAC/mcr/data/cal_files';

%
% load raw telemetry data
%
load([ data_root '/' run '/tel_data.mat'])
len = length(tel_data)-20;

%
% load prt calibration data
%
load([cal_root '/tel_prt_cal_006_12_10_10_linear.mat'])

%
% Convert the PRTs to engineering units [deg. C]
%
prt_chans = [1 13 29 45];

%
% Apply the calibration by looping over the 4 PRTs
%
for i = 1:4,
    prt(:,i) = polyval(P(:,i),tel_data(:,prt_chans(i)));
end

% Two of the telemetry module prt channels over-ranged during the hottest
% sections of the MTO runs. CJC is achevied by reconstructing these two prt
% channles by scaling the mean of the other two if the temperature goes
% above 42 deg. C.
%
% For the range from room temperature up to 42 deg. C, where all 4 are within range,
% the scaling matches the channels to within +/- 0.05 deg. C. As such this
% represents a good estimate of the uncertainty introduced by the reconstruction.
% This accounts for the different self heating of each telemetry module.

%
% Update prt_E1 and prt_E2 with reconstructed values if above 42 deg. C
%
a = find(abs(prt(:,2))>42);
prt(a,2) =  mean( prt(a,[1 4])') +( mean(prt(a,[1 4])') -20 )./(0.96*mean( prt(a,[1 4])'));

b = find(abs(prt(:,3))>42);
prt(b,3) =  mean( prt(b,[1 4])') +( mean(prt(b,[1 4])') -20 )./(0.63*mean( prt(b,[1 4])'));

disp('Warning - prt channels reconstructed')

clear P % all calibrations use the same symbols, these must be cleared for robust debugging.

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

% Base module
MP(1:len,1:11) = tc(1:len,2:12);

% E1
MP(1:len,12:26) = tc(1:len,14:28);

% E2
MP(1:len,27:41) = tc(1:len,30:44);

% E3
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
T_rake = NI(:,30:33);

%
% Drum speed, [RPM]
%
rpm = NI(:,21);

%
% P_atmospheric, [bar]
%
P_atm = NI(:,22);

%
% Timebase, t(n) [s]
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
% 201 TC1 - Inlet air TC 1 - (180 deg. apart) [OK]
% 202 TC2 - Inlet air TC 2 - (180 deg. apart) [OK]
% 203 TC3 - Exit cavity air TC 1 - (180 deg. apart) [OK]
% 204 TC4 - Exit cavity air TC 2 - (180 deg. apart) [OK]
% 205 TC5 - Downstream grease-pack bearing TC upper location (installed near outer race) [OK]
% 206 TC6 - Downstream grease-pack bearing TC lower location (installed near outer race) [OK]
% 207 TC7 - Radial inflow support ceramic bearing TC [OK]
% 208 TC8 - Shaft TC 1 (inlet end) [OK]
% 209 TC9 - Shaft TC 2 [OK]
% 210 TC10 - Shaft TC 3 [OK]
% 211 TC11 - Shaft TC 4 [OK]
% 212 TC12 - Shaft TC 5 [OK]
% 213 TC13 - Shaft TC 6 [OK]
% 214 TC14 - Shaft TC 7 (exit end) [OK]
% 215 TC15 - ZR110 mass flow rate TC [OK]
% 216 TC16 - ZT250 mass flow rate TC [OK]
% 217 TC17 - Radial inflow delivery TC (not installed yet) [OK]
% 218 TC18 - Radial inflow mass flow rate TC, upper (NC)
% 219 TC19 - Radial inflow mass flow rate TC, lower (NC)
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
% Px 2 - Radial inflow delivery
% Px 3 - Radial inflow mass flow absolute pressure OP upper
% Px 4 - Radial inflow mass flow absolute pressure OP lower
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

%
% ZT250 massflow
%

% Geometry
do = 43.991e-3; % [m]
D = 78e-3; % [m]

% Measured variables
dp = (NI(:,20)-1)/4*1.865*1e5; % [Pa]
P = (Px(:,5))*1e5; % [Pa]
T = TC(:,16)+273.15; % [K]

m250 = OrificePlate_flange(D,do,dp,P,T);

%
% ZT110 massflow
%

% Geometry
do = 40.993e-3; % [m]
D = 78e-3; % [m]

% Measured variables
dp = (NI(:,19)-1)/4*0.373*1e5; % [Pa]
P = (Px(:,1))*1e5; % [Pa]
T = TC(:,15)+273.15; % [K]

m110 = OrificePlate_flange(D,do,dp,P,T);

%
% Radial inflow
%

if or( or(strcmp(run(4),'6'),strcmp(run(4),'5')) , strcmp(run(4),'4')) ,
    
    %
    % Tube 1
    %
    
    % Geometry terms
    do = 21.000e-3; % [m]
    D = 48e-3; % [m]
    
    % Measured variables
    dp = (NI(:,29)-4e-3)/16e-3*74.6/1000*1e5; % [Pa]
    P = (Px(:,4))*1e5; % [Pa]
    T = TC(:,15)+273.15; % [K] NB This uses the same TC as the ZR110 mass flow
    
    m_1 = OrificePlate_D_D2(D,do,dp,P,T);
    
    %
    % Tube 2
    %
    
    % Geometry terms
    do = 30.000e-3; % [m]
    D = 48e-3; % [m]
    
    % Measured variables
    dp = (NI(:,28)-4e-3)/16e-3*74.6/1000*1e5; % [Pa]
    P = (Px(:,3))*1e5; % [Pa]
    T = TC(:,15)+273.15; % [K] NB This uses the same TC as the ZR110 mass flow
    
    m_2 = OrificePlate_D_D2(D,do,dp,P,T);
    
    % Assemble the delivered mass flow
    TUBE  = NI(:,17);
    m_rad = TUBE.*m_1 + (1-TUBE).*m_2;
    
else
    m_rad = zeros(len,1);
end

%
% ND conditions
%

IDLE_MTO  = round(NI(:,15)/0.016-0.25);

m_bore = IDLE_MTO.*m250 + m110 - m_rad;

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
[~,mu_bore] = Sutherlands_air(T_bore);
axial_area = pi*(a^2 - r_s^2);
W_av = m_bore ./ ( axial_area * rho_bore);
DT_sh = (T_shroud - T_bore);
beta = 1./(T_bore+0.5*DT_sh); % need a better definition??

% Rotational Reynolds Number based on bore fluid conditions
Re_phi = ( rho_bore .* omega .* b^2 ) ./ mu_bore;

% Axial throughflow Reynolds Number based on bore conditions
Re_z = ( rho_bore .* W_av * 2 * (a - r_s) ) ./ mu_bore;

% Rossby Number based on the inner radius
Ro = W_av ./ (omega * a);

% Grashof b
Gr_b = (rho_bore.^2.*omega.^2 * b * (b - a)^3 .* beta .* DT_sh) ./ mu_bore .^2;

% Grashof sh
Gr_sh = (rho_bore.^2.*omega.^2 * b * (s/2)^3 .*beta .* DT_sh) ./ mu_bore .^2;




