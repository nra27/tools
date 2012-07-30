
root = '/users/hydra/RT27a/3D/stage_calcs/STAGE_STEP/grid_files';

% D = Read_Blade_File([root '/NGV/padram/Blade_Definition_NGV_short_NRA.dat']);
% % Plot NGV annulus profile
% casing = D.n_sections;
% plot(D.section(casing).streamline(:,1),D.section(casing).streamline(:,2),'m.-')
% hold on
% plot(D.section(casing-1).streamline(:,1),D.section(casing-1).streamline(:,2),'m.-')
% plot(D.section(1).streamline(:,1),D.section(1).streamline(:,2),'m.-')


E = Read_Blade_File([root '/NGV/padram/Blade_Definition_NGV_short_NRA_STEP.dat']);
% Plot NGV annulus profile
casing = E.n_sections;
plot(E.section(casing).streamline(:,1),E.section(casing).streamline(:,2),'k')
hold on
%plot(E.section(casing-1).streamline(:,1),E.section(casing-1).streamline(:,2),'m.-')
plot(E.section(1).streamline(:,1),E.section(1).streamline(:,2),'k')

F = Read_Blade_File([root '/HPB/padram/Blade_Definition_HPB_short_NRA_para.dat']);
% Plot HPB annulus profile
casing = F.n_sections;
plot(F.section(casing).streamline(:,1),F.section(casing).streamline(:,2),'k')
hold on
%plot(F.section(casing-1).streamline(:,1),F.section(casing-1).streamline(:,2),'.-r')
plot(F.section(1).streamline(:,1),F.section(1).streamline(:,2),'k')

axis equal
grid on

title('Annulus Lines from the short blade definition files for the plain and step cases')