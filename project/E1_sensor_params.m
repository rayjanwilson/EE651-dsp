function meta = E1_sensor_params()

% ------------------------------------------------------------------------
% Radarsat Sensor Parameters
% ------------------------------------------------------------------------

meta = Metadata;    %create the metadata object

meta.wc = 5.3e9;                         % carrier frequency [Hz]
meta.w0 = 1.748e7;                       % chirp bandwidth [Hz]
meta.Tp = 37.12*10^(-6);                        % chirp pulse duration [s]
meta.alpha = 4.18989015*10^(11);                 % chirp rate [Hz/s]
meta.prf = 1679.902;                     % pulse repetition frequency [Hz]
meta.f_rs = 18.962468*10^6;                   % range sampling frequency
meta.v = 7098.0194;                       % platform velocity [m/s]
meta.lambda = 0.05656;            % carrier freq wavelength
meta.r0 = 852358.15;            % Range to the center of the image [m]
meta.ta = 0.6;                  % Apertur time [s]
%importfile('RSAT_S1_antenna.gain');
% ------------------------------------------------------------------------
end