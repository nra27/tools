%
% [c_area,c_rovx,mass_x] = mass(grid,flow,blocks,i_val)
%
% NRA Feb 2010
%
% tbc
%
% Remember, you can't always get what you want....
%

function [c_area,c_rovx,mass_x] = mass(grid,flow,blocks,i_val)


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
     
    % find the size of the blocks
    im = grid.block(n).im;
    jm = grid.block(n).jm;
    km = grid.block(n).km;
    
    % Jump to cell based data
    
    % find area of the faces on an i = i_val plane
 
    % ck, cj is the cell counter starting with the j,k (1,1) and (2,2)
    % cornered cell works from the bottom corner, needs refining for skewed
    % grids!!!
   
    for ck = 1:km-1,
        for cj = 1:jm-1,
       
        dr(cj,ck) = (r(i_val,cj+1,ck)-r(i_val,cj,ck));
        dt(cj,ck) = -((t(i_val,cj,ck+1))-t(i_val,cj,ck));
        
        % Cell based area da = r.dr.dt
        c_area(cj,ck) = r(i_val,cj,ck)*dr(cj,ck)*dt(cj,ck);
        
        % Cell based rovx (crude average of four corners, not weighted)
        c_rovx(cj,ck) = 1/4*(flow.block(n).rovx(i_val,cj,ck) + ...
                        flow.block(n).rovx(i_val,cj+1,ck) + ...
                        flow.block(n).rovx(i_val,cj,ck+1) + ...
                        flow.block(n).rovx(i_val,cj+1,ck+1) );
        end
    end
    
    mass_x(n) = sum(sum(c_area.*c_rovx));
  
     % find area of the faces on an j = j_val plane
 
%     % ck, ci is the cell counter starting with the j,i (1,1) and (2,2)
%     % cornered cell works from the bottom corner, needs refining for skewed
%     % grids!!!
%    
%     for ck = 1:km-1,
%         for ci = 1:im-1,
%        
%         dx(ci,ck) = (r(ci+1,j_val,ck)-r(ci,j_val,ck));
%         dt(ci,ck) = -((t(ci,j_val,ck+1))-t(ci,j_val,ck));
%         
%         % Cell based area da = r.dr.dt
%         c_arear(ci,ck) = dx(ci,j_val,ck)*r(ci,ck)*dt(ci,ck);
%         
%         % Cell based rovx (crude average of four corners, not weighted)
%         c_rovr(ci,ck) = 1/4*(flow.block(n).rovr(ci,j_val,ck) + ...
%                         flow.block(n).rovr(ci+1,j_val,ck) + ...
%                         flow.block(n).rovr(ci,j_val,ck+1) + ...
%                         flow.block(n).rovr(ci+1,j_val,ck+1) );
%         end
%     end
%     
%     mass_r(n) = sum(sum(c_arear.*c_rovr));
end