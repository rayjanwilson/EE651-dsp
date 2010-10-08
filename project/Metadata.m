classdef Metadata
    % Information from the metadata files we'll need for processing
    properties
        wc              % carrier frequency [Hz]
        w0              % chirp bandwidth [Hz]
        Tp              % chirp pulse duration [s]
        alpha           % chirp rate [Hz/s]
        prf             % pulse repetition frequency [Hz]
        f_rs            % range sampling frequency
        v               % platform velocity [m/s]
        lambda          % carrier freq wavelength
    end
end