%
% -- viewFaces(grid,flow,flow_type,skip)
%
% NRA Feb 2010
%
% Plots the solution on the i = 1 & im, j = 1 & jm and k = 1 & km faces
% 
% 'grid' is output from TblockGetGrid.m
% 'flow' is output from TblockGetFlow.m
%   
% Specify the data type - see below for details!
%
% Remember, you can't always get what you want....
%

function plotiface(grid,flow,blocks,data_type,i_val)


clr = ['k' 'm' 'c' 'y' 'g']; clr = [clr clr clr clr clr clr clr];
skip = 1;
N = 3000; % WARNING!!! Hard coded for 50 Hz MHI turbine 

for i = 1:length(blocks),
    
    n = blocks(i);
    
    % Convert to r [m], t [rads]
    r = grid.block(n).r;
    t = -grid.block(n).rt./grid.block(n).r;
    
    % Convert to x y z to plot in Matlab cartesian
    x = grid.block(n).x;
    y = -r.*sin(t);
    z = r.*cos(t);
    
    % Gas stuff
    cv = flow.cp/flow.ga;
    R = flow.cp*(flow.ga-1)/flow.ga;
    
    % For entropy calc.
    pref = 1e5;
    Tref = 298;
    
    % Tidy up and proc - single block so probably ok for now.
    vx = flow.block(n).rovx./flow.block(n).ro;
    vr = flow.block(n).rovr./flow.block(n).ro;
    vt = flow.block(n).rorvt./(flow.block(n).ro.*r);
    eke = 0.5*(vx.^2+vr.^2+vt.^2);
    T = (flow.block(n).roe./flow.block(n).ro - eke)/cv;
    p = flow.block(n).ro*R.*T;
    T0 = T + eke/flow.cp;
    P0 = p.*(T0./T).^(flow.ga/(flow.ga-1));
    s = flow.cp*log(T0./Tref)-R.*log(p./pref);
  
    % Choose the datatype
    if data_type == 's',
        var = s;
        disp('Plotting Entropy')
    elseif data_type == 'P0',
        var = P0./1e5;
        disp('Plotting total Pressure - (bar)')
    elseif data_type == 'T0',
        var = T0;
        disp('Plotting total temperature')
    elseif data_type == 'vx',
        var = vx;
        disp('x - velocity (ms^-1)')
    elseif data_type == 'vr',
        var = vr;
        disp('r - velocity (ms^-1)')  
    elseif data_type == 'vt',
        var = vt;
        disp('theta - velocity (ms^-1)') 
    elseif data_type == 'p',
        var = p./1e5;
        disp('static pressure - (bar)') 
    elseif data_type == 'b',
        var = vt./(r*(N/60*2*pi));
        disp('swirl ratio') 
    end
    % Mach number etc etc tbc!
    
    % find the size of the blocks
    im = grid.block(n).im;
    jm = grid.block(n).jm;
    km = grid.block(n).km;
         
    % i = i_val face
        pcolor(squeeze(x(i_val,1:skip:jm,[1:skip:km])), ...
        squeeze(t(i_val,[1:skip:jm],[1:skip:km])), ...
         squeeze(var(i_val,[1:skip:jm],[1:skip:km])))
    %pcolor(squeeze(var([1:skip:im],jval,[1:skip:km])));
 
     
end

axis equal
colorbar
title(data_type)
%shading flat
xlabel('i direction (m)')
set(gcf,'color',[1 1 1])   

