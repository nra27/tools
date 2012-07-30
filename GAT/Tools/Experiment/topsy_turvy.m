function topsy_turvy(run_number);
%
% topsy_turvy(run_number)
%
% A function to calculate the run time at which the
% rotor is closest to the design operating conditions.
% The time is writen to the eu file.

% If the function is being called from the command line, set everything up.
if strcmp(class(run_number),'double')

% Load eu file
eval(['load r' num2str(run_number) 'eu.mat']);

% Strip data
Data.STime = eu.time.t;
for i = 1:64
    Data.SData(:,i) = eu.data{i};
end

clear eu

% Define sensor entries
%Data.Co.Channels = [1 25 52 41 42 43 7 8]; % Greg build
Data.Co.Channels = [1 25  52 41 42 43 7 8]; % Yoshi build
Data.Co.Bad_Channels = [];
%Data.Ci.Channels = [27 29 30 40 53 49 18 31]; % Greg build
Data.Ci.Channels = [27 29 30 40 53 49 16 31]; % Yoshi build
Data.Ci.Bad_Channels = [];

%Data.Fo.Channels = [32 39 5 44 45 2 28]; % Greg build
Data.Fo.Channels = [32 26 39 5 44 45 2 28]; % Yoshi build
Data.Fo.Bad_Channels = [];
%Data.Fi.Channels = [20 11 23 14 50 4 47 35]; % Greg build
Data.Fi.Channels = [20 11 23 14 50 4 47 35]; % Yoshi build
Data.Fi.Bad_Channels = [];

Data.Jo.Channels = [54 36 21 19 34 33 48];
Data.Jo.Bad_Channels = [];
Data.Ji.Channels = [6 12 13 24 22 17 51 38];
Data.Ji.Bad_Channels = [];

Data.Mo.Channels = [15 37 9 3];
Data.Mo.Bad_Channels = [];
Data.Mi.Channels = [10 16 46 26];
Data.Mi.Bad_Channels = [];

Data.Pbar.Channels = 61;
Data.Pref.Channels = 60;

Data.P01.Channels = 62;
Data.P03.Channels = 63;

Data.Speed.Channels = 57;

Data.T01.Channels = [55 58];
Data.T01.Bad_Channels = [];

Data.T00.Channels = 56;

% Plot C-plane outers and flag if good
Data.figure = figure('CreateFcn','','menubar','none','NumberTitle','off',...
               'name',['Select Bad Channels - run_' num2str(run_number)],...
               'position',[110 580 400 400]);

hold on

for i = 1:length(Data.Co.Channels)
    Data.Co.line(i) = plot(Data.STime,Data.SData(:,Data.Co.Channels(i)));
    set(Data.Co.line(i),'ButtonDownFcn','topsy_turvy(''Co_line'')');
end

Data.Co.title = title('C-plane outer static pressure');
set(Data.Co.title,'ButtonDownFcn','topsy_turvy(''Co_end'')');

set(Data.figure,'UserData',Data);

% If it is being called by itself, use a switch-yard
else
switch(run_number)
case 'Co_line'
    % Being called by the c-plane outer line window
    Data = get(gcbf,'UserData');
    
    for i = 1:length(Data.Co.Channels)
        if gcbo == Data.Co.line(i)
            set(Data.Co.line(i),'Visible','off');
            Data.Co.Bad_Channels(end+1) = Data.Co.Channels(i);
        end
    end
    
    set(Data.figure,'UserData',Data);
    
case 'Co_end'
    % Being called by the c-plane outer return window
    Data = get(gcbf,'UserData');
    
    figure(Data.figure)
    cla
    
    for i = 1:length(Data.Ci.Channels)
        Data.Ci.line(i) = plot(Data.STime,Data.SData(:,Data.Ci.Channels(i)));
        set(Data.Ci.line(i),'ButtonDownFcn','topsy_turvy(''Ci_line'')');
    end

    Data.Ci.title = title('C-plane inner static pressure');
    set(Data.Co.title,'ButtonDownFcn','topsy_turvy(''Ci_end'')');

    set(Data.figure,'UserData',Data);

case 'Ci_line'
    % Being called by the c-plane inner line window
    Data = get(gcbf,'UserData');
    
    for i = 1:length(Data.Ci.Channels)
        if gcbo == Data.Ci.line(i)
            set(Data.Ci.line(i),'Visible','off');
            Data.Ci.Bad_Channels(end+1) = Data.Ci.Channels(i);
        end
    end
    
    set(Data.figure,'UserData',Data);
    
case 'Ci_end'
    % Being called by the c-plane inner return window
    Data = get(gcbf,'UserData');
    
    figure(Data.figure)
    cla
    
    for i = 1:length(Data.Fo.Channels)
        Data.Fo.line(i) = plot(Data.STime,Data.SData(:,Data.Fo.Channels(i)));
        set(Data.Fo.line(i),'ButtonDownFcn','topsy_turvy(''Fo_line'')');
    end

    Data.Fo.title = title('F-plane outer static pressure');
    set(Data.Fo.title,'ButtonDownFcn','topsy_turvy(''Fo_end'')');

    set(Data.figure,'UserData',Data);

case 'Fo_line'
    % Being called by the f-plane outer line window
    Data = get(gcbf,'UserData');
    
    for i = 1:length(Data.Fo.Channels)
        if gcbo == Data.Fo.line(i)
            set(Data.Fo.line(i),'Visible','off');
            Data.Fo.Bad_Channels(end+1) = Data.Fo.Channels(i);
        end
    end
    
    set(Data.figure,'UserData',Data);

case 'Fo_end'
    % Being called by the f-plane outer return window
    Data = get(gcbf,'UserData');
    
    figure(Data.figure)
    cla
    
    for i = 1:length(Data.Fi.Channels)
        Data.Fi.line(i) = plot(Data.STime,Data.SData(:,Data.Fi.Channels(i)));
        set(Data.Fi.line(i),'ButtonDownFcn','topsy_turvy(''Fi_line'')');
    end

    Data.Fi.title = title('F-plane inner static pressure');
    set(Data.Fi.title,'ButtonDownFcn','topsy_turvy(''Fi_end'')');

    set(Data.figure,'UserData',Data);
    
case 'Fi_line'
    % Being called by the f-plane inner line window
    Data = get(gcbf,'UserData');
    
    for i = 1:length(Data.Fi.Channels)
        if gcbo == Data.Fi.line(i)
            set(Data.Fi.line(i),'Visible','off');
            Data.Fi.Bad_Channels(end+1) = Data.Fi.Channels(i);
        end
    end
    
    set(Data.figure,'UserData',Data);
    
case 'Fi_end'
    % Being called by the f-plane inner return window
    Data = get(gcbf,'UserData');
    
    figure(Data.figure)
    cla
    
    for i = 1:length(Data.Jo.Channels)
        Data.Jo.line(i) = plot(Data.STime,Data.SData(:,Data.Jo.Channels(i)));
        set(Data.Jo.line(i),'ButtonDownFcn','topsy_turvy(''Jo_line'')');
    end

    Data.Jo.title = title('J-plane outer static pressure');
    set(Data.Jo.title,'ButtonDownFcn','topsy_turvy(''Jo_end'')');

    set(Data.figure,'UserData',Data);
    
case 'Jo_line'
    % Being called by the j-plane outer line window
    Data = get(gcbf,'UserData');
    
    for i = 1:length(Data.Jo.Channels)
        if gcbo == Data.Jo.line(i)
            set(Data.Jo.line(i),'Visible','off');
            Data.Jo.Bad_Channels(end+1) = Data.Jo.Channels(i);
        end
    end
    
    set(Data.figure,'UserData',Data);

case 'Jo_end'
    % Being called by the j-plane outer return window
    Data = get(gcbf,'UserData');
    
    figure(Data.figure)
    cla
    
    for i = 1:length(Data.Ji.Channels)
        Data.Ji.line(i) = plot(Data.STime,Data.SData(:,Data.Ji.Channels(i)));
        set(Data.Ji.line(i),'ButtonDownFcn','topsy_turvy(''Ji_line'')');
    end

    Data.Ji.title = title('J-plane inner static pressure');
    set(Data.Ji.title,'ButtonDownFcn','topsy_turvy(''Ji_end'')');

    set(Data.figure,'UserData',Data);
    
case 'Ji_line'
    % Being called by the j-plane inner line window
    Data = get(gcbf,'UserData');
    
    for i = 1:length(Data.Ji.Channels)
        if gcbo == Data.Ji.line(i)
            set(Data.Ji.line(i),'Visible','off');
            Data.Ji.Bad_Channels(end+1) = Data.Ji.Channels(i);
        end
    end
    
    set(Data.figure,'UserData',Data);
    
case 'Ji_end'
    % Being called by the j-plane inner return window
    Data = get(gcbf,'UserData');
    
    figure(Data.figure)
    cla
    
    for i = 1:length(Data.Mo.Channels)
        Data.Mo.line(i) = plot(Data.STime,Data.SData(:,Data.Mo.Channels(i)));
        set(Data.Mo.line(i),'ButtonDownFcn','topsy_turvy(''Mo_line'')');
    end

    Data.Mo.title = title('M-plane outer static pressure');
    set(Data.Mo.title,'ButtonDownFcn','topsy_turvy(''Mo_end'')');

    set(Data.figure,'UserData',Data);
    
case 'Mo_line'
    % Being called by the m-plane outer line window
    Data = get(gcbf,'UserData');
    
    for i = 1:length(Data.Mo.Channels)
        if gcbo == Data.Mo.line(i)
            set(Data.Mo.line(i),'Visible','off');
            Data.Mo.Bad_Channels(end+1) = Data.Mo.Channels(i);
        end
    end
    
    set(Data.figure,'UserData',Data);
    
case 'Mo_end'
    % Being called by the m-plane outer return window
    Data = get(gcbf,'UserData');
    
    figure(Data.figure)
    cla
    
    for i = 1:length(Data.Mi.Channels)
        Data.Mi.line(i) = plot(Data.STime,Data.SData(:,Data.Mi.Channels(i)));
        set(Data.Mi.line(i),'ButtonDownFcn','topsy_turvy(''Mi_line'')');
    end

    Data.Mi.title = title('M-plane inner static pressure');
    set(Data.Mi.title,'ButtonDownFcn','topsy_turvy(''Mi_end'')');

    set(Data.figure,'UserData',Data);
    
case 'Mi_line'
    % Being called by the m-plane inner line window
    Data = get(gcbf,'UserData');
    
    for i = 1:length(Data.Mi.Channels)
        if gcbo == Data.Mi.line(i)
            set(Data.Mi.line(i),'Visible','off');
            Data.Mi.Bad_Channels(end+1) = Data.Mi.Channels(i);
        end
    end
    
    set(Data.figure,'UserData',Data);
    
case 'Mi_end'
    % Being called by the m-plane inner return window
    Data = get(gcbf,'UserData');
    
    figure(Data.figure)
    cla
    
    for i = 1:length(Data.T01.Channels)
        Data.T01.line(i) = plot(Data.STime,Data.SData(:,Data.T01.Channels(i)));
        set(Data.T01.line(i),'ButtonDownFcn','topsy_turvy(''T01_line'')');
    end

    r=1.34;
    T00=Data.SData(:,Data.T00.Channels);
    To=mean(T00(1:50));
    Pbar=Data.SData(:,Data.Pbar.Channels);
    Pbaro=mean(Pbar(1:50));
    Data.T01.issen=To*(Pbar/Pbaro).^(1-1/r); % NGV Inlet Total Temperature
    
    plot(Data.STime,Data.T01.issen,'r');
    
    Data.T01.title = title('Inlet total temperature');
    set(Data.T01.title,'ButtonDownFcn','topsy_turvy(''T01_end'')');

    set(Data.figure,'UserData',Data);
    
case 'T01_line'
    % Being called by the T01 line window
    Data = get(gcbf,'UserData');
    
    for i = 1:length(Data.T01.Channels)
        if gcbo == Data.T01.line(i)
            set(Data.T01.line(i),'Visible','off');
            Data.T01.Bad_Channels(end+1) = Data.T01.Channels(i);
        end
    end
    
    set(Data.figure,'UserData',Data);
    
case 'T01_end'
    % Being called by the P return window
    Data = get(gcbf,'UserData');
    
    figure(Data.figure)
    cla
   
    Data.S.title = title('Rotor speed');
    set(Data.S.title,'ButtonDownFcn','topsy_turvy(''S_end'')');

    plot(Data.STime,Data.SData(:,Data.Speed.Channels),'b');
    
    set(Data.figure,'UserData',Data);
        
case 'S_end'
    % Being called by the T01 return window
    Data = get(gcbf,'UserData');
    
    figure(Data.figure)
    cla
   
    set(Data.figure,'menubar','figure')
    Data.P.title = title('Rotor pressures');
    set(Data.P.title,'ButtonDownFcn','topsy_turvy(''P_end'')');

    plot(Data.STime,Data.SData(:,Data.Pbar.Channels),'b');
    plot(Data.STime,Data.SData(:,Data.P01.Channels),'r');
    plot(Data.STime,Data.SData(:,Data.P03.Channels),'g');
    grid on
    hold off
    
    set(Data.figure,'UserData',Data);
       
case 'P_end'
    % Being called by the S return window
    Data = get(gcbf,'UserData');
    
    figure(Data.figure)
    cla
   
    % Strip the good channels
    Data.Co.Good_Channels = [];
    check = 0;
    for i = 1:length(Data.Co.Channels)
        for j = 1:length(Data.Co.Bad_Channels)
            if Data.Co.Bad_Channels(j) == Data.Co.Channels(i)
                check = 1;
            end
        end
        if check == 0
            Data.Co.Good_Channels(end+1) = Data.Co.Channels(i);
        end
        check = 0;
    end
         
    Data.Ci.Good_Channels = [];
    check = 0;
    for i = 1:length(Data.Ci.Channels)
        for j = 1:length(Data.Ci.Bad_Channels)
            if Data.Ci.Bad_Channels(j) == Data.Ci.Channels(i)
                check = 1;
            end
        end
        if check == 0
            Data.Ci.Good_Channels(end+1) = Data.Ci.Channels(i);
        end
        check = 0;
    end

    Data.Fo.Good_Channels = [];
    check = 0;
    for i = 1:length(Data.Fo.Channels)
        for j = 1:length(Data.Fo.Bad_Channels)
            if Data.Fo.Bad_Channels(j) == Data.Fo.Channels(i)
                check = 1;
            end
        end
        if check == 0
            Data.Fo.Good_Channels(end+1) = Data.Fo.Channels(i);
        end
        check = 0;
    end
         
    Data.Fi.Good_Channels = [];
    check = 0;
    for i = 1:length(Data.Fi.Channels)
        for j = 1:length(Data.Fi.Bad_Channels)
            if Data.Fi.Bad_Channels(j) == Data.Fi.Channels(i)
                check = 1;
            end
        end
        if check == 0
            Data.Fi.Good_Channels(end+1) = Data.Fi.Channels(i);
        end
        check = 0;
    end
    
    Data.Jo.Good_Channels = [];
    check = 0;
    for i = 1:length(Data.Jo.Channels)
        for j = 1:length(Data.Jo.Bad_Channels)
            if Data.Jo.Bad_Channels(j) == Data.Jo.Channels(i)
                check = 1;
            end
        end
        if check == 0
            Data.Jo.Good_Channels(end+1) = Data.Jo.Channels(i);
        end
        check = 0;
    end
         
    Data.Ji.Good_Channels = [];
    check = 0;
    for i = 1:length(Data.Ji.Channels)
        for j = 1:length(Data.Ji.Bad_Channels)
            if Data.Ji.Bad_Channels(j) == Data.Ji.Channels(i)
                check = 1;
            end
        end
        if check == 0
            Data.Ji.Good_Channels(end+1) = Data.Ji.Channels(i);
        end
        check = 0;
    end
    
    Data.Mo.Good_Channels = [];
    check = 0;
    for i = 1:length(Data.Mo.Channels)
        for j = 1:length(Data.Mo.Bad_Channels)
            if Data.Mo.Bad_Channels(j) == Data.Mo.Channels(i)
                check = 1;
            end
        end
        if check == 0
            Data.Mo.Good_Channels(end+1) = Data.Mo.Channels(i);
        end
        check = 0;
    end
         
    Data.Mi.Good_Channels = [];
    check = 0;
    for i = 1:length(Data.Mi.Channels)
        for j = 1:length(Data.Mi.Bad_Channels)
            if Data.Mi.Bad_Channels(j) == Data.Mi.Channels(i)
                check = 1;
            end
        end
        if check == 0
            Data.Mi.Good_Channels(end+1) = Data.Mi.Channels(i);
        end
        check = 0;
    end
    
    Data.T01.Good_Channels = [];
    check = 0;
    for i = 1:length(Data.T01.Channels)
        for j = 1:length(Data.T01.Bad_Channels)
            if Data.T01.Bad_Channels(j) == Data.T01.Channels(i)
                check = 1;
            end
        end
        if check == 0
            Data.T01.Good_Channels(end+1) = Data.T01.Channels(i);
        end
        check = 0;
    end
    
    % Avverage the data
    Co_Avv = mean(Data.SData(:,Data.Co.Good_Channels),2);
    Ci_Avv = mean(Data.SData(:,Data.Ci.Good_Channels),2);
    Fo_Avv = mean(Data.SData(:,Data.Fo.Good_Channels),2);
    Fi_Avv = mean(Data.SData(:,Data.Fi.Good_Channels),2);
    Jo_Avv = mean(Data.SData(:,Data.Jo.Good_Channels),2);
    Ji_Avv = mean(Data.SData(:,Data.Ji.Good_Channels),2);
    Mo_Avv = mean(Data.SData(:,Data.Mo.Good_Channels),2);
    Mi_Avv = mean(Data.SData(:,Data.Mi.Good_Channels),2);
    T01 = mean(Data.SData(:,Data.T01.Good_Channels),2);
    
    % Set up calc arrays
    T01 = Data.T01.issen;
    P01 = Data.SData(:,Data.P01.Channels);
    P2 = (Co_Avv+Ci_Avv)/2;
    P3 = (Fo_Avv+Fi_Avv)/2;
    STime = decimate(Data.STime,20);
    
    % Target values
    No_target = 460.48; % Non-dimensioal speed (N/T01)
    Pr_target = 3.1654;   % Pressure ration (P01/P3)
    Re_target = 2.7e6;  % Reynolds number based on NGV axial chord
    
    Pr = decimate(P01./P3,20,'FIR');
    No = decimate(Data.SData(:,Data.Speed.Channels)./sqrt(T01),20,'FIR');
        
    M = abs(sqrt(2/(1.396-1)*((P01./P2).^((1-1.396)/1.396)-1)));        
    T = T01./(1+(1.396-1)/2*M.^2);
    rho = P2./(287*T);
    u = M.*sqrt(1.396*287*T);
    Re = u*31.212e-3.*rho/18.1e-6;
    Re = decimate(Re,20,'FIR');
    
    set(Data.figure,'menubar','figure')
    figure_name = get(Data.figure,'name');
    run_number = str2num(figure_name(27:30));
    
    title(['Normalised non-dimensional parameters run-' figure_name(27:30)])
    plot(STime,Pr/Pr_target,'b',STime,No/No_target,'r',STime,Re/Re_target,'g')
    legend('Pressure ratio','0D speed','Reynolds number')
    grid on
    
    error = abs(Pr/Pr_target-1)+abs(No/No_target-1);
    [min,index] = min(error);
    
    % Save good data channels
    Channels.Co = Data.Co.Good_Channels;
    Channels.Ci = Data.Ci.Good_Channels;
    Channels.Fo = Data.Fo.Good_Channels;
    Channels.Fi = Data.Fi.Good_Channels;
    Channels.Jo = Data.Jo.Good_Channels;
    Channels.Ji = Data.Ji.Good_Channels;
    Channels.Mo = Data.Mo.Good_Channels;
    Channels.Mi = Data.Mi.Good_Channels;
    Channels.T01 = Data.T01.Good_Channels;
    
    eval(['save Good_Channels_' num2str(run_number) ' Channels']); 
    
    % Save match point
    eval(['load r' num2str(run_number) 'eu.mat']);
    eu.match = [STime(index) index];
    eval(['save r' num2str(run_number) 'eu.mat eu']);
end
end