%
% Iterative D and D/2 orifice plate calc with discharge coefficient from the Reader-Harris/Gallagher Eqn. (1998) - ISO 5167
%
% D orifice diamater [m]
% do tube diameter [m]
%
% P upstream pressure [Pa - abs]
% dp differential pressure [Pa - diff]
% T temperature [K]
%
% function [m] = OrificePlate_D_D2(D,do,dp,P,T)
%
% Discharge coefficient from the Reader-Harris/Gallagher Eqn. (1998) - ISO 5167
%
% NRA June 2011 
%
% v 0.1
%

function [m] = OrificePlate_D_D2(D,do,dp,P,T)

be = do/D; % [-]
E =1/sqrt(1-be^4); % [-]
EPS = 1; % Initial guess
L1 = D;
L2 = D/2;
M2 = 2*L2/(1-be); 

% Derived variables
rho = P./(287*T); % [kg m^-3]
mu = (T.^1.5*(0.00000145))./(T+110.33); % [Sutherlands law]

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
    
    % Expansibility coefficient
    expans = 1 - (0.351 + 0.256*be^4 + 0.93*be^8).*(1 - (P./(P-dp)).^(1/1.4));
    
    const =Cd/(1-be^4).*expans*pi/4*do^2;
    m = const.*abs(sqrt(dp*2.*rho));
    
    i = i+1;
    
end