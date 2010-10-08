% ------------------------------------------------------------------------
% Radarsat Sensor Parameters
% ------------------------------------------------------------------------
wc = 5.3e9;                         % carrier frequency [Hz]
w0 = 1.748e7;                       % chirp bandwidth [Hz]
Tp = 4.2e-5;                        % chirp pulse duration [s]
alpha = -4.1619e11;                 % chirp rate [Hz/s]
prf = 1295.923;                     % pulse repetition frequency [Hz]
f_rs = 1.84669e7;                   % range sampling frequency
v = 7540.357;                       % platform velocity [m/s]
lambda = 0.05656;            % carrier freq wavelength
importfile('RSAT_S1_antenna.gain');
% ------------------------------------------------------------------------
