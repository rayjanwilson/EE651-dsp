function P_chirp_fft_conj = range_ref_func(sample_count, meta, flag_print)

% ------------------------------------------------------------------------
% Range reference function
% ------------------------------------------------------------------------

Tp = meta.Tp;
alpha = meta.alpha;
f_rs = meta.f_rs;


time = -Tp/2:1/f_rs:Tp/2;         % time 
p_chirp_signal=exp(j*pi*alpha.*time.^2); % radar chirp signal

P_chirp_fft = fft(p_chirp_signal, sample_count);
P_chirp_fft_conj = conj(P_chirp_fft);

%matched_filter = zeros(1, sample_count);
%matched_filter(1:length(P_chirp_fft_conj)) = P_chirp_fft_conj;

if flag_print == 1
    figure(1), plot(abs(P_chirp_fft))
end

end