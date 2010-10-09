function meta = R1_sensor_params()

% ------------------------------------------------------------------------
% Radarsat Sensor Parameters
% ------------------------------------------------------------------------

meta = Metadata;    %create the metadata object

meta.wc = 5.3e9;                         % carrier frequency [Hz]
meta.w0 = 1.748e7;                       % range chirp bandwidth [Hz]
meta.Tp = 4.2e-5;                        % range chirp pulse duration [s]
meta.alpha = -4.1619e11;                 % fm range chirp rate [Hz/s]
meta.prf = 1295.923;                     % pulse repetition frequency [Hz]
meta.f_rs = 1.84669e7;                   % range sampling frequency
meta.v = 7540.357;                       % platform velocity [m/s]
meta.lambda = 0.05656;                   % carrier freq wavelength

meta.R0 = 842623.10696;                 % slant range to first pixel [m]
meta.f0 = -1.5941557884;                % Azimuth Doppler Centroid
meta.fm = 2*meta.v^2/(meta.lambda*meta.R0);  %azimuth FM rate
meta.Ta = 0.886*meta.lambda*meta.R0/(10*meta.v); %azimuth exposure time
%importfile('RSAT_S1_antenna.gain');
% ------------------------------------------------------------------------
end