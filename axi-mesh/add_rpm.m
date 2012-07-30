%{
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               Add Patches - I, E, or P                %
%                         v1.0                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Author: sss44                     %
%                   Last mod: 25/3/2011                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      Input: block structure (b)       %
%                     Output: block structure (b)       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


            ______
            _\ _~-\___
    =  = ==(____AA____D
                \_____\___________________,-~~~~~~~`-.._
                /     o O o o o o O O o o o o o o O o  |\_
                `~-.__        ___..----..  Whittle Air     )
                      `---~~\___________/------------`````
                      =  ===(_________D



Notes: - RUN MATCH PATCH BEFORE RUNNING THIS !!!!!!!!!!
       - IT IS ASSUMED THAT THERE WILL NOT BE MORE THAN ONE INLET AND ONE EXIT PATCH PER BLOCK.
       CARD 53, 54, 55, 56.
       - DATA INPUT IN CARDS IS STORED AS ARRAYS!
%}

function [b]=add_rpm(b)
    
%% NUMBER OF BLOCKS
N=length(b);

% CALIBRATE PIXEL DATA
b=cavity_calibration(b);

rpm = 3600;

% DRAW FIGURE

B = imread([b(1).imgpathname,b(1).imgfilename]);
imagesc(B);
axis equal
hold on
set(gcf, 'Position', get(0,'Screensize')); % maximize figure


% DRAW FIGURE
for i=1:N
    % Pixels
    plot(b(i).px_x(1),b(i).px_r(1),'o')
    plot(b(i).px_x(2),b(i).px_r(2),'o')
    plot(b(i).px_x(3),b(i).px_r(3),'o')
    plot(b(i).px_x(4),b(i).px_r(4),'o')
    
    % NORTH FACE
    if b(1).IS_SET(i,1)==1;
        plot([b(i).px_x(1) b(i).px_x(2)] , [b(i).px_r(1),b(i).px_r(2)],'-r')
    elseif b(1).IS_SET(i,1)==2;
        plot([b(i).px_x(1) b(i).px_x(2)] , [b(i).px_r(1),b(i).px_r(2)],'-c')
    elseif b(1).IS_SET(i,1)==3;
        plot([b(i).px_x(1) b(i).px_x(2)] , [b(i).px_r(1),b(i).px_r(2)],'-g')
    elseif abs(b(i).RPMJM) > 0,
         plot([b(i).px_x(1) b(i).px_x(2)] , [b(i).px_r(1),b(i).px_r(2)], '-m','linewidth',3)
    else
        plot([b(i).px_x(1) b(i).px_x(2)] , [b(i).px_r(1),b(i).px_r(2)])
    end
    
    % EAST FACE
    if b(1).IS_SET(i,2)==1;
        plot([b(i).px_x(2) b(i).px_x(3)] , [b(i).px_r(2),b(i).px_r(3)],'-r')
    elseif b(1).IS_SET(i,2)==2;
        plot([b(i).px_x(2) b(i).px_x(3)] , [b(i).px_r(2),b(i).px_r(3)],'-c')
    elseif b(1).IS_SET(i,2)==3;
        plot([b(i).px_x(2) b(i).px_x(3)] , [b(i).px_r(2),b(i).px_r(3)],'-g')
    elseif abs(b(i).RPMIM) > 0,
         plot([b(i).px_x(2) b(i).px_x(3)] , [b(i).px_r(2),b(i).px_r(3)], '-m','linewidth',3)
    else
        plot([b(i).px_x(2) b(i).px_x(3)] , [b(i).px_r(2),b(i).px_r(3)])
    end
    
    % SOUTH FACE
    if b(1).IS_SET(i,3)==1;
        plot([b(i).px_x(3) b(i).px_x(4)] , [b(i).px_r(3),b(i).px_r(4)],'-r')
    elseif b(1).IS_SET(i,3)==2;
        plot([b(i).px_x(3) b(i).px_x(4)] , [b(i).px_r(3),b(i).px_r(4)],'-c')
    elseif b(1).IS_SET(i,3)==3;
        plot([b(i).px_x(3) b(i).px_x(4)] , [b(i).px_r(3),b(i).px_r(4)],'-g')
    elseif abs(b(i).RPMJ1) > 0,
         plot([b(i).px_x(3) b(i).px_x(4)] , [b(i).px_r(3),b(i).px_r(4)], '-m','linewidth',3)
    else
        plot([b(i).px_x(3) b(i).px_x(4)] , [b(i).px_r(3),b(i).px_r(4)])
    end
    
    % WEST FACE
    if b(1).IS_SET(i,4)==1;
        plot([b(i).px_x(4) b(i).px_x(1)] , [b(i).px_r(4),b(i).px_r(1)],'-r')
    elseif b(1).IS_SET(i,4)==2;
        plot([b(i).px_x(4) b(i).px_x(1)] , [b(i).px_r(4),b(i).px_r(1)],'-c')
    elseif b(1).IS_SET(i,4)==3;
        plot([b(i).px_x(4) b(i).px_x(1)] , [b(i).px_r(4),b(i).px_r(1)],'-g')
        elseif abs(b(i).RPMI1) > 0,
         plot([b(i).px_x(4) b(i).px_x(1)] , [b(i).px_r(4),b(i).px_r(1)], '-m','linewidth',3)
    else
        plot([b(i).px_x(4) b(i).px_x(1)] , [b(i).px_r(4),b(i).px_r(1)])
    end
    text(mean(b(i).px_x),mean(b(i).px_r),num2str(i),'fontsize',6,'color','red','fontweight','bold');
    % DISPLAY MESSAGES AND PICK POINT
    
axis equal


end
%%


title('Block layout. Press any key to continue','fontsize',14,'color','black','fontweight','bold')
pause

k = 1;

for k = 1:10,
    
title('Block layout. Click an edge to select it.','fontsize',14,'color','black','fontweight','bold')
[x0 r0] = ginput(1);


%% FIND EDGE

LIM_X=xlim;
LIM_R=ylim;
SHORTEST_DISTANCE=sqrt((LIM_X(1)-LIM_X(2))^2+(LIM_R(1)-LIM_R(2))^2);
NEAREST_EDGE=[1,1];
NEAREST_X=[0,0];
NEAREST_R=[0,0];
POLY_TOLERANCE=0.5; % SETS THE POLYGON TOLERANCE (PERCENTAGE OF THE DISTANCE BETWEEN THE TWO EDGE POINTS)
LOOP_EXIT=0;
while LOOP_EXIT==0
    for i=1:N
        for j=1:4
            x1=b(i).px_x(j) ; r1=b(i).px_r(j) ;
            if j==4
                x2=b(i).px_x(1) ; r2=b(i).px_r(1) ;
            else
                x2=b(i).px_x(j+1) ; r2=b(i).px_r(j+1) ;
            end
            SHORTEST_DISTANCE_CHECK=(abs( (x2-x1)*(r1-r0) - (x1-x0)*(r2-r1) ))/(sqrt( (x2-x1)^2 + (r2-r1)^2 ));
            % FINDS UNIT VECTOR NORMAL TO LINE BETWEEN X1 AND X2
            V_NORM(1)=r2-r1;
            V_NORM(2)=-(x2-x1);
            V_MAG=sqrt(V_NORM(1)^2+V_NORM(2)^2);
            V_NORM=V_NORM./V_MAG;
            % FINDS THE EDGES OF THE POLYGON
            POLY_DISTANCE=sqrt((x2-x1)^2+(r2-r1)^2);
            POLY_CHECK_X(1)=x1+POLY_TOLERANCE*(POLY_DISTANCE*V_NORM(1));
            POLY_CHECK_X(2)=x1-POLY_TOLERANCE*(POLY_DISTANCE*V_NORM(1));
            POLY_CHECK_X(3)=x2-POLY_TOLERANCE*(POLY_DISTANCE*V_NORM(1));
            POLY_CHECK_X(4)=x2+POLY_TOLERANCE*(POLY_DISTANCE*V_NORM(1));
            POLY_CHECK_R(1)=r1+POLY_TOLERANCE*(POLY_DISTANCE*V_NORM(2));
            POLY_CHECK_R(2)=r1-POLY_TOLERANCE*(POLY_DISTANCE*V_NORM(2));
            POLY_CHECK_R(3)=r2-POLY_TOLERANCE*(POLY_DISTANCE*V_NORM(2));
            POLY_CHECK_R(4)=r2+POLY_TOLERANCE*(POLY_DISTANCE*V_NORM(2));
            % CHECKS IF SELECTED POINT IS IN POLYGON
            IN_POLY=inpolygon(x0, r0, POLY_CHECK_X, POLY_CHECK_R);
            if SHORTEST_DISTANCE_CHECK <= SHORTEST_DISTANCE && IN_POLY(1,1)==1
                SHORTEST_DISTANCE=SHORTEST_DISTANCE_CHECK;
                NEAREST_X=[x1,x2];
                NEAREST_R=[r1,r2];
                NEAREST_EDGE=[i,j];
            end
        end
    end
    
    % IF NO MATCH IS FOUND A NEW POINT HAS TO BE SELECTED
    if SHORTEST_DISTANCE~=sqrt((LIM_X(1)-LIM_X(2))^2+(LIM_R(1)-LIM_R(2))^2)
        LOOP_EXIT=1;
    end
    if LOOP_EXIT==0
        title('Edge could not be selected. Press any key to try again.','fontsize',14,'color','black','fontweight','bold')
        pause
        title('Block layout. Click an edge to select it.','fontsize',14,'color','black','fontweight','bold')
        [x0 r0] = ginput(1);
    end
    
    b(i).RPMJM = 0; b(i).RPMIM = 0;  b(i).RPMJ1 = 0;  b(i).RPMI1 = 0;
    
end
                
plot([NEAREST_X(1), NEAREST_X(2)] , [NEAREST_R(1), NEAREST_R(2)], '-k','linewidth',6)

% FIND FACE
if NEAREST_EDGE(2)==1
    FACE='NORTH';
    b(NEAREST_EDGE(1)).RPMJM = rpm;
elseif NEAREST_EDGE(2)==2
    FACE='EAST';
    b(NEAREST_EDGE(1)).RPMIM = rpm;
elseif NEAREST_EDGE(2)==3
    FACE='SOUTH';
    b(NEAREST_EDGE(1)).RPMJ1 = rpm;
elseif NEAREST_EDGE(2)==4
    FACE='WEST'; 
    b(NEAREST_EDGE(1)).RPMI1 = rpm;
end 


    
    for i = 1:N,
        
        %
        % Rotation data
        %
        
        % CARD 59
        b(i).RPMBLOCK = 0; b(i).FMGRID = 0.4; b(i).XLLIM = 0.03; b(i).NSMALL_BLOCK = 3; b(i).NBIG_BLOCK = 9; b(i).ITRANS = 1; b(i). JTRANS = 1; b(i).KTRANS = 1; b(i).FREE_TURB = 0; b(i).XLLIM_FREE = 0.1; b(i).IF_NOSHEAR = 0; b(i).MIXL_TYPE = 3;
        
        % CARD 60
        
       b(i).RPMK1 = 0; b(i).RPMKM = 0;
        
    end
    beep
    
    pause
k = k +1 ;

end
end
