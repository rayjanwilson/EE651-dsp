function Range_Compressed_Image = range_compression(L0_image, matched_filter, meta)

% ------------------------------------------------------------------------
% Range compression
% ------------------------------------------------------------------------

Range_Compressed_Image = zeros(size(L0_image));
for line = 1:meta.line_count
    row = L0_image(line,:);
    Row_fft = fft(row);
    Row_fft_filtered = Row_fft.*matched_filter;
    row_filtered = ifft(Row_fft_filtered);
    Range_Compressed_Image(line,:) = row_filtered;
end

if meta.flag_print == 1
    figure(2),imagesc(real(Range_Compressed_Image)); colormap('gray');
    title('Range Compressed Radarsat SAR image (real)');
    ylabel('Azimuth')
    
    figure(3), imagesc(abs(Range_Compressed_Image)); colormap('gray');
    title('Range Compressed Radarsat SAR image (abs)');
    ylabel('Azimuth')
end

end

