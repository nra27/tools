%{
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 tblockdset.dat Writer                 %
%                         v1.1                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Author: sss44                     %
%                   Last mod: 26/3/2011                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      Input: -                         %
%                     Output: -                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%}

function main_tblockdset_write
clc
clear all

%% DIALOGUE BOX
prompt={'Load b from file?',...
    'Pick points on figure?',...
    'Match Points?',...
    'Move Points?',...
    'Add/Remove Blocks',...
    'Match Patches?',...
    'Add Patches (I, E, or P)',...
    'Sector size - 1/N. N=?'};
name='Tblockdset.dat Writer';
numlines=1;
defaultanswer={'N','Y','Y','Y','Y','Y','Y','80'};
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
answer=inputdlg(prompt,name,numlines,defaultanswer,options);
b(1).sector(1)=str2double(cell2mat(answer(8)));


%% LOAD IMAGE
[b(1).imgfilename, b(1).imgpathname] = uigetfile( ...
    {'*.png','PNG Files (*.png)';
    '*.*',  'All Files (*.*)'}, ...
    'Open Image File');
b(1).patch_match_is_run=0; % before adding or removing blocks, patch matching needs to be run.

%% LOAD FILE
answ=cell2mat(answer(1));
if answ=='Y' || answ=='y'
    [filename, pathname] = uigetfile({'*.mat','MATLAB Files (*.mat)';'*.*', 'All Files (*.*)'},'Load b');
    load([pathname,filename]) %%
    b(1).patch_match_is_run=0; % before adding or removing blocks, patch matching needs to be run.
    
    %% DRAW FIGURE AFTER POINT MATCHING
    [b(1).imgfilename, b(1).imgpathname] = uigetfile( ...
        {'*.png','PNG Files (*.png)';
        '*.*',  'All Files (*.*)'}, ...
        'Open Image File')
    B = imread([b(1).imgpathname,b(1).imgfilename]);
    imagesc(B);
    axis equal
    hold on
    set(gcf, 'Position', get(0,'Screensize')); % maximize figure
    
    N=length(b);
    for i=1:N
        % Pixels
        plot(b(i).px_x(1),b(i).px_r(1),'o')
        plot(b(i).px_x(2),b(i).px_r(2),'o')
        plot(b(i).px_x(3),b(i).px_r(3),'o')
        plot(b(i).px_x(4),b(i).px_r(4),'o')
        DOES_EXIST = exist('exists');
        
        if DOES_EXIST==1
            b(1).patch_match_is_run=1; % patch matching has already been run.
            
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
        else
            % NORTH FACE
            plot([b(i).px_x(1) b(i).px_x(2)] , [b(i).px_r(1),b(i).px_r(2)])
            % EAST FACE
            plot([b(i).px_x(2) b(i).px_x(3)] , [b(i).px_r(2),b(i).px_r(3)])
            % SOUTH FACE
            plot([b(i).px_x(3) b(i).px_x(4)] , [b(i).px_r(3),b(i).px_r(4)])
            % WEST FACE
            plot([b(i).px_x(4) b(i).px_x(1)] , [b(i).px_r(4),b(i).px_r(1)])
        end
        
        text(mean(b(i).px_x),mean(b(i).px_r),num2str(i),'fontsize',14,'color','red','fontweight','bold');
        
        if i==N
            title('Block layout and patches. Patches marked in red (if present). Press any key to continue.','fontsize',14,'color','black','fontweight','bold')
            pause
        end
    end
    close all
    
end

%% INPUT FROM FIGURE
answ=cell2mat(answer(2));
if answ=='Y' || answ=='y'
    b=blocker(b);
end

%% MATCH POINTS
answ=cell2mat(answer(3));
if answ=='Y' || answ=='y'
    b=match_points(b);
end

%% MOVE POINT
answ=cell2mat(answer(4));
DO_MOVE_POINTS=0;
if answ=='Y' || answ=='y'
    while DO_MOVE_POINTS==0
        
        b=move_points(b);
        
        % MATCH POINTS
        prompt1={'Run Match Points?'};
        name1='Run Match Points';
        numlines1=1;
        defaultanswer1={'Y'};
        options.Resize='on';
        options.WindowStyle='normal';
        options.Interpreter='tex';
        answer1=inputdlg(prompt1,name1,numlines1,defaultanswer1,options);
        answ1=cell2mat(answer1(1));
        
        if answ1=='Y' || answ1=='y'
            b=match_points(b);
        end
        
        % MOVE MORE POINTS?
        prompt2={'Move more points?'};
        name2='Move More Points?';
        numlines2=1;
        defaultanswer2={'N'};
        options.Resize='on';
        options.WindowStyle='normal';
        options.Interpreter='tex';
        answer2=inputdlg(prompt2,name2,numlines2,defaultanswer2,options);
        answ2=cell2mat(answer2(1));
        
        if answ2=='N' || answ2=='n'
            DO_MOVE_POINTS=1;
        end
        
    end
end

%% ADD/REMOVE BLOCKS
answ=cell2mat(answer(5));
if answ=='Y' || answ=='y'
    
    b=modify_blocks(b);
    
    % MATCH POINTS
    prompt1={'Run Match Points?'};
    name1='Run Match Points';
    numlines1=1;
    defaultanswer1={'N'};
    options.Resize='on';
    options.WindowStyle='normal';
    options.Interpreter='tex';
    answer1=inputdlg(prompt1,name1,numlines1,defaultanswer1,options);
    answ1=cell2mat(answer1(1));
    if answ1=='Y' || answ1=='y'
        b=match_points(b);
    end
    b(1).patch_match_is_run=0; % before adding or removing blocks, patch matching needs to be run.
    
end


%% MATCH PATCHES
answ=cell2mat(answer(6));
if answ=='Y' || answ=='y'
    b(1).sector(1)=str2double(cell2mat(answer(8)));
    b=create_patch(b);
    
    % NOTE THAT IF THE BLOCKS ARE NOT DRAWN IN THE CORRECT ORDER
    % 1-2-3-4, clockwise starting at the top-left corner then unless
    % consistent with all other blocks, the coordinate system will not
    % match between blocks!
    
end

%% ADD PATCHES I - E - P
answ=cell2mat(answer(7));
if answ=='Y' || answ=='y'
    b=add_patches(b);
end


%% SAVE b
[savefilename, savepathname] = uiputfile(...
    {'*.mat'},...
    'Save File As');
[savefilename, savepathname] = uiputfile(...
    {'*.mat'},...
    'Save File As');

save([savepathname, savefilename], 'b')

%% WRITE TBLOCKDSET.DAT
tblockdset_write(b);

end

