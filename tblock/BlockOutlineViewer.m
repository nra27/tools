%
% -- BlockOutlineViewer(grid)
%
% NRA Feb 2010
%
% Plots the block outline only
% 
% 'grid' is output from TblockGetGrid.m

function BlockOutlineViewer(grid,blocks)

% Loop over all of the blocks, plotting only the block outline

clr = ['k' 'm' 'c' 'y' 'g']; clr = [clr clr clr clr clr clr clr];
clr = [clr clr clr clr clr clr clr];clr = [clr clr clr clr clr clr clr];clr = [clr clr clr clr clr clr clr];
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
    plot3(squeeze(x(1,[1 jm],[1 km])),squeeze(y(1,[1 jm],[1 km])),squeeze(z(1,[1 jm],[1 km])),clr(n))
    hold on 
    plot3(squeeze(x(1,[1 jm],[1 km]))',squeeze(y(1,[1 jm],[1 km]))',squeeze(z(1,[1 jm],[1 km]))',clr(n))
    
    % i = im face
    plot3(squeeze(x(im,[1 jm],[1 km])),squeeze(y(im,[1 jm],[1 km])),squeeze(z(im,[1 jm],[1 km])),clr(n))
    plot3(squeeze(x(im,[1 jm],[1 km]))',squeeze(y(im,[1 jm],[1 km]))',squeeze(z(im,[1 jm],[1 km]))',clr(n))
    
    % j = 1 face
    plot3(squeeze(x([1 im],1,[1 km])),squeeze(y([1 im],1,[1 km])),squeeze(z([1 end],1,[1 km])),clr(n))
    plot3(squeeze(x([1 im],1,[1 km]))',squeeze(y([1 im],1,[1 km]))',squeeze(z([1 end],1,[1 km]))',clr(n))
   
    % j = jm face
    plot3(squeeze(x([1 im],jm,[1 km])),squeeze(y([1 im],jm,[1 km])),squeeze(z([1 end],jm,[1 km])),clr(n))
    plot3(squeeze(x([1 im],jm,[1 km]))',squeeze(y([1 im],jm,[1 km]))',squeeze(z([1 end],jm,[1 km]))',clr(n))
    
end

axis equal
xlabel('i direction (m)')
set(gcf,'color',[1 1 1])   
   

