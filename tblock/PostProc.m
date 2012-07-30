%
% [grid,flow] = PostProc(grid,flow)
%
% Writes the full fluid dynamic variables into the file
%

function [grid,flow] = PostProc(grid,flow)

for n = 1:grid.nblocks,
           
    % Convert to r [m], t [rads]
    grid.block(n).t = -grid.block(n).rt./grid.block(n).r;
    
    % Convert to x y z to plot in Matlab cartesian
    grid.block(n).y = -grid.block(n).r.*sin(grid.block(n).t);
    grid.block(n).z = grid.block(n).r.*cos(grid.block(n).t);
    
    % Gas stuff
    cv = flow.cp/flow.ga;
    R = flow.cp*(flow.ga-1)/flow.ga;
    ga = flow.ga;
    
    % For entropy calc.
    pref = 1e5;
    Tref = 298;
    
    % Tidy up and proc - single block so probably ok for now.
    flow.block(n).vx = flow.block(n).rovx./flow.block(n).ro;
    flow.block(n).vr = flow.block(n).rovr./flow.block(n).ro;
    flow.block(n).vt = flow.block(n).rorvt./(flow.block(n).ro.*grid.block(n).r);
    flow.block(n).eke = 0.5*(flow.block(n).vx.^2+flow.block(n).vr.^2+flow.block(n).vt.^2);
    flow.block(n).T = (flow.block(n).roe./flow.block(n).ro - flow.block(n).eke)/cv;
    flow.block(n).p = flow.block(n).ro*R.*flow.block(n).T;
    flow.block(n).P0  = flow.block(n).ro*R.*flow.block(n).T;
    flow.block(n).T0 = flow.block(n).T + flow.block(n).eke/flow.cp;
    flow.block(n).P0 = flow.block(n).p.*(flow.block(n).T0./flow.block(n).T).^(flow.ga/(flow.ga-1));
    flow.block(n).s = flow.cp*log(flow.block(n).T0./Tref)-R.*log(flow.block(n).p./pref);
    flow.block(n).b = flow.block(n).vt./(grid.block(n).r*(100*pi));
    flow.block(n).vsec = (flow.block(n).vx.^2 + flow.block(n).vr.^2) .^0.5;
    flow.block(n).M = ( (2/(ga-1))*(  ( flow.block(n).P0./flow.block(n).p ).^((ga-1)/ga)-1)  ).^0.5;
    
end