function HT_Qdot_Rejector;
%
% A function to select valid runs

% Load run archive and steady data
load Corrected_Qdot
load Time_Mean_Points

fig = figure;
for gauge = 1:56
    if gauge == 14 % Don't bother with gauge 14
        continue
    end
    
    disp(['Gauge = ' num2str(gauge)])
    
    % Set up figure
    set(fig,'NumberTitle','off','Name',['Gauge ' num2str(gauge)])
    
    for i = 1:length(points{gauge})
        plot([1:144],Qcor(:,points{gauge}(i)),'b');
        hold on
    end
    
    new_points{gauge} = [];
    
    for i = 1:length(points{gauge})
        plot([1:144],Qcor(:,points{gauge}(i)),'k');
        s  = input('Is this run viable? ','s');
        if strcmp(s,'y')
            plot([1:144],Qcor(:,points{gauge}(i)),'r');
            new_points{gauge}(end+1) = points{gauge}(i);
        else
            plot([1:144],Qcor(:,points{gauge}(i)),'b');
        end
    end
    hold off
end


points = new_points;
close(fig);

save Qdot_Points points;