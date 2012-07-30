function index = Find_Nearest_Node(varargin);
%
% index = Find_Nearest_Node(x,y,[z],X,Y,[Z],n)
%
% This function returns the index of the arrays X,Y,Z that
% produces the smallest pythagorean distance to the desired
% point.

if nargin == 5
    x = varargin{1};
    y = varargin{2};
    X = varargin{3};
    Y = varargin{4};
    n = varargin{5};

    error_sum = sqrt((X-x).^2+(Y-y).^2);
    index = zeros(1,n);
    
    m = max(error_sum);
    
    for i = 1:n
        [value,index(i)] = min(error_sum);
        error_sum(index(i)) = m;
    end
elseif nargin == 7
    x = varargin{1};
    y = varargin{2};
    z = varargin{3};
    X = varargin{4};
    Y = varargin{5};
    Z = varargin{6};
    n = varargin{7};

    error_sum = sqrt((X-x).^2+(Y-y).^2+(Z-z).^2);
    index = zeros(1,n);
    
    m = max(error_sum);
    
    for i = 1:n
        [value,index(i)] = min(error_sum);
        error_sum(index(i)) = m;
    end
end