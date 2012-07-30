%{
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    Block Matcher                      %
%                         v1.0                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Author: sss44                     %
%                   Last mod: 24/3/2011                 %
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
function [b]=match_points(b)
%% NUMBER OF BLOCKS
N=length(b);
%% MATCH CRITERIA
CRITERIA=0.2; % percentage distance of shortest corner edge to be used for matching
ROUNDING_CRITERIA=0.005; % percentage distance of shortest edge to be used as a rounding criteria
%% INITIALIZE STUFF
CHECK=zeros(N,4);
SHORTEST_DISTANCE=sqrt((b(1).px_x(1)-b(1).px_x(2))^2+(b(1).px_r(1)-b(1).px_r(2))^2);
%% CYCLE BLOCKS AND APPLY CRITERIA
for ii=1:N % cycle blocks
   for jj=1:4 % cycle each point
       % FIND CHECK DISTANCE
       if jj==1
       CHECK_DISTANCE(1)=sqrt((b(ii).px_x(jj)-b(ii).px_x(4))^2+(b(ii).px_r(jj)-b(ii).px_r(4))^2);
       else
       CHECK_DISTANCE(1)=sqrt((b(ii).px_x(jj)-b(ii).px_x(jj-1))^2+(b(ii).px_r(jj)-b(ii).px_r(jj-1))^2);
       end
       if jj==4
       CHECK_DISTANCE(2)=sqrt((b(ii).px_x(jj)-b(ii).px_x(1))^2+(b(ii).px_r(jj)-b(ii).px_r(1))^2);
       else
       CHECK_DISTANCE(2)=sqrt((b(ii).px_x(jj)-b(ii).px_x(jj+1))^2+(b(ii).px_r(jj)-b(ii).px_r(jj+1))^2);    
       end
       if CHECK_DISTANCE(1)<SHORTEST_DISTANCE
          SHORTEST_DISTANCE=CHECK_DISTANCE(1); 
       end
       WHICH_INDEX=0;
       WHICH_BLOCKS=zeros(3,2);      
       NEW_X=b(ii).px_x(jj);
       NEW_R=b(ii).px_r(jj);
       
       %%
       if CHECK(ii,jj)==0
       for i=1:N
          for j=1:4
              if CHECK(i,j)==0 && ~(j==jj && i==ii)
              % FIND CHECK DISTANCE
              if j==1
              CHECK_DISTANCE(3)=sqrt((b(i).px_x(j)-b(i).px_x(4))^2+(b(i).px_r(j)-b(i).px_r(4))^2);  
              else
              CHECK_DISTANCE(3)=sqrt((b(i).px_x(j)-b(i).px_x(j-1))^2+(b(i).px_r(j)-b(i).px_r(j-1))^2);
              end
              if j==4
              CHECK_DISTANCE(4)=sqrt((b(i).px_x(j)-b(i).px_x(1))^2+(b(i).px_r(j)-b(i).px_r(1))^2);
              else
              CHECK_DISTANCE(4)=sqrt((b(i).px_x(j)-b(i).px_x(j+1))^2+(b(i).px_r(j)-b(i).px_r(j+1))^2);    
              end
              
              % CHOOSE SMALLEST
              CRITERIA_DISTANCE=CRITERIA*min(CHECK_DISTANCE);
              
              % POINT DISTANCE
              POINT_DISTANCE=sqrt((b(ii).px_x(jj)-b(i).px_x(j))^2+(b(ii).px_r(jj)-b(i).px_r(j))^2);
              
              % CHECK IF POINTS SATISFY CRITERIA
              if POINT_DISTANCE<=CRITERIA_DISTANCE
                  WHICH_INDEX=WHICH_INDEX+1;
                  WHICH_BLOCKS(WHICH_INDEX,1)=i;
                  WHICH_BLOCKS(WHICH_INDEX,2)=j;
                  NEW_X=NEW_X+b(i).px_x(j);
                  NEW_R=NEW_R+b(i).px_r(j);
                  CHECK(i,j)=1;
              end
              
              if WHICH_INDEX==3
                 break % max number of matching nodes is 4
              end
              end
          end
       end
       end
       %% MAKE POINTS THE SAME
       NEW_X=NEW_X/(WHICH_INDEX+1);
       NEW_R=NEW_R/(WHICH_INDEX+1);
       b(ii).px_x(jj)=NEW_X;
       b(ii).px_r(jj)=NEW_R;
       if WHICH_INDEX~=0
       for i=1:WHICH_INDEX
           iii=WHICH_BLOCKS(i,1);
           jjj=WHICH_BLOCKS(i,2);
           b(iii).px_x(jjj)=NEW_X;
           b(iii).px_r(jjj)=NEW_R;
       end
       end
   end          
end

%% ROUNDING DOWN EVERYTHING
ROUNDING_CRITERIA=ROUNDING_CRITERIA*SHORTEST_DISTANCE;
CHECK_ROUNDING=0;
i=0;

    if (ROUNDING_CRITERIA/(10^i))>0.1
           j=0; 
    elseif (ROUNDING_CRITERIA*(10^i))<0.1
           j=1; 
    end

while CHECK_ROUNDING==0
    if j==0
    if (ROUNDING_CRITERIA/(10^i))>0.1
           i=i+1; 
    else
        CHECK_ROUNDING=1;
    end
    elseif j==1
    if (ROUNDING_CRITERIA*(10^i))<0.1
           i=i+1; 
    else
        CHECK_ROUNDING=1;
    end
    end
end

for ii=1:N
   for jj=1:4
       if j==0
       b(ii).px_x(jj)=10^i*floor(b(ii).px_x(jj)/(10^i));
       b(ii).px_r(jj)=10^i*floor(b(ii).px_r(jj)/(10^i));       
       else
       b(ii).px_x(jj)=floor(b(ii).px_x(jj)*10^i)/(10^i);
       b(ii).px_r(jj)=floor(b(ii).px_r(jj)*10^i)/(10^i);       
       end
   end
end

%% DRAW FIGURE AFTER POINT MATCHING

B = imread([b(1).imgpathname,b(1).imgfilename]);
imagesc(B);
axis equal
hold on 
set(gcf, 'Position', get(0,'Screensize')); % maximize figure


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


if i==N
 title('Block layout. Press any key to continue.','fontsize',14,'color','black','fontweight','bold')
pause
end
end
close all



end
