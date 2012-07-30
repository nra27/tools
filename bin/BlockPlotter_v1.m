%
% -- Blockplotter
%
grid = Tblock_getgridout;

% List of colours to plot for each block
clr = ['.--k' '.--k' '.--k'];

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
    plot3(squeeze(x(1,[1 jm],[1 km])),squeeze(y(1,[1 jm],[1 km])),squeeze(z(1,[1 jm],[1 km])),'.-k')
    hold on 
    plot3(squeeze(x(1,[1 jm],[1 km]))',squeeze(y(1,[1 jm],[1 km]))',squeeze(z(1,[1 jm],[1 km]))','.-k')
    
    % i = im face
    plot3(squeeze(x(im,[1 jm],[1 km])),squeeze(y(im,[1 jm],[1 km])),squeeze(z(im,[1 jm],[1 km])),'.-k')
    plot3(squeeze(x(im,[1 jm],[1 km]))',squeeze(y(im,[1 jm],[1 km]))',squeeze(z(im,[1 jm],[1 km]))','.-k')
    
    % j = 1 face
    plot3(squeeze(x([1 im],1,[1 km])),squeeze(y([1 im],1,[1 km])),squeeze(z([1 end],1,[1 km])),'.-k')
    plot3(squeeze(x([1 im],1,[1 km]))',squeeze(y([1 im],1,[1 km]))',squeeze(z([1 end],1,[1 km]))','.-k')
   
    % j = jm face
    plot3(squeeze(x([1 im],jm,[1 km])),squeeze(y([1 im],jm,[1 km])),squeeze(z([1 end],jm,[1 km])),'.-k')
    plot3(squeeze(x([1 im],jm,[1 km]))',squeeze(y([1 im],jm,[1 km]))',squeeze(z([1 end],jm,[1 km]))','.-k')
    
    
end

axis equal
axis off
    

