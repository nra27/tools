function [M_blade, M_exit, Whirl] = Mach_Plot(run_name);

[surface_data,flow_data] = Read_ADF_Data('input/HPB_1.3.grid.1.adf',run_name);

load input/midspan.mat

flow_data = Calculate_Po(flow_data,0);
flow_data = Calculate_Whirl_Angle(flow_data,0);

xmin = min(flow_data.coordinates(midspan,1));
xmax = max(flow_data.coordinates(midspan,1));
cax = xmax-xmin;
prex = (flow_data.coordinates(midspan,1)-xmin)/cax;

P_tot = Bulk_Circumferential_Average(0.043,0.25,flow_data,'total pressure');
P_stat = Bulk_Circumferential_Average(xmax+0.65*cax,0.25,flow_data,'pressure');
Whirl = Bulk_Circumferential_Average(0.043,0.25,flow_data,'whirl angle');

P_blade = flow_data.flow(midspan,5);
P_blade = P_blade.*(P_blade < P_tot) + P_tot.*(P_blade >= P_tot);

M_exit = sqrt(((P_tot/P_stat)^(0.4/1.4)-1)*2/0.4);
M_blade = sqrt(((P_tot./P_blade).^(0.4/1.4)-1)*2/0.4);

title(['Mach = ' num2str(M_exit) ', Incidence = ' num2str(Whirl) '\circ']);
xlabel('X / Cax');
ylabel('Surface Mach Number');

plot(prex,M_blade,'r.');
