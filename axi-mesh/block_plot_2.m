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

function block_plot_2(b)
    
%% NUMBER OF BLOCKS
N=length(b);

% CALIBRATE PIXEL DATA
b=cavity_calibration(b);

% DRAW FIGURE
B = imread([b(1).imgpathname,b(1).imgfilename]);
imagesc(B);
axis equal
hold on
set(gcf, 'Position', get(0,'Screensize')); % maximize figurew

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
    text(mean(b(i).px_x),mean(b(i).px_r),num2str(i),'fontsize',10,'color','red','fontweight','bold');
    % DISPLAY MESSAGES AND PICK POINT
    
axis equal


end
%%


end
