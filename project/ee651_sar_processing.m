% ee651_sar_processing.m

% This program loads the data and satellite parameters into the workspace
% Then calls the different compression routines.

clear all; close all; clc;

meta = R1_sensor_params();

meta.flag_print = 0;

% ------------------------------------------------------------------------
% image parameters
% ------------------------------------------------------------------------
%line_count = 22151;                 % number of rows (azimuth)
%sample_count = 6354;                % number of columns (range)

%set smaller for testing
meta.line_count = 2048;                 % number of rows (azimuth)
meta.sample_count = 2048;                % number of columns (range)
% ------------------------------------------------------------------------

load HHcomplex_new.mat;
L0_image = HHcomplex_new(1:meta.line_count, 1:meta.sample_count);
clear HHcomplex_new;



range_match_filt = range_ref_func(meta);
Range_Compressed_Image = range_compression(L0_image, range_match_filt, meta);
azimuth_match_filt = az_ref_func(meta);