function curve = Profile_Curvature(R,Theta,X);
%
% curve = Profile_Curvature(R,Theta,X)
% A function to calculate the streamline curvature of a Rolls-Royce
% blade profile.  R, Theta and X are the profile coordinates, from 
% LE to LE.

% Convert to XYZ coordinates
Y = R.*cos(Theta);
Z = R.*sin(Theta);

% Trip repeated LE point
X = X(1:end-1);
Y = Y(1:end-1);
Z = Z(1:end-1);

% Wrap for correct differentiation
X = [X(end-1);X(end);X;X(1);X(2)];
Y = [Y(end-1);Y(end);Y;Y(1);Y(2)];
Z = [Z(end-1);Z(end);Z;Z(1);Y(2)];

S = sqrt((X(3:end)-X(2:end-1)).^2+(Y(3:end)-Y(2:end-1)).^2+(Y(3:end)-Y(2:end-1)).^2);
s = sqrt((X(2:end-1)-X(1:end-2)).^2+(Y(2:end-1)-Y(1:end-2)).^2+(Y(2:end-1)-Y(1:end-2)).^2);   

GX = (X(3:end)-X(1:end-2))./(S+s);
GY = (Y(3:end)-Y(1:end-2))./(S+s);
GZ = (Z(3:end)-Z(1:end-2))./(S+s);

TX = (GX(3:end)-GX(1:end-2))./(S(2:end-1)+s(2:end-1));
TY = (GY(3:end)-GY(1:end-2))./(S(2:end-1)+s(2:end-1));
TZ = (GZ(3:end)-GZ(1:end-2))./(S(2:end-1)+s(2:end-1));

curve = sqrt(TX.^2+TY.^2+TZ.^2);
curve(end+1) = curve(1);