%
% -- BlockperiodicViewer(grid,skip)
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

function BlockPeriodicViewer(grid,skip)


clr = ['k' 'm' 'r' 'b' 'g']; clr = [clr clr clr clr clr clr clr];

for n = 1:grid.nblocks,
    
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
    
    % k = 1 face
    plot(squeeze(x([1:skip:im],[1:skip:jm],1)),squeeze(r([1:skip:im],[1:skip:jm],1)),clr(n))
    hold on
    plot(squeeze(x([1:skip:im],[1:skip:jm],1))',squeeze(r([1:skip:im],[1:skip:jm],1))',clr(n))
     
    
end

axis equal
axis off
set(gcf,'color',[1 1 1])   

