function [stab_cruise_clr,stab_MTO_clr,worst_decel_clr,worst_accel_clr] = func_closure_mm_stage5_new(dfact,cfact)

% Load the environemtal parameters
[rpm_IDLE,rpm_MTO,rpm_CRUISE,T26_IDLE,T26_MTO,T26_CRUISE,T30_IDLE,T30_MTO,T30_CRUISE,t,t0,t1,t2,t3] = envParams('T1000');

t2=t2-9;
pulse_train = ones(1,length(t));

stage = 5;

% stage 5 parameters 
radius = 0.3587;
blade_height = 0.036;
alpha_casing = 1*0.99e-6; % ^-K
k_drum = 568.986;
E = 110e9; % Pa

tau_casing_idle = 28; % s
tau_drum_idle = 423; % s
Xd_idle = 1.4698;
Xc_idle = 1.156;
casing_delay_idle = 21; drum_delay_idle = casing_delay_idle;

tau_casing_accel = 59; % s
tau_drum_accel = 76;
Xd_accel=-0.46166;
Xc_accel=-1.2665;

tau_casing_decel = 22; % s
tau_drum_decel = 387; 
Xd_decel=0.7834;
Xc_decel=1.5585;

tau_drum_cruise = 180;
tau_casing_cruise = 9;
Xd_cruise=0.3458;
Xc_cruise=0.43;

% speed setup
rpm = rpm_IDLE ...
    + ClosureModel_delay((rpm_MTO-rpm_IDLE)*pulse_train,t1)...
    - ClosureModel_delay((rpm_MTO-rpm_IDLE)*pulse_train,t2)...
    + ClosureModel_delay((rpm_CRUISE-rpm_IDLE)*pulse_train,t3);

Hd = rpm_filter;
rpm = filtfilt(Hd.Numerator,1,rpm);

% CF growth of the drum
d_cf = k_drum/E*rpm.^2;
 
% Thermal growths. NB x1000 for mm
t_casing = 288.15+[ClosureModel_delay(Xc_idle*(T30_IDLE - 288.15)*(1-exp(-(t-t0-casing_delay_idle)./(cfact*tau_casing_idle))),t0+casing_delay_idle) ...
    + ClosureModel_delay(Xc_accel*(T30_MTO-T30_IDLE)*(1-exp(-(t-t1)./(cfact*tau_casing_accel))),t1) ...
    - ClosureModel_delay(Xc_decel*(T30_MTO-T30_IDLE)*(1-exp(-(t-t2)./(cfact*tau_casing_decel))),t2) ...
    + ClosureModel_delay(Xc_cruise*(T30_CRUISE-T30_IDLE)*(1-exp(-(t-t3)./(cfact*tau_casing_cruise))),t3)]*1000;

d_casing = alpha_casing*t_casing;

Trotor_idle = Xd_idle*(T26_IDLE - 288.15)+288.15;
Trotor_acel = Xd_accel*(T26_MTO-T26_IDLE)+288.15;
Trotor_decel = Xd_decel*(T26_MTO-T26_IDLE)+288.15;
Trotor_cruise = Xd_cruise*(T26_CRUISE-T26_IDLE)+288.15;

t_drum = 288.15+[ClosureModel_delay((Trotor_idle-288.15)*(1-exp(-(t-t0-drum_delay_idle)./(dfact*tau_drum_idle))),t0+drum_delay_idle)  ...
    + ClosureModel_delay((Trotor_acel-288.15)*(1-exp(-(t-t1)./(dfact*tau_drum_accel))),t1) ...
    - ClosureModel_delay((Trotor_decel-288.15)*(1-exp(-(t-t2)./(dfact*tau_drum_decel))),t2) ...
    + ClosureModel_delay((Trotor_cruise-288.15)*(1-exp(-(t-t3)./(dfact*tau_drum_cruise))),t3)]*1000;

% Variable alpha
alphaD = alphaDrum(t_drum);

% drum displacement
d_drum = radius*alphaD'.*t_drum;

closure = d_casing-(d_cf+d_drum);

% Plot the characteristics

lw = 1; % line width

%subplot(2,1,1)
plot(t,(d_casing-(d_cf+d_drum)),'k','linewidth',lw); 
hold on
load T1000_sc03.mat
plot(t_T1000,stage5_clr)
axis([0 8000 -1.5 0])
%axis(a)

%
% Calculate the CBC
%

RS_pt = find(closure==min(closure(4030:5800))); % hot reslam point

d_cf_fhrs = k_drum/E*(rpm_MTO^2-rpm_IDLE^2);

c_fhrs = closure(RS_pt)-(d_cf_fhrs); % add reslam cf growth

worst_pt = find(closure==min(closure));
c_worst = closure(worst_pt(1));

CBC = mean([c_fhrs c_worst]);

plot(RS_pt,CBC,'x','MarkerSize',6)
plot([RS_pt RS_pt],[closure(RS_pt) (c_fhrs)],'.r')
plot([RS_pt RS_pt],[closure(RS_pt) (c_fhrs)],'-k')
plot(worst_pt(1),c_worst,'.m')

grid on; ylabel('Closure (mm)'); xlabel('Time (s)')
title(['Clousure behaviour - Stage ' num2str(stage)])
legend('Lumped model','SC03','CBC')

% %
% % Plot the clearance
% %
subplot(2,1,2)
clearance = (-CBC+closure);

plot(t,clearance/25*100,'k','linewidth',lw); 
grid on 
hold on
ylabel('% Clearance [-]'); xlabel('Time (s)')
axis([0 8000 0 8])


% worst case accel clearance (surge point)
surge_pt = find(clearance==max(clearance(2015:2500)))
plot(surge_pt,c_worst,'.m')

worst_accel_clr = clearance(surge_pt)
worst_decel_clr = clearance(RS_pt)
stab_MTO_clr = clearance(3999)
stab_cruise_clr = clearance(10000)

subplot(2,1,1)
plot(surge_pt,closure(surge_pt),'.c')
%axis(a)
