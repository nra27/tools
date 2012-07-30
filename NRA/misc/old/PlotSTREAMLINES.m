%
% Function to plot JH05 streamlines and points
%
% PlotSTREAMLINES(BLADE,color_str)
%
% where color_str could be 'b.-' for example

function PlotSTREAMLINES(BLADE,color_str)

% Plot the streamlines of a blade definition file
hold on;
for n = 1:BLADE.n_sections,
    stream = BLADE.section(n).streamline; plot(stream(:,1),stream(:,2),color_str);
end