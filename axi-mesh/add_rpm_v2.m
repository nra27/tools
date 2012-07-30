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

%%
function [b]=add_patches(b)
%% NUMBER OF BLOCKS
N=length(b);
%% CALIBRATE PIXEL DATA
b=cavity_calibration(b);
%% INITIALIZE STUFF
check_exit=0;
CONFIRM_CHOICE=2;
IS_SET=b(1).IS_SET;
if b(1).patch_match_is_run==1
while check_exit==0
%% PROMPT USER
if CONFIRM_CHOICE>0
    prompt1={'Add: Inlet (I), Exit (E), Periodic (P)?'};
    name1='Add Blocks';
    numlines1=1;
    defaultanswer1={'P'};
    options.Resize='on';
    options.WindowStyle='normal';
    options.Interpreter='tex';
    answer1=inputdlg(prompt1,name1,numlines1,defaultanswer1,options);
    answ1=cell2mat(answer1(1));
    CONFIRM_CHOICE=0;
end

%% DRAW FIGURE
if CONFIRM_CHOICE==0
            B = imread([b(1).imgpathname,b(1).imgfilename]);
            imagesc(B);
            axis equal
            hold on
            set(gcf, 'Position', get(0,'Screensize')); % maximize figure
            N=length(b);
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
            else
                plot([b(i).px_x(4) b(i).px_x(1)] , [b(i).px_r(4),b(i).px_r(1)])
            end
                text(mean(b(i).px_x),mean(b(i).px_r),num2str(i),'fontsize',14,'color','red','fontweight','bold');
            % DISPLAY MESSAGES AND PICK POINT
    end

                title('Block layout. Press any key to continue','fontsize',14,'color','black','fontweight','bold')
                pause
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
                end
end                
%% HIGHLIGHT EDGE

                if answ1=='I' || answ1=='i'
                    plot([NEAREST_X(1), NEAREST_X(2)] , [NEAREST_R(1), NEAREST_R(2)], '-c')
                elseif answ1=='E' || answ1=='e'
                    plot([NEAREST_X(1), NEAREST_X(2)] , [NEAREST_R(1), NEAREST_R(2)], '-g')
                elseif answ1=='P' || answ1=='p'
                    plot([NEAREST_X(1), NEAREST_X(2)] , [NEAREST_R(1), NEAREST_R(2)], '-r')
                end

                title('Patch selected. Click to reselect or press any key to confirm selectrion.','fontsize',14,'color','black','fontweight','bold')
                CONFIRM_CHOICE = waitforbuttonpress;


                
%% FIND FACE
                if NEAREST_EDGE(2)==1
                   FACE='NORTH'; 
                elseif NEAREST_EDGE(2)==2
                   FACE='EAST';    
                elseif NEAREST_EDGE(2)==3
                   FACE='SOUTH';    
                elseif NEAREST_EDGE(2)==4
                   FACE='WEST';    
                end
                
                
%%  
if CONFIRM_CHOICE==1    
    %% PATCH TYPE I
if answ1=='I' || answ1=='i'
    % SET PATCH VARIABLES
                b(1).NUM_PATCH(NEAREST_EDGE(1))=b(1).NUM_PATCH(NEAREST_EDGE(1))+1;            
                IS_SET(NEAREST_EDGE(1),NEAREST_EDGE(2))=2;
                b(NEAREST_EDGE(1)).PATCHTITLE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = {['INLET - ',FACE,' FACE.']};
                b(NEAREST_EDGE(1)).PATCHTYPE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = 'I';
                if NEAREST_EDGE(2)==1
                    b(NEAREST_EDGE(1)).IPATCHS(b(1).NUM_PATCH(NEAREST_EDGE(1))) = 1;
                    b(NEAREST_EDGE(1)).IPATCHE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(NEAREST_EDGE(1)).NI;
                    b(NEAREST_EDGE(1)).JPATCHS(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(NEAREST_EDGE(1)).NJ;
                    b(NEAREST_EDGE(1)).JPATCHE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(NEAREST_EDGE(1)).NJ;
                    b(NEAREST_EDGE(1)).KPATCHS(b(1).NUM_PATCH(NEAREST_EDGE(1))) = 1;
                    b(NEAREST_EDGE(1)).KPATCHE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(NEAREST_EDGE(1)).NK;
                elseif NEAREST_EDGE(2)==2
                    b(NEAREST_EDGE(1)).IPATCHS(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(NEAREST_EDGE(1)).NI;
                    b(NEAREST_EDGE(1)).IPATCHE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(NEAREST_EDGE(1)).NI;
                    b(NEAREST_EDGE(1)).JPATCHS(b(1).NUM_PATCH(NEAREST_EDGE(1))) = 1;
                    b(NEAREST_EDGE(1)).JPATCHE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(NEAREST_EDGE(1)).NJ;
                    b(NEAREST_EDGE(1)).KPATCHS(b(1).NUM_PATCH(NEAREST_EDGE(1))) = 1;
                    b(NEAREST_EDGE(1)).KPATCHE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(NEAREST_EDGE(1)).NK;
                elseif NEAREST_EDGE(2)==3
                    b(NEAREST_EDGE(1)).IPATCHS(b(1).NUM_PATCH(NEAREST_EDGE(1))) = 1;
                    b(NEAREST_EDGE(1)).IPATCHE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(NEAREST_EDGE(1)).NI;
                    b(NEAREST_EDGE(1)).JPATCHS(b(1).NUM_PATCH(NEAREST_EDGE(1))) = 1;
                    b(NEAREST_EDGE(1)).JPATCHE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = 1;
                    b(NEAREST_EDGE(1)).KPATCHS(b(1).NUM_PATCH(NEAREST_EDGE(1))) = 1;
                    b(NEAREST_EDGE(1)).KPATCHE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(NEAREST_EDGE(1)).NK;
                elseif NEAREST_EDGE(2)==4
                    b(NEAREST_EDGE(1)).IPATCHS(b(1).NUM_PATCH(NEAREST_EDGE(1))) = 1;
                    b(NEAREST_EDGE(1)).IPATCHE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = 1;
                    b(NEAREST_EDGE(1)).JPATCHS(b(1).NUM_PATCH(NEAREST_EDGE(1))) = 1;
                    b(NEAREST_EDGE(1)).JPATCHE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(NEAREST_EDGE(1)).NJ;
                    b(NEAREST_EDGE(1)).KPATCHS(b(1).NUM_PATCH(NEAREST_EDGE(1))) = 1;
                    b(NEAREST_EDGE(1)).KPATCHE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(NEAREST_EDGE(1)).NK;
                end
    % PROMPT FOR CARD 53   
    prompt3={'NPIN?','IFRELIN?','RFIN?'};
    name3='Card 53';
    numlines3=1;
    defaultanswer3={'1','0','0.5'};
    options.Resize='on';
    options.WindowStyle='normal';
    options.Interpreter='tex';
    answer3=inputdlg(prompt3,name3,numlines3,defaultanswer3,options);
    % SET VARIABLES
    b(NEAREST_EDGE(1)).NPIN(1)=str2double(cell2mat(answer3(1)));
    b(NEAREST_EDGE(1)).IFRELIN(1)=str2double(cell2mat(answer3(2)));
    b(NEAREST_EDGE(1)).RFIN(1)=str2double(cell2mat(answer3(3)));    
    
    for ii=1:b(NEAREST_EDGE(1)).NPIN(1)
        % PROMPT FOR CARD 54
        prompt4={'FRAC?','POIN?','TOIN?','YAW?','PITCH?','PHI?'};
        name4='Card 54';
        numlines4=1;
        defaultanswer4={'0.5','1800000.0','1500.0','70.0','0.0','0'};
        options.Resize='on';
        options.WindowStyle='normal';
        options.Interpreter='tex';
        answer4=inputdlg(prompt4,name4,numlines4,defaultanswer4,options);
        % SET VARIABLES
        b(NEAREST_EDGE(1)).FRAC(ii)=str2double(cell2mat(answer4(1)));
        b(NEAREST_EDGE(1)).POIN(ii)=str2double(cell2mat(answer4(2)));
        b(NEAREST_EDGE(1)).TOIN(ii)=str2double(cell2mat(answer4(3)));
        b(NEAREST_EDGE(1)).YAW(ii)=str2double(cell2mat(answer4(4)));
        b(NEAREST_EDGE(1)).PITCH(ii)=str2double(cell2mat(answer4(5)));
        b(NEAREST_EDGE(1)).PHI(ii)=str2double(cell2mat(answer4(6)));
    end
    
end
%% PATCH TYPE E
if answ1=='E' || answ1=='e'
    % SET PATCH VARIABLES
                b(1).NUM_PATCH(NEAREST_EDGE(1))=b(1).NUM_PATCH(NEAREST_EDGE(1))+1;            
                IS_SET(NEAREST_EDGE(1),NEAREST_EDGE(2))=3;
                b(NEAREST_EDGE(1)).PATCHTITLE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = {['EXIT - ',FACE,' FACE.']};
                b(NEAREST_EDGE(1)).PATCHTYPE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = 'E';
                if NEAREST_EDGE(2)==1
                    b(NEAREST_EDGE(1)).IPATCHS(b(1).NUM_PATCH(NEAREST_EDGE(1))) = 1;
                    b(NEAREST_EDGE(1)).IPATCHE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(NEAREST_EDGE(1)).NI;
                    b(NEAREST_EDGE(1)).JPATCHS(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(NEAREST_EDGE(1)).NJ;
                    b(NEAREST_EDGE(1)).JPATCHE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(NEAREST_EDGE(1)).NJ;
                    b(NEAREST_EDGE(1)).KPATCHS(b(1).NUM_PATCH(NEAREST_EDGE(1))) = 1;
                    b(NEAREST_EDGE(1)).KPATCHE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(NEAREST_EDGE(1)).NK;
                elseif NEAREST_EDGE(2)==2
                    b(NEAREST_EDGE(1)).IPATCHS(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(NEAREST_EDGE(1)).NI;
                    b(NEAREST_EDGE(1)).IPATCHE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(NEAREST_EDGE(1)).NI;
                    b(NEAREST_EDGE(1)).JPATCHS(b(1).NUM_PATCH(NEAREST_EDGE(1))) = 1;
                    b(NEAREST_EDGE(1)).JPATCHE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(NEAREST_EDGE(1)).NJ;
                    b(NEAREST_EDGE(1)).KPATCHS(b(1).NUM_PATCH(NEAREST_EDGE(1))) = 1;
                    b(NEAREST_EDGE(1)).KPATCHE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(NEAREST_EDGE(1)).NK;
                elseif NEAREST_EDGE(2)==3
                    b(NEAREST_EDGE(1)).IPATCHS(b(1).NUM_PATCH(NEAREST_EDGE(1))) = 1;
                    b(NEAREST_EDGE(1)).IPATCHE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(NEAREST_EDGE(1)).NI;
                    b(NEAREST_EDGE(1)).JPATCHS(b(1).NUM_PATCH(NEAREST_EDGE(1))) = 1;
                    b(NEAREST_EDGE(1)).JPATCHE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = 1;
                    b(NEAREST_EDGE(1)).KPATCHS(b(1).NUM_PATCH(NEAREST_EDGE(1))) = 1;
                    b(NEAREST_EDGE(1)).KPATCHE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(NEAREST_EDGE(1)).NK;
                elseif NEAREST_EDGE(2)==4
                    b(NEAREST_EDGE(1)).IPATCHS(b(1).NUM_PATCH(NEAREST_EDGE(1))) = 1;
                    b(NEAREST_EDGE(1)).IPATCHE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = 1;
                    b(NEAREST_EDGE(1)).JPATCHS(b(1).NUM_PATCH(NEAREST_EDGE(1))) = 1;
                    b(NEAREST_EDGE(1)).JPATCHE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(NEAREST_EDGE(1)).NJ;
                    b(NEAREST_EDGE(1)).KPATCHS(b(1).NUM_PATCH(NEAREST_EDGE(1))) = 1;
                    b(NEAREST_EDGE(1)).KPATCHE(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(NEAREST_EDGE(1)).NK;
                end
    % PROMPT FOR CARD 53   
    prompt5={'NPOUT?','I_EXBCS?','IPOUT?','FREFLECT/FTHROTTLE?'};
    name5='Card 55';
    numlines5=1;
    defaultanswer5={'1','0','3','0'};
    options.Resize='on';
    options.WindowStyle='normal';
    options.Interpreter='none';
    answer5=inputdlg(prompt5,name5,numlines5,defaultanswer5,options);
    % SET VARIABLES    
    b(NEAREST_EDGE(1)).NPOUT(1)=str2double(cell2mat(answer5(1)));
    b(NEAREST_EDGE(1)).I_EXBCS(1)=str2double(cell2mat(answer5(2)));
    b(NEAREST_EDGE(1)).IPOUT(1)=str2double(cell2mat(answer5(3)));     
    b(NEAREST_EDGE(1)).FREFLECT(1)=str2double(cell2mat(answer5(4)));        
    
    for ii=1:b(NEAREST_EDGE(1)).NPOUT(1)
        % PROMPT FOR CARD 54
        prompt6={'FRAC?','POUT?'};
        name6='Card 56';
        numlines6=1;
        defaultanswer6={'0.5','1180000'};
        options.Resize='on';
        options.WindowStyle='normal';
        options.Interpreter='none';
        answer6=inputdlg(prompt6,name6,numlines6,defaultanswer6,options);
        b(NEAREST_EDGE(1)).FRAC_E(ii)=str2double(cell2mat(answer6(1)));
        b(NEAREST_EDGE(1)).POUT(ii)=str2double(cell2mat(answer6(2)));
    end
     
      
end
%% PATCH TYPE P
if answ1=='P' || answ1=='p'
    
    % FIND THE MATCHING FACE ON THE OTHER BLOCK (MAY NOT NECESSARILY BE
    % REPRESENTATIVE!)
    for i=1:N
        if i~=NEAREST_EDGE(1);
            % NORTH FACE
            if ((((NEAREST_X(1)==b(i).px_x(1) && NEAREST_R(1)==b(i).px_r(1)) &&  (NEAREST_X(2)==b(i).px_x(2) && NEAREST_R(2)==b(i).px_r(2)))) || ...
                    (((NEAREST_X(1)==b(i).px_x(2) && NEAREST_R(1)==b(i).px_r(2)) &&  (NEAREST_X(2)==b(i).px_x(1) && NEAREST_R(2)==b(i).px_r(1)))))
                
                b(1).NUM_PATCH(NEAREST_EDGE(1))=b(1).NUM_PATCH(NEAREST_EDGE(1))+1;
                b(1).NUM_PATCH(i)=b(1).NUM_PATCH(i)+1;
                
                b(NEAREST_EDGE(1)).NEXTBLOCK(b(1).NUM_PATCH(NEAREST_EDGE(1))) = i;
                b(NEAREST_EDGE(1)).NEXTPATCH(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(1).NUM_PATCH(i);
                
                b(i).NEXTBLOCK(b(1).NUM_PATCH(i)) = NEAREST_EDGE(1);
                b(i).NEXTPATCH(b(1).NUM_PATCH(i)) = b(1).NUM_PATCH(NEAREST_EDGE(1));
                
                % SETS DATA ON THE SELECTED FACE
                if NEAREST_EDGE(2)==1
                    [b, IS_SET]=match_north(b, 1, IS_SET, NEAREST_EDGE(1), i);
                    [b, IS_SET]=match_north(b, 1, IS_SET, i, NEAREST_EDGE(1));
                elseif NEAREST_EDGE(2)==2
                    [b, IS_SET]=match_east(b, 1, IS_SET, NEAREST_EDGE(1), i);
                    [b, IS_SET]=match_north(b, 2, IS_SET, i, NEAREST_EDGE(1));
                elseif NEAREST_EDGE(2)==3
                    [b, IS_SET]=match_south(b, 1, IS_SET, NEAREST_EDGE(1), i);
                    [b, IS_SET]=match_north(b, 3, IS_SET, i, NEAREST_EDGE(1));
                elseif NEAREST_EDGE(2)==4
                    [b, IS_SET]=match_west(b, 1, IS_SET, NEAREST_EDGE(1), i);
                    [b, IS_SET]=match_north(b, 4, IS_SET, i, NEAREST_EDGE(1));
                end
                
                
                % EAST FACE
            elseif ((((NEAREST_X(1)==b(i).px_x(2) && NEAREST_R(1)==b(i).px_r(2)) &&  (NEAREST_X(2)==b(i).px_x(3) && NEAREST_R(2)==b(i).px_r(3)))) || ...
                    (((NEAREST_X(1)==b(i).px_x(3) && NEAREST_R(1)==b(i).px_r(3)) &&  (NEAREST_X(2)==b(i).px_x(2) && NEAREST_R(2)==b(i).px_r(2)))))
                
                b(1).NUM_PATCH(NEAREST_EDGE(1))=b(1).NUM_PATCH(NEAREST_EDGE(1))+1;
                b(1).NUM_PATCH(i)=b(1).NUM_PATCH(i)+1;
                
                b(NEAREST_EDGE(1)).NEXTBLOCK(b(1).NUM_PATCH(NEAREST_EDGE(1))) = i;
                b(NEAREST_EDGE(1)).NEXTPATCH(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(1).NUM_PATCH(i);
                
                b(i).NEXTBLOCK(b(1).NUM_PATCH(i)) = NEAREST_EDGE(1);
                b(i).NEXTPATCH(b(1).NUM_PATCH(i)) = b(1).NUM_PATCH(NEAREST_EDGE(1));
                
                % SETS DATA ON THE SELECTED FACE
                if NEAREST_EDGE(2)==1
                    [b, IS_SET]=match_north(b, 2, IS_SET, NEAREST_EDGE(1), i);
                    [b, IS_SET]=match_east(b, 1, IS_SET, i, NEAREST_EDGE(1));
                elseif NEAREST_EDGE(2)==2
                    [b, IS_SET]=match_east(b, 2, IS_SET, NEAREST_EDGE(1), i);
                    [b, IS_SET]=match_east(b, 2, IS_SET, i, NEAREST_EDGE(1));
                elseif NEAREST_EDGE(2)==3
                    [b, IS_SET]=match_south(b, 2, IS_SET, NEAREST_EDGE(1), i);
                    [b, IS_SET]=match_east(b, 3, IS_SET, i, NEAREST_EDGE(1));
                elseif NEAREST_EDGE(2)==4
                    [b, IS_SET]=match_west(b, 2, IS_SET, NEAREST_EDGE(1), i);
                    [b, IS_SET]=match_east(b, 4, IS_SET, i, NEAREST_EDGE(1));
                end
                
                
                % SOUTH FACE
            elseif ((((NEAREST_X(1)==b(i).px_x(3) && NEAREST_R(1)==b(i).px_r(3)) &&  (NEAREST_X(2)==b(i).px_x(4) && NEAREST_R(2)==b(i).px_r(4)))) || ...
                    (((NEAREST_X(1)==b(i).px_x(4) && NEAREST_R(1)==b(i).px_r(4)) &&  (NEAREST_X(2)==b(i).px_x(3) && NEAREST_R(2)==b(i).px_r(3)))))
                
                b(1).NUM_PATCH(NEAREST_EDGE(1))=b(1).NUM_PATCH(NEAREST_EDGE(1))+1;
                b(1).NUM_PATCH(i)=b(1).NUM_PATCH(i)+1;
                
                b(NEAREST_EDGE(1)).NEXTBLOCK(b(1).NUM_PATCH(NEAREST_EDGE(1))) = i;
                b(NEAREST_EDGE(1)).NEXTPATCH(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(1).NUM_PATCH(i);
                
                b(i).NEXTBLOCK(b(1).NUM_PATCH(i)) = NEAREST_EDGE(1);
                b(i).NEXTPATCH(b(1).NUM_PATCH(i)) = b(1).NUM_PATCH(NEAREST_EDGE(1));
                
                % SETS DATA ON THE SELECTED FACE
                if NEAREST_EDGE(2)==1
                    [b, IS_SET]=match_north(b, 3, IS_SET, NEAREST_EDGE(1), i);
                    [b, IS_SET]=match_south(b, 1, IS_SET, i, NEAREST_EDGE(1));
                elseif NEAREST_EDGE(2)==2
                    [b, IS_SET]=match_east(b, 3, IS_SET, NEAREST_EDGE(1), i);
                    [b, IS_SET]=match_south(b, 2, IS_SET, i, NEAREST_EDGE(1));
                elseif NEAREST_EDGE(2)==3
                    [b, IS_SET]=match_south(b, 3, IS_SET, NEAREST_EDGE(1), i);
                    [b, IS_SET]=match_south(b, 3, IS_SET, i, NEAREST_EDGE(1));
                elseif NEAREST_EDGE(2)==4
                    [b, IS_SET]=match_west(b, 3, IS_SET, NEAREST_EDGE(1), i);
                    [b, IS_SET]=match_south(b, 4, IS_SET, i, NEAREST_EDGE(1));
                end
                
                
                % WEST FACE
            elseif ((((NEAREST_X(1)==b(i).px_x(4) && NEAREST_R(1)==b(i).px_r(4)) &&  (NEAREST_X(2)==b(i).px_x(1) && NEAREST_R(2)==b(i).px_r(1)))) || ...
                    (((NEAREST_X(1)==b(i).px_x(1) && NEAREST_R(1)==b(i).px_r(1)) &&  (NEAREST_X(2)==b(i).px_x(4) && NEAREST_R(2)==b(i).px_r(4)))))
                
                b(1).NUM_PATCH(NEAREST_EDGE(1))=b(1).NUM_PATCH(NEAREST_EDGE(1))+1;
                b(1).NUM_PATCH(i)=b(1).NUM_PATCH(i)+1;
                
                b(NEAREST_EDGE(1)).NEXTBLOCK(b(1).NUM_PATCH(NEAREST_EDGE(1))) = i;
                b(NEAREST_EDGE(1)).NEXTPATCH(b(1).NUM_PATCH(NEAREST_EDGE(1))) = b(1).NUM_PATCH(i);
                
                b(i).NEXTBLOCK(b(1).NUM_PATCH(i)) = NEAREST_EDGE(1);
                b(i).NEXTPATCH(b(1).NUM_PATCH(i)) = b(1).NUM_PATCH(NEAREST_EDGE(1));
                
                % SETS DATA ON THE SELECTED FACE
                if NEAREST_EDGE(2)==1
                    [b, IS_SET]=match_north(b, 4, IS_SET, NEAREST_EDGE(1), i);
                    [b, IS_SET]=match_west(b, 1, IS_SET, i, NEAREST_EDGE(1));
                elseif NEAREST_EDGE(2)==2
                    [b, IS_SET]=match_east(b, 4, IS_SET, NEAREST_EDGE(1), i);
                    [b, IS_SET]=match_west(b, 2, IS_SET, i, NEAREST_EDGE(1));
                elseif NEAREST_EDGE(2)==3
                    [b, IS_SET]=match_south(b, 4, IS_SET, NEAREST_EDGE(1), i);
                    [b, IS_SET]=match_west(b, 3, IS_SET, i, NEAREST_EDGE(1));
                elseif NEAREST_EDGE(2)==4
                    [b, IS_SET]=match_west(b, 4, IS_SET, NEAREST_EDGE(1), i);
                    [b, IS_SET]=match_west(b, 4, IS_SET, i, NEAREST_EDGE(1));
                end
            end
        end
    end   
   
end
%% ADD MORE PATCHES?    
    prompt2={'Add more patches?'};
    name2='Add More Patches';
    numlines2=1;
    defaultanswer2={'Y'};
    options.Resize='on';
    options.WindowStyle='normal';
    options.Interpreter='none';
    answer2=inputdlg(prompt2,name2,numlines2,defaultanswer2,options);
    answ2=cell2mat(answer2(1));
    if answ2 == 'N' || answ2 == 'n'
       check_exit=1; 
    end
end
    b(1).IS_SET=IS_SET;
end

%%
%
% Data for the additional patches
%

for i = 1:N,
   b(i).NPATCH=b(1).NUM_PATCH(i);    
%
% Rotation data
%

% CARD 59
b(i).RPMBLOCK = 0; b(i).FMGRID = 0.4; b(i).XLLIM = 0.03; b(i).NSMALL_BLOCK = 3; b(i).NBIG_BLOCK = 9; b(i).ITRANS = 1; b(i). JTRANS = 1; b(i).KTRANS = 1; b(i).FREE_TURB = 0; b(i).XLLIM_FREE = 0.1; b(i).IF_NOSHEAR = 0; b(i).MIXL_TYPE = 3;

% CARD 60
b(i).RPMI1 = 0; b(i).RPMIM = 0; b(i).RPMJ1 = 0; b(i).RPMJM = 0; b(i).RPMK1 = 0; b(i).RPMKM = 0;

end
else
    errordlg('You have not run patch matching yet! Please run it before manually adding patches.','Match Patch Not Run!');
end
end