%
%   Quick and dirty fft that returns the frequency vector in Hz
%
%   call as: [y,f]=QuickFFT(data,fs,n,window)
%
%   window is 1 for 'yes', 0 for 'no'   
%
%   NRA 7th Jan 2004

function [y,f,raw]=QuickFFT(data,fs,n,window)

temp=data/max(data);
if window == 1,
temp = data-mean(data);
temp = temp.*hann(length(temp))';
else
end

raw = fft(data-mean(data),2^n);
%raw = fft(data,2^n);
G=abs(raw);
f = fs*(0:2^(n-1))/(2^n);
y=G(1:2^(n-1)+1);

figure(20)
plot(f,y,'r')
ylabel('Normalised Magnitude')
xlabel('Frequency in Hz')