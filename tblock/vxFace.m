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

function vxFace(grid,flow,skip)

% Loop over all of the blocks, plotting only the mesh
% if size(varargin(1))>= 0,
%     blk = varargin;
% else
%     blk = 1:grid.nblocks;
% end

close all

clr = ['k' 'm' 'c' 'y' 'g']; clr = [clr clr clr clr clr clr clr];

for n = 1:1:grid.nblocks,
    
    % Convert to r [m], th [rads]
    r = grid.block(n).r;
    t = -grid.block(n).rt./grid.block(n).r;
    
    % Convert to x y z to plot in Matlab cartesian
    x = grid.block(n).x;
    y = -r.*sin(t);
    z = r.*cos(t);
    
    var = flow.block(n).rovx./flow.block(n).ro;
    
    % find the size of the blocks
    im = grid.block(n).im;
    jm = grid.block(n).jm;
    km = grid.block(n).km;
    
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
xlabel('i direction (m)')
set(gcf,'color',[1 1 1])   

