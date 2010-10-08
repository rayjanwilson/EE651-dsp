
% this program focuses a piece of a real ERS-1 SAR image. The processor
% does the full fledged range focusing but simplyfies azimuth compression a
% bit. In particular, the following approximations are made:
%   - the variation of the azimuth reference function across range is
%     neglected. Instead, only a single constant azimuth reference function
%     is used, corresponding to the reference function of mid-range. By
%     choosing mid-range, the errors that are introduced within the image
%     are minimized. As you will see, for ERS-1 like acquisition geometries
%     this assumption is not horribly critical if you analyze your data
%     only visually. For geometries as used in airborne systems, this
%     approximation would degrade the image significanlty.
%   - In a second approximation we are neglecting Range Cell Migration
%     Correction. This is ok for this dataset as RCM is limited to only a
%     few pixels (about 4) in ERS-1 data and does not visually degrade the
%     image. If you look closer into the data (e.g. by analyzing a point
%     target response) you would see some degradation (check figure 6).


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

clear i tau

%--------------------------------------------------------------------------
% Derivation of the azimuth reference function ( Azimuth Chirp ) 
% for both a stationary scene and a moving target
%--------------------------------------------------------------------------
az=zeros(1,2048);
az_motion=zeros(1,2048);

vlos = 2.5; %range velocity of a moving target [m/s]

tau=-ta/2:1/prf:ta/2;
az_chirp=exp(i.*pi.*fm.*tau.^2);
az_chirp_motion=exp(i.*pi.*fm.*tau.^2).* exp(-i.*2*pi.*tau.*2*vlos./lambda);
step=ta*prf;
az(2048-floor(step):2048)=az_chirp;
az = fliplr(az);
az_motion(2048-floor(step):2048)=az_chirp_motion;
az_motion = fliplr(az_motion);
fourier_az=fft(az);
fourier_az_motion=fft(az_motion);
con_az=conj(fourier_az);
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Creating an additional target that is added to the image. In once case
% this target is stationary, in the other case it is moving
%--------------------------------------------------------------------------
target = zeros(size(processed2));
target_motion = zeros(size(processed2));
defocused_az = zeros(size(processed2));
defocused_az_motion = zeros(size(processed2));
target(1300,400) = 1000;
window = zeros(1,2048)
window2 = hamming(2*round(step) + 1);
window(1300-round(step) : 2048)=window2(1:1757);
window(1:260) = window2(1758:length(window2));
target_motion(1300,400) = 1000;
[a,b]=size(processed2);
for kk=1:b
    vec=target(:,kk);
    vec_motion=target_motion(:,kk);
    f_vec=fft(vec);
    f_vec_motion=fft(vec_motion);
    zw=f_vec(:).*fourier_az(:);
    zw_motion=f_vec_motion(:).*fourier_az_motion(:);
    if_vec=ifft(zw);
    if_vec_motion=ifft(zw_motion);
    if kk == 400
        figure;plot(abs(fftshift(zw,1)))
        figure;plot(abs(fftshift(zw.*fftshift(window)',1)))
    end
    defocused_az(:,kk)=if_vec;
    defocused_az_motion(:,kk)=if_vec_motion;
end
defocused_az = fftshift(defocused_az,1);
defocused_az_motion = fftshift(defocused_az_motion,1);

processed2_stationary = processed2 + defocused_az;
processed2_motion = processed2 + defocused_az_motion;
figure;imagesc(real(processed2_motion'));colormap('gray')
title('Range Compressed ERS SAR image with moving object (real part-note cosine modulation)','FontSize',12)
ylabel('Range','FontSize',12);xlabel('Azimuth','FontSize',12);
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Azimut compression
%--------------------------------------------------------------------------
processed3=zeros(size(processed2));
processed3_motion=zeros(size(processed2));
[a,b]=size(processed2);
az=zeros(1,2048);
az_motion=zeros(1,2048);
az(1:ceil(step))=az_chirp;
az_motion(1:ceil(step))=az_chirp_motion;
fourier_az=fft(az);
fourier_az_motion=fft(az_motion);
con_az=conj(fourier_az);

for kk=1:b
    vec=processed2_stationary(:,kk);
    vec_motion = processed2_motion(:,kk);
    f_vec=fft(vec);
    f_vec_motion=fft(vec_motion);
    zw=f_vec(:).*con_az(:);
    zw_motion=f_vec_motion(:).*con_az(:);
    if_vec=ifft(zw);
    if_vec_motion=ifft(zw_motion);
    processed3(:,kk)=if_vec;
    processed3_motion(:,kk)=if_vec_motion;
%   if kk == 400
%       figure;plot(real(fftshift(f_vec))./max(real(fftshift(f_vec))));figure;plot(real(fftshift(con_az))./max(real(fftshift(con_az))),'k');
%       figure;plot(real((con_az)))
%       figure;plot(real(fftshift(zw)));hold on; plot(real(fftshift(zw_motion)),'k')
%   end
end
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Filtering and visualizing of the focused image
%--------------------------------------------------------------------------
H = fspecial('gaussian',[5 5],0.7);     % some Gaussian filtering for visual improvement
Y = filter2(H,abs(processed3'));
Y_motion = filter2(H,abs(processed3_motion'));
figure;imagesc(Y);colormap('gray')
title('Compressed ERS SAR image','FontSize',12)
ylabel('Range','FontSize',12);xlabel('Azimuth','FontSize',12);
caxis([0 8000])
figure;imagesc(Y_motion);colormap('gray')
title('Compressed ERS SAR image with Moving Target','FontSize',12)
ylabel('Range','FontSize',12);xlabel('Azimuth','FontSize',12);
caxis([0 8000])
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Multilooking - for further visual improvement and to generate roughly
% square pixels on ground (5 azimuth cells are averaged)
%--------------------------------------------------------------------------
erg=zeros(ceil(a/5),b);
index2=1;
for kk=1:5:a-5
   vec=processed3(kk:kk+4,:);
   vec_motion=processed3_motion(kk:kk+4,:);
   m_vec=mean(abs(vec),1);
   m_vec_motion=mean(abs(vec_motion),1);
   erg(index2,:)=m_vec;
   erg_motion(index2,:)=m_vec_motion;
   index2=index2+1;
end
erg=erg(1:(min(size(erg))-200),:);
erg_motion=erg_motion(1:(min(size(erg_motion))-200),:);
Y = filter2(H,abs(erg'));
Y_motion = filter2(H,abs(erg_motion'));
figure;imagesc(Y);colormap('gray')
title('Multilooked ERS SAR image','FontSize',12)
ylabel('Range','FontSize',12);xlabel('Azimuth','FontSize',12);
caxis([0 8000])
axis equal; axis off
figure;imagesc(Y_motion);colormap('gray')
title('Multilooked ERS SAR image with Moving Target','FontSize',12)
ylabel('Range','FontSize',12);xlabel('Azimuth','FontSize',12);
caxis([0 8000])
axis equal; axis off
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Plotting Impulse response function for a bright point target in the image
%--------------------------------------------------------------------------
test = processed3(192-31:192+29,916);
test2 = resample(test',10,1);
figure;plot([-305:304],10.*log(abs(test2))-max(10.*log(abs(test2))),'k','LineWidth',2);axis([-150 150 -50 0]);grid
%figure;plot([-30:30],10.*log(abs(processed3(192,917-30:917+30)))-max(10.*log(abs(processed3(192,917-30:917+30)))),'k','LineWidth',2);axis([-30 30 -50 0]);grid
title('Impulse Response of bright Point Scatterer (azimuth)','FontSize',12)
ylabel('RCS [dB]','FontSize',12);xlabel('Azimuth Sample','FontSize',12);
h = text(15, -12, 'Note: Asymmetry of lobes'); set(h,'Color',[1 0 0],'FontSize',11)
h = text(42, -15, '& reduced resolution'); set(h,'Color',[1 0 0],'FontSize',11)
h = text(-120, -7, '10x oversampled'); set(h,'Color',[0 0 0],'FontSize',10,'FontWeight','b')
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Point spread function for added moving object.
%--------------------------------------------------------------------------
test = processed3(275-111:275+109,400);
test_motion = processed3_motion(275-111:275+109,400);
test2 = resample(test',10,1);
test2_motion = resample(test_motion',10,1);
figure;plot([-1110:1099],10.*log(abs(test2))-max(10.*log(abs(test2))),'k','LineWidth',2);axis([-1050 1050 -50 0]);grid
hold on; plot([-1110:1099],10.*log(abs(test2_motion))-max(10.*log(abs(test2))),'r','LineWidth',2)
%figure;plot([-30:30],10.*log(abs(processed3(192,917-30:917+30)))-max(10.*log(abs(processed3(192,917-30:917+30)))),'k','LineWidth',2);axis([-30 30 -50 0]);grid
title('Impulse Response of moving target (azimuth)','FontSize',12)
ylabel('RCS [dB]','FontSize',12);xlabel('Azimuth Sample','FontSize',12);
h = text(-900, -12, 'Black: no motion'); set(h,'Color',[0 0 0],'FontSize',11,'FontWeight','b')
h = text(-900, -17, ['Red: movement with ',num2str(vlos),' [m/s]']); set(h,'Color',[1 0 0],'FontSize',11,'FontWeight','b')
h = text(-900, -20, 'shift scales with range velocity'); set(h,'Color',[1 0 0],'FontSize',11)
h = text(-900, -6, '10x oversampled'); set(h,'Color',[0 0 0],'FontSize',10,'FontWeight','b')
%--------------------------------------------------------------------------