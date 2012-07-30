function New_Data = Upsample_Casing_Data(Data);
%
% Data = Upsample_Casing_Data(Data)
%
% A function to upsample the rotor casing data taking into
% account phase and amplitude.

% Data is upsampled by adding 10 points
add = 9;
New_Data = zeros(144,((add+1)*6+1)*8);

% Gauge loop
for gauge = 1:48
    base1 = Data(:,gauge);
    base2 = Data(:,gauge+8);
    
    % Remove phase difference from base2 to match base1
    base2 = [base2(end-39:end); base2(1:end-40)];
    
    % Interpolation loop
    for i = 0:add
        % Amplitude
        new = base1+(base2-base1)*i/(add+1);
        
        if i ~= 0
            % Phase
            new = [new((40/(add+1)*i+1):end); new(1:(40/(add+1)*i))];
        end
        
        % New location
        if rem(gauge,8) == 0
            location = 8+80*(floor(gauge/8)-1)+8*i;
        else
            location = rem(gauge,8)+80*floor(gauge/8)+8*i;
        end
        
        New_Data(:,location) = new;
    end
end

New_Data(:,481:488) = Data(:,49:56);