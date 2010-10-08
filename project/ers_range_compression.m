clear all;close all
load raw;
%raw = raw_new_1;

% -------------------------------------------------------------------------
% Sensor Parameters
% -------------------------------------------------------------------------
fs=18.962468*10^6;          % Sampling Frequency
range=zeros(1,2048);        
k=(4.18989015*10^(11));     % FM Rate Range Chirp  
tau_p=37.12*10^(-6);        % Chirp length [s]
v=7098.0194;                % satellite velocity along the orbit [m/s]
lambda=0.05656;             % Carrier frequency (here C-band)
r=852358.15;                % Range to the center of the image [m]
fm=-2*v^2/(lambda*r);       % FM Rate Azimuth Chirp
ta=0.6;                     % Apertur time [s]   
prf=1679.902;               % Pulse Repitition Frequency [Hz]
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Calculation of the range reference function (Range Chirp)
%--------------------------------------------------------------------------
tau=-tau_p/2:1/fs:tau_p/2;
range_chirp = exp(i.*pi.*(4.18989015*10^(11)).*tau.^2);
range(1:704)=range_chirp;
fourier_chirp=fft(range);
con_chirp=conj(fourier_chirp);
processed=zeros(size(raw));
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Range compression (here done line by line - you could do a 2-D FFT
% instead
%--------------------------------------------------------------------------
for i = 1:2048
    vec = raw(i,:);
    f_vec = fft(vec);
    zw = f_vec.*con_chirp;
    if_vec = ifft(zw);
    processed(i,:) = if_vec;
end
%--------------------------------------------------------------------------

processed2=processed(:,1:2048-703);

figure;imagesc(real(raw'));colormap('gray')
title('Raw ERS SAR image (real part)','FontSize',12)
ylabel('Range','FontSize',12);xlabel('Azimuth','FontSize',12);
% here I plot the real part of the image showing the real part of the
% azimuth chirp, which shows you the cosine modulation

figure;imagesc(real(processed2'));colormap('gray')
title('Range Compressed ERS SAR image (real part-note cosine modulation)','FontSize',12)
ylabel('Range','FontSize',12);xlabel('Azimuth','FontSize',12);
% here I plot the real part of the range compressed image showing the real part of the
% azimuth chirp, which shows you the cosine modulation

figure;imagesc(abs(processed2'));colormap('gray')
title('Range Compressed ERS SAR image (abs-represents abs of antenna pattern','FontSize',12)
ylabel('Range','FontSize',12);xlabel('Azimuth','FontSize',12);