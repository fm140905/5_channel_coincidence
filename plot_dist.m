% Load the data from the HDF5 file
filename = 'test/coincidences.h5';
pulse_integrals = h5read(filename, '/pulse_integrals');
time_stamps = h5read(filename, '/time_stamps');

% Convert time stamps from ps to ns
time_stamps = time_stamps / 1e3; % ps to ns

% Calculate time differences
dts_1 = time_stamps(:, 2) - time_stamps(:, 1);
dts_2 = time_stamps(:, 3) - time_stamps(:, 1);
dts_3 = time_stamps(:, 4) - time_stamps(:, 1);
dts_4 = time_stamps(:, 5) - time_stamps(:, 1);

% Create histograms
figure;
subplot(1, 2, 1);
histogram(dts_2 - dts_1, 300, 'BinLimits', [-100, 100]);
xlabel('dts_2 - dts_1 (ns)');
ylabel('Count');

subplot(1, 2, 2);
histogram(dts_4 - dts_3, 300, 'BinLimits', [-100, 100]);
xlabel('dts_4 - dts_3 (ns)');
ylabel('Count');

% Scatter plot
xs = dts_2 - dts_1;
ys = dts_4 - dts_3;

figure;
scatter(xs(1:10000), ys(1:10000), 1, 'filled');
xlabel('dts_2 - dts_1 (ns)');
ylabel('dts_4 - dts_3 (ns)');
title('Scatter plot of time differences');
grid on;
