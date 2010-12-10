% ee651_sar_processing.m

% This program loads the data and satellite parameters into the workspace
% Then calls the different compression routines.

clear all; close all; clc;

meta = R1_sensor_params();

meta.flag_print = 1;

% ------------------------------------------------------------------------
% image parameters
% ------------------------------------------------------------------------
%meta.line_count = 22151;                 % number of rows (azimuth)
%meta.sample_count = 6354;                % number of columns (range)

%set smaller for testing
meta.line_count = 2048*2;                 % number of rows (azimuth)
meta.sample_count = 2048;                % number of columns (range)
% ------------------------------------------------------------------------

load HHcomplex_new.mat;
L0_image = HHcomplex_new(1:meta.line_count, 1:meta.sample_count);
clear HHcomplex_new;
L0_image(1,1)


range_match_filt = range_ref_func(meta);
Range_Compressed_Image = range_compression(L0_image, range_match_filt, meta);



az_match_filter = az_ref_func(meta);
Azimuth_Compressed_Image = az_compression2(Range_Compressed_Image, az_match_filter, meta);



figure(5), colormap('gray'), imagesc(abs(Azimuth_Compressed_Image)); caxis([0 10000])

H = fspecial('gaussian',[5 5],0.7);
Y = filter2(H,abs(Azimuth_Compressed_Image'));
figure(6), imagesc(Y'), colormap('gray'), caxis([0 10000])

get_Az_Pattern(Range_Compressed_Image, meta);

%antenna_pattern = get_Antenna_Pattern(L0_image);
%ant_pat_corr = -1*(antenna_pattern);

%Fixed_Range_comp_Image = antenna_pattern_correction(Range_Compressed_Image, ant_pat_corr);