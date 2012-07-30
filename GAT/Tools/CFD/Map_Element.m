function P = Map_Element(B,M,element);
%
% P = Map_Element(B,M,element);
%
% A routine to find the mapped coordinates
% in function space for a given point
% in real space.
% B is the vector of target points
% M is the shape function matrix
% element is the type of element
%
% The equation solved is I*M-B=0 where I is
% the vector of mapped coordinates

% Warnings off
warning off

% Step length for differentiation
step = 10*eps;

switch element
case 'quad'
    P = [0 0]';     % Initial solution
    I = [P(1) P(2) P(1)*P(2)]';
    E = M*I-B;      % Initial error
    
    while sum(abs(E)) > eps*100
        % Setup gradient steps
        I_px = [P(1)+step P(2) (P(1)+step)*P(2)]';
        I_mx = [P(1)-step P(2) (P(1)-step)*P(2)]';
        I_py = [P(1) P(2)+step P(1)*(P(2)+step)]';
        I_my = [P(1) P(2)-step P(1)*(P(2)-step)]';
        E_px = M*I_px-B;
        E_mx = M*I_mx-B;
        E_py = M*I_py-B;
        E_my = M*I_my-B;
        
        % Calculate Jacobian
        J = [(E_px(1)-E_mx(1))/(2*step) (E_py(1)-E_my(1))/(2*step);...
                (E_px(2)-E_mx(2))/(2*step) (E_py(2)-E_my(2))/(2*step)];
        
        % Newton-Ralfson approximation
        dP = inv(J)*E;
        
        P = P-dP;   % New solution
        I = [P(1) P(2) P(1)*P(2)]'; 
        E = M*I-B;  % New error
    end
case 'hex'
    P = [0 0 0]';     % Initial solution
    I = [P(1) P(2) P(3) P(1)*P(2) P(1)*P(3) P(2)*P(3) P(1)*P(2)*P(3)]';
    E = M*I-B;      % Initial error
    
    while sum(abs(E)) > eps*100
        % Setup gradient steps
        I_px = [(P(1)+step) P(2) P(3) (P(1)+step)*P(2) (P(1)+step)*P(3) P(2)*P(3) (P(1)+step)*P(2)*P(3)]';
        I_mx = [(P(1)-step) P(2) P(3) (P(1)-step)*P(2) (P(1)-step)*P(3) P(2)*P(3) (P(1)-step)*P(2)*P(3)]';
        I_py = [P(1) (P(2)+step) P(3) P(1)*(P(2)+step) P(1)*P(3) (P(2)+step)*P(3) P(1)*(P(2)+step)*P(3)]';
        I_my = [P(1) (P(2)-step) P(3) P(1)*(P(2)-step) P(1)*P(3) (P(2)-step)*P(3) P(1)*(P(2)-step)*P(3)]';
        I_pz = [P(1) P(2) (P(3)+step) P(1)*P(2) P(1)*(P(3)+step) P(2)*(P(3)+step) P(1)*P(2)*(P(3)+step)]';
        I_mz = [P(1) P(2) (P(3)-step) P(1)*P(2) P(1)*(P(3)-step) P(2)*(P(3)-step) P(1)*P(2)*(P(3)-step)]';        
        E_px = M*I_px-B;
        E_mx = M*I_mx-B;
        E_py = M*I_py-B;
        E_my = M*I_my-B;
        E_pz = M*I_pz-B;
        E_mz = M*I_mz-B;
        
        % Calculate Jacobian
        J = [(E_px(1)-E_mx(1))/(2*step) (E_py(1)-E_my(1))/(2*step) (E_pz(1)-E_mz(1))/(2*step) ;...
                (E_px(2)-E_mx(2))/(2*step) (E_py(2)-E_my(2))/(2*step) (E_pz(2)-E_mz(2))/(2*step) ; ...
                (E_px(3)-E_mx(3))/(2*step) (E_py(3)-E_my(3))/(2*step) (E_pz(3)-E_mz(3))/(2*step)];
        
        % Newton-Ralfson approximation
        dP = inv(J)*E;
        
        P = P-dP;   % New solution
        I = [P(1) P(2) P(3) P(1)*P(2) P(1)*P(3) P(2)*P(3) P(1)*P(2)*P(3)]'; 
        E = M*I-B;  % New error
    end
case 'piramid'
    P = [0 0 0.5]';     % Initial solution
    I = [P(1) P(2) P(3) P(1)*P(2) P(1)*P(3) P(2)*P(3) P(1)*P(2)*P(3)]';
    E = M*I-B;      % Initial error
    
    while sum(abs(E)) > eps*100
        % Setup gradient steps
        I_px = [(P(1)+step) P(2) P(3) (P(1)+step)*P(2) (P(1)+step)*P(3) P(2)*P(3) (P(1)+step)*P(2)*P(3)]';
        I_mx = [(P(1)-step) P(2) P(3) (P(1)-step)*P(2) (P(1)-step)*P(3) P(2)*P(3) (P(1)-step)*P(2)*P(3)]';
        I_py = [P(1) (P(2)+step) P(3) P(1)*(P(2)+step) P(1)*P(3) (P(2)+step)*P(3) P(1)*(P(2)+step)*P(3)]';
        I_my = [P(1) (P(2)-step) P(3) P(1)*(P(2)-step) P(1)*P(3) (P(2)-step)*P(3) P(1)*(P(2)-step)*P(3)]';
        I_pz = [P(1) P(2) (P(3)+step) P(1)*P(2) P(1)*(P(3)+step) P(2)*(P(3)+step) P(1)*P(2)*(P(3)+step)]';
        I_mz = [P(1) P(2) (P(3)-step) P(1)*P(2) P(1)*(P(3)-step) P(2)*(P(3)-step) P(1)*P(2)*(P(3)-step)]';        
        E_px = M*I_px-B;
        E_mx = M*I_mx-B;
        E_py = M*I_py-B;
        E_my = M*I_my-B;
        E_pz = M*I_pz-B;
        E_mz = M*I_mz-B;
        
        % Calculate Jacobian
        J = [(E_px(1)-E_mx(1))/(2*step) (E_py(1)-E_my(1))/(2*step) (E_pz(1)-E_mz(1))/(2*step) ;...
                (E_px(2)-E_mx(2))/(2*step) (E_py(2)-E_my(2))/(2*step) (E_pz(2)-E_mz(2))/(2*step) ; ...
                (E_px(3)-E_mx(3))/(2*step) (E_py(3)-E_my(3))/(2*step) (E_pz(3)-E_mz(3))/(2*step)];
        
        % Newton-Ralfson approximation
        dP = inv(J)*E;
        
        P = P-dP;   % New solution
        I = [P(1) P(2) P(3) P(1)*P(2) P(1)*P(3) P(2)*P(3) P(1)*P(2)*P(3)]'; 
        E = M*I-B;  % New error
    end
case 'prism'
    P = [0.5 0.5 0.5]';     % Initial solution
    I = [P(1) P(2) P(3) P(1)*P(3) P(2)*P(3)]';
    E = M*I-B;      % Initial error
    
    while sum(abs(E)) > eps*100
        % Setup gradient steps
        I_px = [(P(1)+step) P(2) P(3) (P(1)+step)*P(3) P(2)*P(3)]';
        I_mx = [(P(1)-step) P(2) P(3) (P(1)-step)*P(3) P(2)*P(3)]';
        I_py = [P(1) (P(2)+step) P(3) P(1)*P(3) (P(2)+step)*P(3)]';
        I_my = [P(1) (P(2)-step) P(3) P(1)*P(3) (P(2)-step)*P(3)]';
        I_pz = [P(1) P(2) (P(3)+step) P(1)*(P(3)+step) P(2)*(P(3)+step)]';
        I_mz = [P(1) P(2) (P(3)-step) P(1)*(P(3)-step) P(2)*(P(3)-step)]';        
        E_px = M*I_px-B;
        E_mx = M*I_mx-B;
        E_py = M*I_py-B;
        E_my = M*I_my-B;
        E_pz = M*I_pz-B;
        E_mz = M*I_mz-B;
        
        % Calculate Jacobian
        J = [(E_px(1)-E_mx(1))/(2*step) (E_py(1)-E_my(1))/(2*step) (E_pz(1)-E_mz(1))/(2*step) ;...
                (E_px(2)-E_mx(2))/(2*step) (E_py(2)-E_my(2))/(2*step) (E_pz(2)-E_mz(2))/(2*step) ; ...
                (E_px(3)-E_mx(3))/(2*step) (E_py(3)-E_my(3))/(2*step) (E_pz(3)-E_mz(3))/(2*step)];
        
        % Newton-Ralfson approximation
        dP = inv(J)*E;
        
        P = P-dP;   % New solution
        I = [P(1) P(2) P(3) P(1)*P(3) P(2)*P(3)]'; 
        E = M*I-B;  % New error
    end
end

% Warning on
warning on