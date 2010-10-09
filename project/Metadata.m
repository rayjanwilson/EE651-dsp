classdef Metadata
    % Information from the metadata files we'll need for processing
    properties
        line_count      % number of lines in the image (rows)
        sample_count    % number of range samples in the image (columns)
        flag_print=0      % make plots of intermediate steps. defaults to no
        wc              % carrier frequency [Hz]
        w0              % chirp bandwidth [Hz]
        Tp              % chirp pulse duration [s]
        alpha           % chirp rate [Hz/s]
        prf             % pulse repetition frequency [Hz]
        f_rs            % range sampling frequency
        v               % platform velocity [m/s]
        lambda          % carrier freq wavelength
        r0              % Range to the center of the image [m]
        ta              % Apertur time [s]
    end
end