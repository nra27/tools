
function [estimates, model] = erfc_Fit_Estimate(xdata,ydata)

% Call fminsearch with a random starting point.
start_point = rand(1, 2);
model = @expfun;
estimates = fminsearch(model, start_point);

% expfun accepts curve parameters as inputs, and outputs sse,
% the sum of squares error for A*exp(-lambda*xdata)-ydata,

    function [sse, FittedCurve] = expfun(params)
        DT = params(1);
        alpha = params(2);
        
        FittedCurve = DT*(1- erfc(alpha*xdata));
        
        ErrorVector = FittedCurve - ydata;
        sse = sum(ErrorVector .^ 2);
    end
end