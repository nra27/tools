%
%  Packaged up routine to filter data with a given -6db point
%
%  N is the order of the window
%  in (the data) can be a matrix
%
%  f6db is the cutoff frequency in Hz 
%
%  [out] = QuickFILT(in,N,fs,f6db,response)
%
%  Using variable input, if response is 'anything' then you get 
%  the freqz plot on the next figure
%
%  Matrix inputs are ok
%
%  NRA


function [out] = QuickFILT_var(in,varargin)

N = varargin{1};
fs = varargin{2};
f6db = varargin{3};

A = 1;
B = FIR1(N,f6db/(fs/2),blackman(N+1));
out = filtfilt(B, A,in);

if nargin == 5,
    figure
    freqz(B,A,2^14,fs)
else
end