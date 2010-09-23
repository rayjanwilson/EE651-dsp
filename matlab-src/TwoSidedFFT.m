function [x ds fft,freq] = TwoSidedFFT(x,fs)
% [x ds fft,freq] = TwoSidedFFT(x,fs) Generates complex two-sided
% Fourier transform (x ds fft) of signal x. Plots the magnitude and
% phase of x ds fft as a function of frequency.
%
% x = discrete time signal
% fs = sampling frequency
% x ds fft = complex two-sided Fourier transform
% freq = vector giving the frequency axis (Hz)
%
% freq vector has the same length as x. It is assumed that fs is
% large enough to avoid aliasing.

n = length(x); % length of input vector (signal)
x_fft = fft(x); % fft of signal x
x_ds_fft = fftshift(x fft); % produce two-sided fft with dc term in the middle

df = fs/(n-1); % frequency step
freq = (-fs/2):df:(fs/2); % frequency axis vector of same length as x

magnitude = abs(x ds fft);
% magnitude of Fourier transform
phase = angle(x ds fft)*180/pi;% phase in degrees of Fourier transform


subplot(2,1,1); plot(freq,magnitude);
ylabel(’|X(f)|’); grid on;
subplot(2,1,2); plot(freq,phase);ylabel(’Phase(X(f))’);
xlabel(’Frequency (Hz)’); grid on;
