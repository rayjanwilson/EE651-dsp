function Az_Img = az_compression2(RC_image, az_match_filter, meta);

Az_Img = zeros(size(RC_image)); % Initialize the compressed image
size(az_match_filter)
for k=1:meta.sample_count
    az_sample = RC_image(:,k);
    fft_az_sample = fft(az_sample, meta.line_count);
    zw = fft_az_sample(:).*az_match_filter(:);
    zw(1) = zw(2);
    az_compressed = ifft(zw);
    Az_Img(:,k) = az_compressed(:);
    
    if k == 10
        sprintf('%f+j%f ', real(fft_az_sample(1:10)), imag(fft_az_sample(1:10)))
        figure(7), plot(abs(zw), '.'), title('Az(f) = H(f)X(f)')
        size(zw)
        zw(1:5)

end
end
