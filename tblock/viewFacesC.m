%
% -- viewFacesC(grid,flow,flow_type,skip)
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

function viewFacesC(grid,flow,data_type,skip)

% Loop over all of the blocks, plotting only the mesh
% if size(varargin(1))>= 0,
%     blk = varargin;
% else
%     blk = 1:grid.nblocks;
% end

close all
clr = ['k' 'm' 'c' 'y' 'g']; clr = [clr clr clr clr clr clr clr];
skip = 1;

for n = 1:1:grid.nblocks,
    
    % Convert to r [m], th [rads]
    r = grid.block(n).r;
    t = -grid.block(n).rt./grid.block(n).r;
    
    % Convert to x y z to plot in Matlab cartesian
    x = grid.block(n).x;
    y = -r.*sin(t);
    z = r.*cos(t);
    
    cv = flow.cp/flow.ga;
    R = flow.cp*(flow.ga-1)/flow.ga;
    pref = 1e5;
    Tref = 298;
    
    vx = flow.block(n).rovx./flow.block(n).ro;
    vr = flow.block(n).rovr./flow.block(n).ro;
    vt = flow.block(n).rorvt./(flow.block(n).ro.*r);
    eke = 0.5*(vx.^2+vr.^2+vt.^2);
    T = (flow.block(n).roe./flow.block(n).ro - eke)/cv;
    p = flow.block(n).ro*R.*T;
    T0 = T + eke/flow.cp;
    P0 = p.*(T0./T).^(flow.ga/(flow.ga-1));
    s = flow.cp*log(T0./Tref)-R.*log(p./pref);
  
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
    end
    
    % tbc! 
    
    % find the size of the blocks
    im = grid.block(n).im;
    jm = grid.block(n).jm;
    km = grid.block(n).km;
    
    % i = 1 face
    fill3(squeeze(x(1,[1:skip:jm],[1:skip:km])), ...
         squeeze(y(1,[1:skip:jm],[1:skip:km])), ...
         squeeze(z(1,[1:skip:jm],[1:skip:km])), ...
       squeeze(var(1,[1:skip:jm],[1:skip:km])))
    
    hold on
    
    % i = im face
    fill3(squeeze(x(im,[1:skip:jm],[1:skip:km])), ...
         squeeze(y(im,[1:skip:jm],[1:skip:km])), ...
         squeeze(z(im,[1:skip:jm],[1:skip:km])), ...
       squeeze(var(im,[1:skip:jm],[1:skip:km])))
    
    % j = 1 face
    fill3(squeeze(x([1:skip:im],1,[1:skip:km])), ...
         squeeze(y([1:skip:im],1,[1:skip:km])), ...
         squeeze(z([1:skip:im],1,[1:skip:km])), ...
       squeeze(var([1:skip:im],1,[1:skip:km])))
      
    % j = jm face
    fill3(squeeze(x([1:skip:im],jm,[1:skip:km])), ...
         squeeze(y([1:skip:im],jm,[1:skip:km])), ...
         squeeze(z([1:skip:im],jm,[1:skip:km])), ...
       squeeze(var([1:skip:im],jm,[1:skip:km])))
  
    % k = 1 face
    fill3(squeeze(x([1:skip:im],[1:skip:jm],1)), ...
         squeeze(y([1:skip:im],[1:skip:jm],1)), ...
         squeeze(z([1:skip:im],[1:skip:jm],1)), ...
       squeeze(var([1:skip:im],[1:skip:jm],1)))
  
    % k = km face
    fill3(squeeze(x([1:skip:im],[1:skip:jm],km)), ...
         squeeze(y([1:skip:im],[1:skip:jm],km)), ...
         squeeze(z([1:skip:im],[1:skip:jm],km)), ...
       squeeze(var([1:skip:im],[1:skip:jm],km)))
     
end

axis equal
colorbar
title(data_type)
shading flat
xlabel('i direction (m)')
set(gcf,'color',[1 1 1])   

