function coefs = Line_Fit(x,y,sign);
%
% coefs = Line_Fit(x,y)
% A function to give the perpendicular least sqares fit

% Check that x and y are the same length
if length(x) ~= length(y)
    Disp('Vectors must be the same length!')
    return
end

n = length(x);

D = sum(y.^2)-(sum(y))^2/n;
E = sum(x.^2)-(sum(x))^2/n;

F = sum(x)*sum(y)/n-sum(x.*y);

B = (D-E)/(2*F);

if sign == 1
    b = -B+sqrt(B^2+1);
elseif sign == -1
    b = -B-sqrt(B^2+1);
else
    disp('This is not a valid option')
    return
end
    
a = mean(y)-b*mean(x);

%keyboard

coefs = [b a];