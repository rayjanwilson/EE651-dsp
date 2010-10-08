% ee651_sar_processing.m

% This program loads the data and satellite parameters into the workspace
% Then calls the different compression routines.

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

flag_print = 0;

range_match_filt = range_ref_func(Tp, alpha, sample_count, flag_print);

Range_Compressed_Image = range_compression(L0_image, range_match_filt, flag_print);