%{
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Blocker                         %
%                         v1.2                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Author: nra27                     %
%                   Last mod: 23/3/2011, sss44          %
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



version hist:
v 1.2:
- removed open file prompt - moved it to the main program
v1.1:
- load existing points or choose to map them out

%}

 function b=blocker(b)


close all
clc

% [b(1).imgfilename, b(1).imgpathname] = uigetfile( ...
% {'*.png','PNG Files (*.png)';
%    '*.*',  'All Files (*.*)'}, ...
%    'Open Image File');
[b(1).imgfilename, b(1).imgpathname] = uigetfile( ...
{'*.png','PNG Files (*.png)';
   '*.*',  'All Files (*.*)'}, ...
   'Open Image File');

B = imread([b(1).imgpathname,b(1).imgfilename]);
imagesc(B);
axis equal
hold on 
set(gcf, 'Position', get(0,'Screensize')); % maximize figure


%%

i = 0;
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


%% TESTING
% savefile = 'btest.mat';
% save(savefile, 'b')
 end
%%

% % % % % % for i = 1:NBLOCKIN,
% % % % % %     
% % % % % % % Pixels
% % % % % % %[b(i).px_x(1) b(i).px_r(1)] = ginput(1);
% % % % % % plot(b(1).px_x(1),b(1).px_r(1),'o')
% % % % % % 
% % % % % % %beep
% % % % % % 
% % % % % % %[b(i).px_x(2) b(i).px_r(2)] = ginput(1);
% % % % % % plot(b(i).px_x(2),b(i).px_r(2),'o')
% % % % % % plot([b(i).px_x(1) b(i).px_x(2)] , [b(i).px_r(1),b(i).px_r(2)])
% % % % % % 
% % % % % % %beep
% % % % % % 
% % % % % % %[b(i).px_x(3) b(i).px_r(3)] = ginput(1);
% % % % % % plot(b(i).px_x(3),b(i).px_r(3),'o')
% % % % % % plot([b(i).px_x(2) b(i).px_x(3)] , [b(i).px_r(2),b(i).px_r(3)])
% % % % % % 
% % % % % % %beep
% % % % % % 
% % % % % % %[b(i).px_x(4) b(i).px_r(4)] = ginput(1);
% % % % % % plot(b(i).px_x(4),b(i).px_r(4),'o')
% % % % % % plot([b(i).px_x(3) b(i).px_x(4)] , [b(i).px_r(3),b(i).px_r(4)])
% % % % % % 
% % % % % % plot([b(i).px_x(4) b(i).px_x(1)] , [b(i).px_r(4),b(i).px_r(1)])
% % % % % % 
% % % % % % text(mean(b(i).px_x),mean(b(i).px_r),num2str(i));
% % % % % % 
% % % % % % %beep
% % % % % % 
% % % % % % pause
% % % % % % end
