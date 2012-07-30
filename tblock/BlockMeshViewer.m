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

function BlockMeshViewer(grid,blocks)

% Loop over all of the blocks, plotting only the mesh
% if size(varargin(1))>= 0,
%     blk = varargin;
% else
%     blk = 1:grid.nblocks;
% end

skip = 1;

clr = ['m' 'c' 'y' 'b' 'g' 'k']; clr = [clr clr clr clr clr clr clr];clr = [clr clr clr clr clr clr clr];clr = [clr clr clr clr clr clr clr];

for i = 1:length(blocks),
    
    n = blocks(i);
    
    % Convert to r [m], th [rads]
    r = grid.block(n).r;
    t = -grid.block(n).rt./grid.block(n).r;
    
    % Convert to x y z to plot in Matlab cartesian
    x = grid.block(n).x;
    y = -r.*sin(t);
    z = r.*cos(t);
      
    % find the size of the blocks
    im = grid.block(n).im;
    jm = grid.block(n).jm;
    km = grid.block(n).km;
    
    % i = 1 face
    plot3(squeeze(x(1,[1:skip:jm],[1:skip:km])),squeeze(y(1,[1:skip:jm],[1:skip:km])),squeeze(z(1,[1:skip:jm],[1:skip:km])),clr(n))
    hold on 
    plot3(squeeze(x(1,[1:skip:jm],[1:skip:km]))',squeeze(y(1,[1:skip:jm],[1:skip:km]))',squeeze(z(1,[1:skip:jm],[1:skip:km]))',clr(n))
    
    % i = im face
    plot3(squeeze(x(im,[1:skip:jm],[1:skip:km])),squeeze(y(im,[1:skip:jm],[1:skip:km])),squeeze(z(im,[1:skip:jm],[1:skip:km])),clr(n))
    plot3(squeeze(x(im,[1:skip:jm],[1:skip:km]))',squeeze(y(im,[1:skip:jm],[1:skip:km]))',squeeze(z(im,[1:skip:jm],[1:skip:km]))',clr(n))
    
    % j = 1 face
    plot3(squeeze(x([1:skip:im],1,[1:skip:km])),squeeze(y([1:skip:im],1,[1:skip:km])),squeeze(z([1:skip:end],1,[1:skip:km])),clr(n))
    plot3(squeeze(x([1:skip:im],1,[1:skip:km]))',squeeze(y([1:skip:im],1,[1:skip:km]))',squeeze(z([1:skip:end],1,[1:skip:km]))',clr(n))
   
    % j = jm face
    plot3(squeeze(x([1:skip:im],jm,[1:skip:km])),squeeze(y([1:skip:im],jm,[1:skip:km])),squeeze(z([1:skip:end],jm,[1:skip:km])),clr(n))
    plot3(squeeze(x([1:skip:im],jm,[1:skip:km]))',squeeze(y([1:skip:im],jm,[1:skip:km]))',squeeze(z([1:skip:end],jm,[1:skip:km]))',clr(n))
    
end

axis equal
xlabel('i direction (m)')
set(gcf,'color',[1 1 1])   
