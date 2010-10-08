function meta = R1_sensor_params()

% ------------------------------------------------------------------------
% Radarsat Sensor Parameters
% ------------------------------------------------------------------------

meta = Metadata;    %create the metadata object

meta.wc = 5.3e9;                         % carrier frequency [Hz]
meta.w0 = 1.748e7;                       % chirp bandwidth [Hz]
meta.Tp = 4.2e-5;                        % chirp pulse duration [s]
meta.alpha = -4.1619e11;                 % chirp rate [Hz/s]
meta.prf = 1295.923;                     % pulse repetition frequency [Hz]
meta.f_rs = 1.84669e7;                   % range sampling frequency
meta.v = 7540.357;                       % platform velocity [m/s]
meta.lambda = 0.05656;            % carrier freq wavelength
%importfile('RSAT_S1_antenna.gain');
% ------------------------------------------------------------------------
end