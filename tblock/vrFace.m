%
% -- BlockMeshViewer(grid,skip,[blocks])
%
% NRA Feb 2010
%
% Plots the mesh, with skips
% 
% 'grid' is output from TblockGetGrid.m
%
% Leave n out to get the whole mesh
% 
% Specify a range to get what you need
%
% Remember, you can't always get what you want....
%

function viewFaces(grid,flow_type,skip)

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
    
    cv = flow.cp/flow.ga
    R = flow.cp*(flow.ga-1)/flow.ga
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
  
    size(s)
    
    if flow_type == 's',
        var = s;
        disp('Plotting Entropy')
    elseif flow_type == 'P0',
        var = P0;
        disp('Plotting total Pressure')
    elseif flow_type == 'T0',
        var = T0;
        disp('Plotting total temperature')
    elseif flow_type == 'vx',
        var = vx;
        disp('x - velocity (ms^-1)')
    elseif flow_type == 'vr',
        var = vr;
        disp('r - velocity (ms^-1)')  
    elseif flow_type == 'vt',
        var = vt;
        disp('theta - velocity (ms^-1)') 
    end
    
    
    % find the size of the blocks
    im = grid.block(n).im
    jm = grid.block(n).jm
    km = grid.block(n).km
    
    % i = 1 face
    surf(squeeze(x(1,[1:skip:jm],[1:skip:km])), ...
         squeeze(y(1,[1:skip:jm],[1:skip:km])), ...
         squeeze(z(1,[1:skip:jm],[1:skip:km])), ...
       squeeze(var(1,[1:skip:jm],[1:skip:km])))
    
     hold on
    
    % i = im face
    surf(squeeze(x(im,[1:skip:jm],[1:skip:km])), ...
         squeeze(y(im,[1:skip:jm],[1:skip:km])), ...
         squeeze(z(im,[1:skip:jm],[1:skip:km])), ...
       squeeze(var(im,[1:skip:jm],[1:skip:km])))
    
    % j = 1 face
    surf(squeeze(x([1:skip:im],1,[1:skip:km])), ...
         squeeze(y([1:skip:im],1,[1:skip:km])), ...
         squeeze(z([1:skip:im],1,[1:skip:km])), ...
       squeeze(var([1:skip:im],1,[1:skip:km])))
      
    % j = jm face
    surf(squeeze(x([1:skip:im],jm,[1:skip:km])), ...
         squeeze(y([1:skip:im],jm,[1:skip:km])), ...
         squeeze(z([1:skip:im],jm,[1:skip:km])), ...
       squeeze(var([1:skip:im],jm,[1:skip:km])))
  
    % k = 1 face
    surf(squeeze(x([1:skip:im],[1:skip:jm],1)), ...
         squeeze(y([1:skip:im],[1:skip:jm],1)), ...
         squeeze(z([1:skip:im],[1:skip:jm],1)), ...
       squeeze(var([1:skip:im],[1:skip:jm],1)))
  
    % k = km face
    surf(squeeze(x([1:skip:im],[1:skip:jm],km)), ...
         squeeze(y([1:skip:im],[1:skip:jm],km)), ...
         squeeze(z([1:skip:im],[1:skip:jm],km)), ...
       squeeze(var([1:skip:im],[1:skip:jm],km)))
  
    
    
end

axis equal
colorbar
title(flow_type)
xlabel('i direction (m)')
set(gcf,'color',[1 1 1])   
