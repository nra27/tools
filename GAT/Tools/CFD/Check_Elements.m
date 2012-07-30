function check = Check_Elements(elements,face,type);
%
% A function to find out if a given face is in the list
% of faces(elements).

if isempty(elements)
    check = 0;
    return
end

switch type
case 'q'    % Quad
    % Do a two tiered search
    band = find(sum(elements(:,1:4),2) == sum(face));
    
    % This should narrow the search down a lot!
    if isempty(band) % We deffinately don't have it
        check = 0;
        return
    else
        % So we might have it.
        % For perm 1
        order = perms(1:4);
        for i = 1:24
            a1 = find(elements(band,1) == face(order(i,1)));
            a2 = find(elements(band,2) == face(order(i,2)));
            a3 = find(elements(band,3) == face(order(i,3)));
            a4 = find(elements(band,4) == face(order(i,4)));
            
            if isempty(a1) | isempty(a2) | isempty(a3) | isempty(a4)
                continue
            end
            
            test = [a1;a2;a3;a4];
            for i = 1:length(test)
                a = sum(test == test(i));
                if a == 4
                    check = band(test(i));
                    return
                end
            end
        end
        check = 0;
    end
    
case 't' % Triangle
    % Again use two tiered search
    band = find(sum(elements(:,1:3),2) == sum(face));
    
    % This should narrow the search down a lot!
    if isempty(band) % We deffinately don't have it
        check = 0;
        return
    else
        % So we might have it.
        % For perm 1
        order = perms(1:3);
        for i = 1:6
            a1 = find(elements(band,1) == face(order(i,1)));
            a2 = find(elements(band,2) == face(order(i,2)));
            a3 = find(elements(band,3) == face(order(i,3)));
            
            if isempty(a1) | isempty(a2) | isempty(a3)
                continue
            end
            
            test = [a1;a2;a3];
            for i = 1:length(test)
                a = sum(test == test(i));
                if a == 3
                    check = band(test(i));
                    return
                end
            end
        end
        check = 0;
    end
end