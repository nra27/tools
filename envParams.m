%
% Function to return the environmetal parameters for each engine
%
% [rpm_IDLE,rpm_MTO,rpm_CRUISE,T26_IDLE,T26_MTO,T26_CRUISE] = ...
%                 envParams(engine)
%
% valid arguments for engine can be '__524' or 'T1000'
%
% NRA 26/07/2008
%

function [rpm_IDLE,rpm_MTO,rpm_CRUISE,T26_IDLE,T26_MTO,T26_CRUISE,T30_IDLE,T30_MTO,T30_CRUISE,t,t0,t1,t2,t3] = envParams(engine)

if engine == 'T1000',

    % Spool speed in rpm
    rpm_IDLE = 886.228/(2*pi)*60; % NH should be 866.31????
    rpm_MTO = 1293.6/(2*pi)*60; % NH
    rpm_CRUISE = 1257.75/(2*pi)*60; % NH

    % Fluid Temperatures in Kelvin
    T26_IDLE = 350.859; % T26 ???
    T26_MTO = 599.61; % T26 ???
    T26_CRUISE = 582.206; % NB guess

    T30_IDLE = 516.13;
    T30_MTO = 909.119;
    T30_CRUISE = 876.20;
    
    % Time vector setup
    t = 1:10000;
    t0 = 0;
    t1 = 2009;
    t2 = 3288.25;
    t3 = 5280.45;
    
else if engine == '__524',
    
        % Spool speed in rpm
    rpm_IDLE = 886.228/(2*pi)*60; % NH should be 866.31????
    rpm_MTO = 1293.6/(2*pi)*60; % NH
    rpm_CRUISE = 1257.75/(2*pi)*60; % NH

    % Fluid Temperatures in Kelvin
    T26_IDLE = 350.859; % T26 ???
    T26_MTO = 599.61; % T26 ???
    T26_CRUISE = 582.206; % NB guess

    T30_IDLE = 516.13;
    T30_MTO = 909.119;
    T30_CRUISE = 876.20;
    
    % Time vector setup
    t = 1:8000;
    t0 = 0;
    t1 = 2005;
    t2 = 3100;
    t3 = 5000;

else end
end

    