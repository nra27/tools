%
% -- Blockplotter
%
grid = Tblock_getgridout;

% Number of grid lines to skip
skip = 2;

% List of colours to plot for each block

clr = ['k' 'c' 'm'];

% Loop over all ofthe blocks

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
set(gcf,'color',[1 1 1])   

