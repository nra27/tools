% Initialiase sums
Spv2 = 0;
Spv3 = 0;
Spv5 = 0;
Spv6 = 0;
Spv8 = 0;
Spv10 = 0;
Sv2 = 0;
Sv3 = 0;
Sv5 = 0;
Sv6 = 0;
Sv8 = 0;
Sv10 = 0;

figure(2)
set(2,'NumberTitle','off','Name','Kuc2')
plot(0,0,'k*')
hold on

figure(3)
set(3,'NumberTitle','off','Name','Kuc3')
plot(0,0,'k*')
hold on

figure(5)
set(5,'NumberTitle','off','Name','Kuc5')
plot(0,0,'k*')
hold on

figure(6)
set(6,'NumberTitle','off','Name','Kuc6')
plot(0,0,'k*')
hold on

figure(8)
set(8,'NumberTitle','off','Name','Kuc8')
plot(0,0,'k*')
hold on

figure(10)
set(10,'NumberTitle','off','Name','Kuc10')
plot(0,0,'k*')
hold on

% First set of runs
runs = [8118];
for run = 1:length(runs)
    % Change directory
    cd(['../run_' num2str(runs(run))]);
    eval(['load r' num2str(runs(run)) 'c;']);
    
    [points,gauge] = size(FData);
    for i = 1:gauge-1
        FData(:,i) = FData(:,i)-mean(FData(1:50,i));
        FData(:,i) = FData(:,i).*FData(:,gauge)/5;
    end
    
    PData(:,1) = FData(:,1)/9.9895e-8;
    PData(:,4) = FData(:,4)/8.8979e-8;
    
    p1 = mean(PData(end-50:end,1));
    p4 = mean(PData(end-50:end,4));
    
    v2 = mean(FData(end-50:end,2));
    v3 = mean(FData(end-50:end,3));
    v5 = mean(FData(end-50:end,5));
    v6 = mean(FData(end-50:end,6));
    v8 = mean(FData(end-50:end,8));
    
    figure(2)
    h1 = plot(v2,p1,'r*');
    h2 = plot(v2,p4,'r*');
    s = input('Is this gauge behaving?  :','s');
    if strcmp(s,'y');
        Sv2 = Sv2+2*v2*v2;
        Spv2 = Spv2+p1*v2+p4*v2;
        set(h1,'color',[0 0 0]);
        set(h2,'color',[0 0 0]);
    else
        delete(h1);
        delete(h2);
    end
    figure(3)
    h1 = plot(v3,p1,'r*');
    h2 = plot(v3,p4,'r*');
    s = input('Is this gauge behaving?  :','s');
    if strcmp(s,'y');
        Sv3 = Sv3+2*v3*v3;
        Spv3 = Spv3+p1*v3+p4*v3;
        set(h1,'color',[0 0 0]);
        set(h2,'color',[0 0 0]);
    else
        delete(h1);
        delete(h2);
    end
    figure(5)
    h1 = plot(v5,p1,'r*');
    h2 = plot(v5,p4,'r*');
    s = input('Is this gauge behaving?  :','s');
    if strcmp(s,'y');
        Sv5 = Sv5+2*v5*v5;
        Spv5 = Spv5+p1*v5+p4*v5;
        set(h1,'color',[0 0 0]);
        set(h2,'color',[0 0 0]);
    else
        delete(h1);
        delete(h2);
    end
    figure(6)
    h1 = plot(v6,p1,'r*');
    h2 = plot(v6,p4,'r*');
    s = input('Is this gauge behaving?  :','s');
    if strcmp(s,'y');
        Sv6 = Sv6+2*v6*v6;
        Spv6 = Spv6+p1*v6+p4*v6;
        set(h1,'color',[0 0 0]);
        set(h2,'color',[0 0 0]);
    else
        delete(h1);
        delete(h2);
    end
    figure(8)
    h1 = plot(v8,p1,'r*');
    h2 = plot(v8,p4,'r*');
    s = input('Is this gauge behaving?  :','s');
    if strcmp(s,'y');
        Sv8 = Sv8+2*v8*v8;
        Spv8 = Spv8+p1*v8+p4*v8;
        set(h1,'color',[0 0 0]);
        set(h2,'color',[0 0 0]);
    else
        delete(h1);
        delete(h2);
    end
end

% Nextset of runs
runs = [8119 8120 8121];
for run = 1:length(runs)
    % Change directory
    cd(['../run_' num2str(runs(run))]);
    eval(['load r' num2str(runs(run)) 'c;']);
    
    [points,gauge] = size(FData);
    for i = 1:gauge-1
        FData(:,i) = FData(:,i)-mean(FData(1:50,i));
        FData(:,i) = FData(:,i).*FData(:,gauge)/5;
    end
    
    PData(:,1) = FData(:,1)/9.9895e-8;
    PData(:,4) = FData(:,4)/8.8979e-8;
    
    p1 = mean(PData(end-50:end,1));
    p4 = mean(PData(end-50:end,4));
    
    v2 = mean(FData(end-50:end,2));
    v3 = mean(FData(end-50:end,3));
    v5 = mean(FData(end-50:end,5));
    v6 = mean(FData(end-50:end,6));
    v8 = mean(FData(end-50:end,7));
    
    figure(2)
    h1 = plot(v2,p1,'r*');
    h2 = plot(v2,p4,'r*');
    s = input('Is this gauge behaving?  :','s');
    if strcmp(s,'y');
        Sv2 = Sv2+2*v2*v2;
        Spv2 = Spv2+p1*v2+p4*v2;
        set(h1,'color',[0 0 0]);
        set(h2,'color',[0 0 0]);
    else
        delete(h1);
        delete(h2);
    end
    figure(3)
    h1 = plot(v3,p1,'r*');
    h2 = plot(v3,p4,'r*');
    s = input('Is this gauge behaving?  :','s');
    if strcmp(s,'y');
        Sv3 = Sv3+2*v3*v3;
        Spv3 = Spv3+p1*v3+p4*v3;
        set(h1,'color',[0 0 0]);
        set(h2,'color',[0 0 0]);
    else
        delete(h1);
        delete(h2);
    end
    figure(5)
    h1 = plot(v5,p1,'r*');
    h2 = plot(v5,p4,'r*');
    s = input('Is this gauge behaving?  :','s');
    if strcmp(s,'y');
        Sv5 = Sv5+2*v5*v5;
        Spv5 = Spv5+p1*v5+p4*v5;
        set(h1,'color',[0 0 0]);
        set(h2,'color',[0 0 0]);
    else
        delete(h1);
        delete(h2);
    end
    figure(6)
    h1 = plot(v6,p1,'r*');
    h2 = plot(v6,p4,'r*');
    s = input('Is this gauge behaving?  :','s');
    if strcmp(s,'y');
        Sv6 = Sv6+2*v6*v6;
        Spv6 = Spv6+p1*v6+p4*v6;
        set(h1,'color',[0 0 0]);
        set(h2,'color',[0 0 0]);
    else
        delete(h1);
        delete(h2);
    end
    figure(8)
    h1 = plot(v8,p1,'r*');
    h2 = plot(v8,p4,'r*');
    s = input('Is this gauge behaving?  :','s');
    if strcmp(s,'y');
        Sv8 = Sv8+2*v8*v8;
        Spv8 = Spv8+p1*v8+p4*v8;
        set(h1,'color',[0 0 0]);
        set(h2,'color',[0 0 0]);
    else
        delete(h1);
        delete(h2);
    end
end

% 3rd set of runs
runs = [8122 8123];
for run = 1:length(runs)
    % Change directory
    cd(['../run_' num2str(runs(run))]);
    eval(['load r' num2str(runs(run)) 'c;']);
    
    [points,gauge] = size(FData);
    for i = 1:gauge-1
        FData(:,i) = FData(:,i)-mean(FData(1:50,i));
        FData(:,i) = FData(:,i).*FData(:,gauge)/5;
    end
    
    PData(:,1) = FData(:,1)/9.9895e-8;
    PData(:,4) = FData(:,3)/8.8979e-8;
    
    p1 = mean(PData(end-50:end,1));
    p4 = mean(PData(end-50:end,4));
    
    v2 = mean(FData(end-50:end,2));
    v5 = mean(FData(end-50:end,4));
    v6 = mean(FData(end-50:end,5));
    
    figure(2)
    h1 = plot(v2,p1,'r*');
    h2 = plot(v2,p4,'r*');
    s = input('Is this gauge behaving?  :','s');
    if strcmp(s,'y');
        Sv2 = Sv2+2*v2*v2;
        Spv2 = Spv2+p1*v2+p4*v2;
        set(h1,'color',[0 0 0]);
        set(h2,'color',[0 0 0]);
    else
        delete(h1);
        delete(h2);
    end
    figure(5)
    h1 = plot(v5,p1,'r*');
    h2 = plot(v5,p4,'r*');
    s = input('Is this gauge behaving?  :','s');
    if strcmp(s,'y');
        Sv5 = Sv5+2*v5*v5;
        Spv5 = Spv5+p1*v5+p4*v5;
        set(h1,'color',[0 0 0]);
        set(h2,'color',[0 0 0]);
    else
        delete(h1);
        delete(h2);
    end
    figure(6)
    h1 = plot(v6,p1,'r*');
    h2 = plot(v6,p4,'r*');
    s = input('Is this gauge behaving?  :','s');
    if strcmp(s,'y');
        Sv6 = Sv6+2*v6*v6;
        Spv6 = Spv6+p1*v6+p4*v6;
        set(h1,'color',[0 0 0]);
        set(h2,'color',[0 0 0]);
    else
        delete(h1);
        delete(h2);
    end
end

% 4th of runs
runs = [8124:8127];
for run = 1:length(runs)
    % Change directory
    cd(['../run_' num2str(runs(run))]);
    eval(['load r' num2str(runs(run)) 'c;']);
    
    [points,gauge] = size(FData);
    for i = 1:gauge-1
        FData(:,i) = FData(:,i)-mean(FData(1:50,i));
        FData(:,i) = FData(:,i).*FData(:,gauge)/5;
    end
    
    PData(:,1) = FData(:,1)/9.9895e-8;
    PData(:,9) = FData(:,3)/8.9353e-8;
    PData(:,4) = FData(:,4)/8.8979e-8;
    
    p1 = mean(PData(end-50:end,1));
    p4 = mean(PData(end-50:end,4));
    p9 = mean(PData(end-50:end,9));
    
    v2 = mean(FData(end-50:end,2));
    v5 = mean(FData(end-50:end,5));
    v6 = mean(FData(end-50:end,6));
    
    figure(2)
    h1 = plot(v2,p1,'r*');
    h2 = plot(v2,p4,'r*');
    h3 = plot(v2,p9,'r*');
    s = input('Is this gauge behaving?  :','s');
    if strcmp(s,'y');
        Sv2 = Sv2+3*v2*v2;
        Spv2 = Spv2+p1*v2+p4*v2+p9*v2;
        set(h1,'color',[0 0 0]);
        set(h2,'color',[0 0 0]);
        set(h3,'color',[0 0 0]);
    else
        delete(h1);
        delete(h2);
        delete(h3);
    end
    figure(5)
    h1 = plot(v5,p1,'r*');
    h2 = plot(v5,p4,'r*');
    h3 = plot(v5,p9,'r*');
    s = input('Is this gauge behaving?  :','s');
    if strcmp(s,'y');
        Sv5 = Sv5+3*v5*v5;
        Spv5 = Spv5+p1*v5+p4*v5+p9*v5;
        set(h1,'color',[0 0 0]);
        set(h2,'color',[0 0 0]);
        set(h3,'color',[0 0 0]);
    else
        delete(h1);
        delete(h2);
        delete(h3);
    end
    figure(6)
    h1 = plot(v6,p1,'r*');
    h2 = plot(v6,p4,'r*');
    h3 = plot(v6,p9,'r*');
    s = input('Is this gauge behaving?  :','s');
    if strcmp(s,'y');
        Sv6 = Sv6+3*v6*v6;
        Spv6 = Spv6+p1*v6+p4*v6+p9*v6;
        set(h1,'color',[0 0 0]);
        set(h2,'color',[0 0 0]);
        set(h3,'color',[0 0 0]);
    else
        delete(h1);
        delete(h2);
        delete(h3);
    end
end

% 5th set of runs
runs = [8128:8134];
for run = 1:length(runs)
    % Change directory
    cd(['../run_' num2str(runs(run))]);
    eval(['load r' num2str(runs(run)) 'c;']);
    
    [points,gauge] = size(FData);
    for i = 1:gauge-1
        FData(:,i) = FData(:,i)-mean(FData(1:50,i));
        FData(:,i) = FData(:,i).*FData(:,gauge)/5;
    end
    
    PData(:,1) = FData(:,1)/9.9895e-8;
    PData(:,9) = FData(:,3)/8.9353e-8;
    PData(:,4) = FData(:,4)/8.8979e-8;
    
    p1 = mean(PData(end-50:end,1));
    p4 = mean(PData(end-50:end,4));
    p9 = mean(PData(end-50:end,9));
    
    v2 = mean(FData(end-50:end,2));
    v10 = mean(FData(end-50:end,5));
    
    figure(2)
    h1 = plot(v2,p1,'r*');
    h2 = plot(v2,p4,'r*');
    h3 = plot(v2,p9,'r*');
    s = input('Is this gauge behaving?  :','s');
    if strcmp(s,'y');
        Sv2 = Sv2+3*v2*v2;
        Spv2 = Spv2+p1*v2+p4*v2+p9*v2;
        set(h1,'color',[0 0 0]);
        set(h2,'color',[0 0 0]);
        set(h3,'color',[0 0 0]);
    else
        delete(h1);
        delete(h2);
        delete(h3);
    end
    figure(10)
    h1 = plot(v10,p1,'r*');
    h2 = plot(v10,p4,'r*');
    h3 = plot(v10,p9,'r*');
    s = input('Is this gauge behaving?  :','s');
    if strcmp(s,'y');
        Sv10 = Sv10+3*v10*v10;
        Spv10 = Spv10+p1*v10+p4*v10+p9*v10;
        set(h1,'color',[0 0 0]);
        set(h2,'color',[0 0 0]);
        set(h3,'color',[0 0 0]);
    else
        delete(h1);
        delete(h2);
        delete(h3);
    end
end

% 6th set of runs
runs = [8135:8139];
for run = 1:length(runs)
    % Change directory
    cd(['../run_' num2str(runs(run))]);
    eval(['load r' num2str(runs(run)) 'c;']);
    
    [points,gauge] = size(FData);
    for i = 1:gauge-1
        FData(:,i) = FData(:,i)-mean(FData(1:50,i));
        FData(:,i) = FData(:,i).*FData(:,gauge)/5;
    end
    
    PData(:,1) = FData(:,1)/9.9895e-8;
    PData(:,9) = FData(:,2)/8.9353e-8;
    PData(:,4) = FData(:,3)/8.8979e-8;
    
    p1 = mean(PData(end-50:end,1));
    p4 = mean(PData(end-50:end,4));
    p9 = mean(PData(end-50:end,9));
    
    v10 = mean(FData(end-50:end,4));
    
    figure(10)
    h1 = plot(v10,p1,'r*');
    h2 = plot(v10,p4,'r*');
    h3 = plot(v10,p9,'r*');
    s = input('Is this gauge behaving?  :','s');
    if strcmp(s,'y');
        Sv10 = Sv10+3*v10*v10;
        Spv10 = Spv10+p1*v10+p4*v10+p9*v10;
        set(h1,'color',[0 0 0]);
        set(h2,'color',[0 0 0]);
        set(h3,'color',[0 0 0]);
    else
        delete(h1);
        delete(h2);
        delete(h3);
    end
end

% 7th set of runs
runs = [8140];
for run = 1:length(runs)
    % Change directory
    cd(['../run_' num2str(runs(run))]);
    eval(['load r' num2str(runs(run)) 'c;']);
    
    [points,gauge] = size(FData);
    for i = 1:gauge-1
        FData(:,i) = FData(:,i)-mean(FData(1:50,i));
        FData(:,i) = FData(:,i).*FData(:,gauge)/5;
    end
    
    PData(:,1) = FData(:,1)/9.9895e-8;
    PData(:,9) = FData(:,3)/8.9353e-8;
    PData(:,4) = FData(:,4)/8.8979e-8;
    
    p1 = mean(PData(end-50:end,1));
    p4 = mean(PData(end-50:end,4));
    p9 = mean(PData(end-50:end,9));
    
    v2 = mean(FData(end-50:end,2));
    v10 = mean(FData(end-50:end,5));
    
    figure(2)
    h1 = plot(v2,p1,'r*');
    h2 = plot(v2,p4,'r*');
    h3 = plot(v2,p9,'r*');
    s = input('Is this gauge behaving?  :','s');
    if strcmp(s,'y');
        Sv2 = Sv2+3*v2*v2;
        Spv2 = Spv2+p1*v2+p4*v2+p9*v2;
        set(h1,'color',[0 0 0]);
        set(h2,'color',[0 0 0]);
        set(h3,'color',[0 0 0]);
    else
        delete(h1);
        delete(h2);
        delete(h3);
    end
    figure(10)
    h1 = plot(v10,p1,'r*');
    h2 = plot(v10,p4,'r*');
    h3 = plot(v10,p9,'r*');
    s = input('Is this gauge behaving?  :','s');
    if strcmp(s,'y');
        Sv10 = Sv10+3*v10*v10;
        Spv10 = Spv10+p1*v10+p4*v10+p9*v10;
        set(h1,'color',[0 0 0]);
        set(h2,'color',[0 0 0]);
        set(h3,'color',[0 0 0]);
    else
        delete(h1);
        delete(h2);
        delete(h3);
    end
end

% 6th set of runs
runs = [8141:8142];
for run = 1:length(runs)
    % Change directory
    cd(['../run_' num2str(runs(run))]);
    eval(['load r' num2str(runs(run)) 'c;']);
    
    [points,gauge] = size(FData);
    for i = 1:gauge-1
        FData(:,i) = FData(:,i)-mean(FData(1:50,i));
        FData(:,i) = FData(:,i).*FData(:,gauge)/5;
    end
    
    PData(:,1) = FData(:,1)/9.9895e-8;
    PData(:,9) = FData(:,2)/8.9353e-8;
    PData(:,4) = FData(:,3)/8.8979e-8;
    
    p1 = mean(PData(end-50:end,1));
    p4 = mean(PData(end-50:end,4));
    p9 = mean(PData(end-50:end,9));
    
    v10 = mean(FData(end-50:end,4));
    
    figure(10)
    h1 = plot(v10,p1,'r*');
    h2 = plot(v10,p4,'r*');
    h3 = plot(v10,p9,'r*');
    s = input('Is this gauge behaving?  :','s');
    if strcmp(s,'y');
        Sv10 = Sv10+3*v10*v10;
        Spv10 = Spv10+p1*v10+p4*v10+p9*v10;
        set(h1,'color',[0 0 0]);
        set(h2,'color',[0 0 0]);
        set(h3,'color',[0 0 0]);
    else
        delete(h1);
        delete(h2);
        delete(h3);
    end
end

k2 = Spv2/Sv2
k3 = Spv3/Sv3
k5 = Spv5/Sv5
k6 = Spv6/Sv6
k8 = Spv8/Sv8
k10 = Spv10/Sv10