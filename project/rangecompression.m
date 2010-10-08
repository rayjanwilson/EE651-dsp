clear all; close all; clc;

% ------------------------------------------------------------------------
% image parameters
% ------------------------------------------------------------------------
%line_count = 22151;                 % number of rows (azimuth)
%sample_count = 6354;                % number of columns (range)
line_count = 2048;                 % number of rows (azimuth)
sample_count = 2048;                % number of columns (range)
% ------------------------------------------------------------------------

load HHcomplex_new.mat;
L0_image = HHcomplex_new(1:line_count, 1:sample_count);
clear HHcomplex_new;
load 'R1_sensor_params.mat'



% ------------------------------------------------------------------------
% Range reference function
% ------------------------------------------------------------------------
time = -Tp/2:1/f_rs:Tp/2;         % time 
%p_chirp = zeros(1,sample_count);
p_chirp_signal=exp(j*pi*alpha.*time.^2); % radar chirp signal
%p_chirp(1:length(time)) = p_chirp_signal;

P_chirp_fft = fft(p_chirp_signal, sample_count);
P_chirp_fft_conj = conj(P_chirp_fft);
matched_filter = zeros(1, sample_count);
matched_filter(1:length(P_chirp_fft_conj)) = P_chirp_fft_conj;
figure(1), plot(abs(P_chirp_fft))

% ------------------------------------------------------------------------
% Range compression
% ------------------------------------------------------------------------
Range_Compressed_Image = zeros(size(L0_image));
for line = 1:line_count
    row = L0_image(line,:);
    Row_fft = fft(row);
    Row_fft_filtered = Row_fft.*matched_filter;
    row_filtered = ifft(Row_fft_filtered);
    Range_Compressed_Image(line,:) = row_filtered;
end

figure(2),imagesc(real(Range_Compressed_Image)); colormap('gray');
title('Range Compressed Radarsat SAR image (real)');
ylabel('Azimuth')

figure(3), imagesc(abs(Range_Compressed_Image)); colormap('gray');
title('Range Compressed Radarsat SAR image (abs)');
ylabel('Azimuth')

% ------------------------------------------------------------------------
% Azimuth compression
% ------------------------------------------------------------------------
r=8.5093e5;                % Range to the center of the image [m]
%fm=-2*v^2/(lambda*r)       % FM Rate Azimuth Chirp
ta=0.64;                     % Aperture time [s]
fm = 2095        
step=ta*prf;

az=zeros(1,length(Range_Compressed_Image));
az_time = -ta/2:1/prf:ta/2;
az_chirp=exp(j.*pi.*fm.*az_time.^2);
figure(5), plot(az_time, real(az_chirp))
title('az chirp')

az(2048-floor(step):2048)=az_chirp;
az=fliplr(az);
fourier_az=fft(az);
figure(6), plot(abs(fourier_az))
title('first az fft')
con_az=conj(fourier_az);

azimuth_comp_image = zeros(size(Range_Compressed_Image));
[a,b]=size(azimuth_comp_image);
az=zeros(1,b);

az(1:ceil(step))=az_chirp;
fourier_az=fft(az);
figure(7), plot(abs(fourier_az))
title('second az fft')
con_az=conj(fourier_az);

for kk=1:b
    vec=Range_Compressed_Image(:,kk);    
    f_vec=fft(vec);    
    zw=f_vec(:).*con_az(:);  
    if_vec=ifft(zw);    
    azimuth_comp_image(:,kk)=if_vec;
end

%--------------------------------------------------------------------------
% Filtering and visualizing of the focused image
%--------------------------------------------------------------------------
H = fspecial('gaussian',[5 5],0.7);     % some Gaussian filtering for visual improvement
Y = filter2(H,abs(azimuth_comp_image));

caxis('auto')
figure(4), imagesc(abs(azimuth_comp_image));colormap('gray');
%figure(4);imagesc(Y);colormap('gray')
title('Compressed Radarsat SAR image','FontSize',12)
ylabel('Azimuth','FontSize',12);xlabel('Range','FontSize',12);
%caxis([0 8000])
%--------------------------------------------------------------------------