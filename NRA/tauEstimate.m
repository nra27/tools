
function [estimates, model] = tauEstimate(xdata,ydata)

% Call fminsearch with a random starting point.
start_point = rand(1, 2);
model = @expfun;
estimates = fminsearch(model, start_point);

% expfun accepts curve parameters as inputs, and outputs sse,
% the sum of squares error for A*exp(-lambda*xdata)-ydata,

    function [sse, FittedCurve] = expfun(params)
        DT = params(1);
        lambda = params(2);
        FittedCurve = ydata(1) - DT .* (1- exp(-lambda * xdata));
        ErrorVector = FittedCurve - ydata;
        sse = sum(ErrorVector .^ 2);
    end
end