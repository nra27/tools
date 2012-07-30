function Write_Gambit_Blade_File(blade);

sections = [1:19 50:81];

flip = (1-2*blade.flip);

% Form base profile
x = blade.section(1).profile(:,3)*1000;
y = blade.section(1).profile(:,1).*cos(blade.section(1).profile(:,2))*1000;
z = blade.section(1).profile(:,1).*sin(blade.section(1).profile(:,2))*1000*flip;

[te,te_i] = max(x);

SS = cumsum(sqrt(x(1:te_i).^2+y(1:te_i).^2+z(1:te_i).^2));
SS = SS/SS(end);

PS = cumsum(sqrt(x(te_i:end).^2+y(te_i:end).^2+z(te_i:end).^2));
PS = PS/PS(end);

filename = ['HPB' num2str(1) '.dat'];
fid = fopen(filename,'w');

for j = 1:length(x)-1
    fprintf(fid,' %14.10f %14.10f %14.10f \n',[x(j) y(j) z(j)]);
end
fclose(fid);

% For each blade profile
for i = 2:length(sections)
    filename = ['HPB' num2str(i) '.dat'];
    fid = fopen(filename,'w');
    
    k = sections(i);
    
    x = blade.section(k).profile(:,3)*1000;
    y = blade.section(k).profile(:,1).*cos(blade.section(k).profile(:,2))*1000;
    z = blade.section(k).profile(:,1).*sin(blade.section(k).profile(:,2))*1000*flip;
    
    [te,te_i] = max(x);

    ss = cumsum(sqrt(x(1:te_i).^2+y(1:te_i).^2+z(1:te_i).^2));
    ss = ss/ss(end);
    
    ps = cumsum(sqrt(x(te_i:end).^2+y(te_i:end).^2+z(te_i:end).^2));
    ps = ps/ps(end);
    
    xs = interp1(ss,x(1:te_i),SS,'spline');
    ys = interp1(ss,y(1:te_i),SS,'spline');
    zs = interp1(ss,z(1:te_i),SS,'spline');
    
    xp = interp1(ps,x(te_i:end),PS,'spline');
    yp = interp1(ps,y(te_i:end),PS,'spline');
    zp = interp1(ps,z(te_i:end),PS,'spline');
    
    x = [xs;xp(2:end)];
    y = [ys;yp(2:end)];
    z = [zs;zp(2:end)];
    
    for j = 1:length(x)-1
        fprintf(fid,' %14.10f %14.10f %14.10f \n',[x(j) y(j) z(j)]);
    end
    
    fclose(fid);
end