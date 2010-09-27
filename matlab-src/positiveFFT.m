function [X,freq]=positiveFFT_zero_padding(x,Fs)

N=4*2^nextpow2(x);
k=0:N-1;     %create a vector from 0 to N-1
T=N/Fs;      %get the frequency interval
freq=k/T;    %create the frequency range
X=fft(x,N)/length(x); % normalize the data
 
%only want the first half of the FFT, since it is redundant
cutOff = ceil(N/2); 
 
%take only the first half of the spectrum
X = X(1:cutOff);
freq = freq(1:cutOff);