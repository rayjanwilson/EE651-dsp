function [X,freq]=centeredFFT(x,Fs,N)
%this is a custom function that helps in plotting the two-sided spectrum
%x is the signal that is to be transformed
%Fs is the sampling rate
%N is the number of points returned in the FFT result
 
%this part of the code generates that frequency axis
if mod(N,2)==0
    k=-N/2:N/2-1; % N even
else
    k=-(N-1)/2:(N-1)/2; % N odd
end
 
T=N/Fs;
freq=k/T; %creates the frequency axis
X=fft(x,N)/length(x); % normalizes the data
X=fftshift(X);%shifts the fft data so that it is centered