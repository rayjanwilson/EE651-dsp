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