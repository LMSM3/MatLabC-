% signal_processing.m
% Signal processing and filtering demonstration
%
% Run with: mlab++ signal_processing.m --visual

disp('MatLabC++ Signal Processing Demo');
disp('=================================');
disp('');

% ========== GENERATE TEST SIGNAL ==========
disp('1. Generating Test Signal');
disp('-------------------------');

fs = 1000;  % Sampling frequency (Hz)
t = 0:1/fs:1;  % Time vector (1 second)

% Composite signal: 50 Hz + 120 Hz + noise
f1 = 50;
f2 = 120;
signal = sin(2*pi*f1*t) + 0.5*sin(2*pi*f2*t) + 0.2*randn(size(t));

fprintf('Sample rate: %d Hz\n', fs);
fprintf('Duration: %.1f s\n', t(end));
fprintf('Samples: %d\n', length(signal));
disp('');

% ========== FFT ANALYSIS ==========
disp('2. FFT Analysis');
disp('---------------');

n = length(signal);
f = (0:n-1)*(fs/n);
X = fft(signal);
power = abs(X).^2/n;

% Find peaks
[pks, locs] = findpeaks(power(1:floor(n/2)), 'MinPeakHeight', max(power)/10);
freq_peaks = f(locs);

fprintf('Detected frequencies:\n');
for i = 1:length(freq_peaks)
    fprintf('  %.1f Hz (power: %.2e)\n', freq_peaks(i), pks(i));
end
disp('');

% ========== FILTERING ==========
disp('3. Low-pass Filtering');
disp('---------------------');

% Design Butterworth filter
order = 4;
cutoff = 80;  % Hz
[b, a] = butter(order, cutoff/(fs/2), 'low');

% Apply filter
filtered = filter(b, a, signal);

% Calculate SNR improvement
noise_power_before = var(signal - sin(2*pi*f1*t));
noise_power_after = var(filtered - sin(2*pi*f1*t));
snr_improvement = 10*log10(noise_power_before / noise_power_after);

fprintf('Filter order: %d\n', order);
fprintf('Cutoff frequency: %d Hz\n', cutoff);
fprintf('SNR improvement: %.1f dB\n', snr_improvement);
disp('');

% ========== WINDOWING ==========
disp('4. Windowing Functions');
disp('----------------------');

window_types = {'hamming', 'hann', 'blackman'};
for i = 1:length(window_types)
    win_type = window_types{i};
    
    switch win_type
        case 'hamming'
            w = hamming(length(signal));
        case 'hann'
            w = hann(length(signal));
        case 'blackman'
            w = blackman(length(signal));
    end
    
    windowed = signal .* w';
    X_win = fft(windowed);
    
    fprintf('%s window - Energy: %.2e\n', win_type, sum(abs(X_win).^2));
end
disp('');

% ========== CORRELATION ==========
disp('5. Auto-correlation');
disp('-------------------');

[acf, lags] = xcorr(signal, 100, 'coeff');
[max_acf, max_lag_idx] = max(acf(lags > 0));
period_samples = lags(max_lag_idx + 101);  % Offset for zero lag
period_hz = fs / period_samples;

fprintf('Dominant period: %d samples\n', period_samples);
fprintf('Corresponds to: %.1f Hz\n', period_hz);
disp('');

% ========== SPECTROGRAM ==========
disp('6. Short-Time Fourier Transform');
disp('--------------------------------');

window_size = 128;
overlap = 64;
[S, F, T] = spectrogram(signal, window_size, overlap, [], fs);

fprintf('Window size: %d samples\n', window_size);
fprintf('Overlap: %d samples\n', overlap);
fprintf('Time resolution: %.3f s\n', T(2) - T(1));
fprintf('Frequency resolution: %.2f Hz\n', F(2) - F(1));
disp('');

disp('Demo complete! Signal processing features:');
disp('  ✓ FFT analysis');
disp('  ✓ Digital filtering');
disp('  ✓ Windowing functions');
disp('  ✓ Correlation analysis');
disp('  ✓ Time-frequency analysis (STFT)');
