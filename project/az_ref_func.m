function azimuth_match_filter = az_ref_func(meta)
% Create the matched filter for azimuth compression

ta = meta.Ta;
prf = meta.prf;
fm = meta.fm;
f0 = meta.f0;

az=zeros(1,2048);
az_motion=zeros(1,2048);


time=-ta/2:1/prf:ta/2;

az_chirp=exp(-i.*pi.*fm.*time.^2);
%az_chirp = exp(-j*pi*(f0^2)/fm);

step=ta*prf;

%az(meta.line_count-floor(step):meta.line_count)=az_chirp;
%az = fliplr(az);
%az(1:ceil(step))=az_chirp;

%figure(1), plot(real(az_chirp))

%fourier_az=fft(az, meta.line_count);
fourier_az=fft(az_chirp, meta.line_count);
%figure(2), plot(abs(fftshift(fourier_az)));

azimuth_match_filter = conj(fourier_az);

figure(10), plot(abs(fourier_az))
title('az chirp')

end