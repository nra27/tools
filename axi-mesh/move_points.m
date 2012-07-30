%{
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      Move Points                      %
%                         v1.0                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Author: sss44                     %
%                   Last mod: 23/3/2011                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      Input: block structure (b)       %
%                     Output: block structure (b)       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            ---------------+---------------                                                
                      ___ /^^[___              _                                           
                     /|^+----+   |#___________//                                           
                   ( -+ |____|    ______-----+/                                            
                    ==_________--'            \                                            
                      ~_|___|__    


%}
%%
function [b]=move_points(b)
%% NUMBER OF BLOCKS
N=length(b);
%% DRAW POINTS

B = imread([b(1).imgpathname,b(1).imgfilename]);
imagesc(B);
axis equal
hold on 
set(gcf, 'Position', get(0,'Screensize')); 


        for i=1:N
        % Pixels

        plot(b(i).px_x(1),b(i).px_r(1),'o')
        plot(b(i).px_x(2),b(i).px_r(2),'o')
        plot(b(i).px_x(3),b(i).px_r(3),'o')
        plot(b(i).px_x(4),b(i).px_r(4),'o')
        % NORTH FACE
        plot([b(i).px_x(1) b(i).px_x(2)] , [b(i).px_r(1),b(i).px_r(2)])
        % EAST FACE
        plot([b(i).px_x(2) b(i).px_x(3)] , [b(i).px_r(2),b(i).px_r(3)])   
        % SOUTH FACE
        plot([b(i).px_x(3) b(i).px_x(4)] , [b(i).px_r(3),b(i).px_r(4)])
        % WEST FACE
        plot([b(i).px_x(4) b(i).px_x(1)] , [b(i).px_r(4),b(i).px_r(1)])
        text(mean(b(i).px_x),mean(b(i).px_r),num2str(i),'fontsize',14,'color','red','fontweight','bold');

        end

        title('Press any key to start moving points.','fontsize',14,'color','red','fontweight','bold')
        pause

%% CYCLE BLOCKS AND MOVE POINTS
IF_MOVED=zeros(N,4);
TO_MOVE=zeros(N,4);

check_num = 0;
while check_num == 0,


     title('Click on a point to move it.','fontsize',14,'color','black','fontweight','bold')
     [old_x old_r] = ginput(1);
     plot(old_x,old_r,'og')     
     title('Click to select new location.','fontsize',14,'color','black','fontweight','bold')
     [new_x new_r] = ginput(1);  
     plot(new_x,new_r,'or')  

     % FIND SHORTEST DISTANCE
     CHECK_DISTANCE=sqrt((old_x-b(1).px_x(1))^2+(old_r-b(1).px_r(1))^2);
     for i=1:N
        for j=1:4
           NEW_DISTANCE=sqrt((old_x-b(i).px_x(j))^2+(old_r-b(i).px_r(j))^2);
           if NEW_DISTANCE<=CHECK_DISTANCE
               CHECK_DISTANCE=NEW_DISTANCE;
           end
        end
     end
     
     % MOVE POINTS
     for i=1:N
        for j=1:4
           NEW_DISTANCE=sqrt((old_x-b(i).px_x(j))^2+(old_r-b(i).px_r(j))^2);
           if NEW_DISTANCE==CHECK_DISTANCE
              b(i).px_x(j)=new_x;
              b(i).px_r(j)=new_r;
              IF_MOVED(i,j)=1;
              break
           end
        end
     end
       
 
%% REDRAW FIGURE
        close all
        B = imread([b(1).imgpathname,b(1).imgfilename]);
        imagesc(B);
        axis equal
        hold on 
        set(gcf, 'Position', get(0,'Screensize')); 
        for i=1:N
        % Pixels
        % POINT 1
        if IF_MOVED(i,1)==1
        plot(b(i).px_x(1),b(i).px_r(1),'or')
        else
        plot(b(i).px_x(1),b(i).px_r(1),'o')
        end
        % POINT 2        
        if IF_MOVED(i,2)==1
        plot(b(i).px_x(2),b(i).px_r(2),'or')
        else
        plot(b(i).px_x(2),b(i).px_r(2),'o')
        end
        % POINT 3        
        if IF_MOVED(i,3)==1        
        plot(b(i).px_x(3),b(i).px_r(3),'or')
        else
        plot(b(i).px_x(3),b(i).px_r(3),'o')
        end
        % POINT 4        
        if IF_MOVED(i,4)==1          
        plot(b(i).px_x(4),b(i).px_r(4),'or')
        else
        plot(b(i).px_x(4),b(i).px_r(4),'o')            
        end
        % NORTH FACE
        if IF_MOVED(i,1)==1 || IF_MOVED(i,2)==1         
        plot([b(i).px_x(1) b(i).px_x(2)] , [b(i).px_r(1),b(i).px_r(2)],'-r')
        else
        plot([b(i).px_x(1) b(i).px_x(2)] , [b(i).px_r(1),b(i).px_r(2)])
        end
        % EAST FACE
        if IF_MOVED(i,2)==1 || IF_MOVED(i,3)==1          
        plot([b(i).px_x(2) b(i).px_x(3)] , [b(i).px_r(2),b(i).px_r(3)],'-r')
        else
        plot([b(i).px_x(2) b(i).px_x(3)] , [b(i).px_r(2),b(i).px_r(3)])            
        end
        % SOUTH FACE
        if IF_MOVED(i,3)==1 || IF_MOVED(i,4)==1          
        plot([b(i).px_x(3) b(i).px_x(4)] , [b(i).px_r(3),b(i).px_r(4)],'-r')
        else
        plot([b(i).px_x(3) b(i).px_x(4)] , [b(i).px_r(3),b(i).px_r(4)])            
        end
        % WEST FACE
        if IF_MOVED(i,1)==1 || IF_MOVED(i,4)==1          
        plot([b(i).px_x(4) b(i).px_x(1)] , [b(i).px_r(4),b(i).px_r(1)],'-r')
        else
        plot([b(i).px_x(4) b(i).px_x(1)] , [b(i).px_r(4),b(i).px_r(1)])            
        end
        text(mean(b(i).px_x),mean(b(i).px_r),num2str(i),'fontsize',14,'color','red','fontweight','bold');

        end
        
        title('Point moved. Click to continue moving points or press any key to exit.','fontsize',14,'color','red','fontweight','bold')
        check_num = waitforbuttonpress;
        
            % MOVE MORE POINTS?
            if check_num==0
                prompt2={'Pause (to pan and zoom)?'};
                name2='Pause?';
                numlines2=1;
                defaultanswer2={'Y'};
                options.Resize='on';
                options.WindowStyle='normal';
                options.Interpreter='tex';
                answer2=inputdlg(prompt2,name2,numlines2,defaultanswer2,options);
                answ2=cell2mat(answer2(1));
                if answ2=='Y' || answ2=='y'
                    pause
                end
            end
        
        
        

end
        close all




end
