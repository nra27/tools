%{
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Modify Blocks                   %
%                         v1.0                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Author: sss44                     %
%                   Last mod: 25/3/2011                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      Input: block structure (b)       %
%                     Output: block structure (b)       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                               |
                               |
                               |
                             .-'-.
                            ' ___ '
                  ---------'  .-.  '---------
  _________________________'  '-'  '_________________________
   ''''''-|---|--/    \==][^',_m_,'^][==/    \--|---|-''''''
                 \    /  ||/   H   \||  \    /
                  '--'   OO   O|O   OO   '--'

%}

function b=modify_blocks(b)
%%
check_exit=0;
while check_exit==0
    % PROMPT
    prompt1={'Remove (R), Add (A), Exit(E)?'};
    name1='Modify Blocks';
    numlines1=1;
    defaultanswer1={'E'};
    options.Resize='on';
    options.WindowStyle='normal';
    options.Interpreter='tex';
    answer1=inputdlg(prompt1,name1,numlines1,defaultanswer1,options);
    answ1=cell2mat(answer1(1));
    if answ1=='E' || answ1=='e'
        break
    end
    
    %% REMOVE BLOCKS
    if answ1=='R' || answ1=='r'   
        rem_block=0;
        check_num=0;
        while check_num==0
            close all
            B = imread([b(1).imgpathname,b(1).imgfilename]);
            imagesc(B);
            axis equal
            hold on
            set(gcf, 'Position', get(0,'Screensize')); % maximize figure
            N=length(b);
            % DRAW FIGURE
            for i=1:N
                % Point 1
                plot(b(i).px_x(1),b(i).px_r(1),'o')
                % Point 2
                plot(b(i).px_x(2),b(i).px_r(2),'o')
                % Point 3
                plot(b(i).px_x(3),b(i).px_r(3),'o')
                % Point 4
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
            % DISPLAY MESSAGES AND PICK POINT
            if rem_block==0
                title('Block layout. Press any key to continue','fontsize',14,'color','black','fontweight','bold')
                pause
                title('Block layout. Click inside a block to remove it','fontsize',14,'color','black','fontweight','bold')
                [rem_point_x rem_point_r] = ginput(1);
            else
                title(['Block ',num2str(rem_block),' removed. Click to continue or press any key to exit.'],'fontsize',14,'color','black','fontweight','bold')
                check_num = waitforbuttonpress;
                if check_num==0
                    title('Block layout. Click inside a block to remove it','fontsize',14,'color','black','fontweight','bold')
                    [rem_point_x rem_point_r] = ginput(1);
                end
            end
            
            if check_num==0
                % FIND BLOCK NUMBER TO BE REMOVED
                for i=1:N
                    distance_to_points(i)=sqrt((rem_point_x-b(i).px_x(1))^2+(rem_point_r-b(i).px_r(1))^2);
                    distance_to_points(i)=distance_to_points(i)+sqrt((rem_point_x-b(i).px_x(2))^2+(rem_point_r-b(i).px_r(2))^2);
                    distance_to_points(i)=distance_to_points(i)+sqrt((rem_point_x-b(i).px_x(3))^2+(rem_point_r-b(i).px_r(3))^2);
                    distance_to_points(i)=distance_to_points(i)+sqrt((rem_point_x-b(i).px_x(4))^2+(rem_point_r-b(i).px_r(4))^2);
                end
                [dummy_value, rem_block]=min(distance_to_points);
                % HIGHLIGHT BLOCK ASK IF IT IS CORRECT
                % NORTH FACE
                plot([b(rem_block).px_x(1) b(rem_block).px_x(2)] , [b(rem_block).px_r(1),b(rem_block).px_r(2)],'-r')
                % EAST FACE
                plot([b(rem_block).px_x(2) b(rem_block).px_x(3)] , [b(rem_block).px_r(2),b(rem_block).px_r(3)],'-r')
                % SOUTH FACE
                plot([b(rem_block).px_x(3) b(rem_block).px_x(4)] , [b(rem_block).px_r(3),b(rem_block).px_r(4)],'-r')
                % WEST FACE
                plot([b(rem_block).px_x(4) b(rem_block).px_x(1)] , [b(rem_block).px_r(4),b(rem_block).px_r(1)],'-r')
                
                text(mean(b(i).px_x),mean(b(i).px_r),num2str(i),'fontsize',14,'color','red','fontweight','bold');
                title(['Block ',num2str(rem_block),' selected. Click to remove or press any key to manually enter number.'],'fontsize',14,'color','black','fontweight','bold')
                is_correct = waitforbuttonpress;
                % MANUALLY CHOOSE BLOCK
                if is_correct==1
                    prompt2={'Enter block number to remove?'};
                    name2='Remove block';
                    numlines2=1;
                    defaultanswer2={num2str(rem_block)};
                    options.Resize='on';
                    options.WindowStyle='normal';
                    options.Interpreter='tex';
                    answer2=inputdlg(prompt2,name2,numlines2,defaultanswer2,options);
                    rem_block=str2double(cell2mat(answer2(1)));
                end
                % REMOVE BLOCK AND SHIFT ALL OTHER BLOCK NUMBERS;
                if exist('bb')==1
                    clear bb
                end
                
                if rem_block~=1
                for i=1:rem_block-1
                  bb(i)=b(i);
                end
                end
                
                for i=rem_block:N-1
                  bb(i)=b(i+1);
                end
                clear b
                b=bb;
                clear bb
            end
        end
    end   
    
    %% ADD BLOCKS
    if answ1=='A' || answ1=='a'
        % DRAW FIGURE
        close all
        B = imread([b(1).imgpathname,b(1).imgfilename]);
        imagesc(B);
        axis equal
        hold on
        set(gcf, 'Position', get(0,'Screensize')); % maximize figure
        N=length(b);
        % DRAW FIGURE
        for i=1:N
            % Point 1
            plot(b(i).px_x(1),b(i).px_r(1),'o')
            % Point 2
            plot(b(i).px_x(2),b(i).px_r(2),'o')
            % Point 3
            plot(b(i).px_x(3),b(i).px_r(3),'o')
            % Point 4
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
        % PICK MORE POINTS
        pause
        i = N;
        check_num = 0;
        while check_num == 0,
            i=i+1;
            % Pixels
            title(['Please select point 1 for block ', num2str(i)],'fontsize',14,'color','black','fontweight','bold')
            [b(i).px_x(1) b(i).px_r(1)] = ginput(1);
            plot(b(i).px_x(1),b(i).px_r(1),'o')
            
            beep
            title(['Please select point 2 for block ', num2str(i)],'fontsize',14,'color','black','fontweight','bold')
            [b(i).px_x(2) b(i).px_r(2)] = ginput(1);
            plot(b(i).px_x(2),b(i).px_r(2),'o')
            plot([b(i).px_x(1) b(i).px_x(2)] , [b(i).px_r(1),b(i).px_r(2)])
            
            beep
            title(['Please select point 3 for block ', num2str(i)],'fontsize',14,'color','black','fontweight','bold')
            [b(i).px_x(3) b(i).px_r(3)] = ginput(1);
            plot(b(i).px_x(3),b(i).px_r(3),'o')
            plot([b(i).px_x(2) b(i).px_x(3)] , [b(i).px_r(2),b(i).px_r(3)])
            
            beep
            title(['Please select point 4 for block ', num2str(i)],'fontsize',14,'color','black','fontweight','bold')
            [b(i).px_x(4) b(i).px_r(4)] = ginput(1);
            plot(b(i).px_x(4),b(i).px_r(4),'o')
            plot([b(i).px_x(3) b(i).px_x(4)] , [b(i).px_r(3),b(i).px_r(4)])
            
            plot([b(i).px_x(4) b(i).px_x(1)] , [b(i).px_r(4),b(i).px_r(1)])
            
            text(mean(b(i).px_x),mean(b(i).px_r),num2str(i),'fontsize',14,'color','red','fontweight','bold');
            
            beep
            
            title(['Input for block ', num2str(i),' complete. Click for more blocks. Press any key to Stop.'],'fontsize',14,'color','red','fontweight','bold')
            
            check_num = waitforbuttonpress;
            
        end
        close all
        
    end

end
end

