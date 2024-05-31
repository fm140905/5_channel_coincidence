%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script reads the CSV files generated by the digitizer and saves the data to hdf5 file.
% The script also plots the pulse height distribution and some voltage pulses.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters. Modify these parameters according to your needs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
input_dir = '/media/ming/Elements/LgModCf252_EXTTRIG_28MAY24/RAW/';
CSV_file_name_pattern = 'DataR_CH_{channel_number}_@DT5730S_30718_LgModCf252_EXTTRIG_28MAY24.CSV';
POLARITY = 1
DC_OFFSET = 0.2
PH_THRESHOLD = 0.05 % V, discard pulses with height less than this value
VMAX = 2.0;

% CFD settings
FRACTION = 0.75;
DELAY = 20; % ns

% downsample the pulses by a factor of 2
DOWNSAMPLE_FACTOR = 2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

NBITS = 14;
LSB_2_VOLT = VMAX / (2^NBITS - 1);
% BASE_LINE = round(DC_OFFSET*(2^NBITS-1));
% if POLARITY == -1
%     BASE_LINE = round((1-DC_OFFSET)*(2^NBITS-1));
% end
N_BASELINE_SAMPLES = 8;

CFD_TIMER = DIACFD(FRACTION, DELAY);

for channel_number = 0:4
    fpath = strcat(input_dir, strrep(CSV_file_name_pattern, '_{channel_number}_', num2str(channel_number)));
    disp(['Reading data from ', fpath]);
    fid = fopen(fpath);
    header = fgetl(fid);
    % disp(header);
    second_line = fgetl(fid);
    sub_strs = strsplit(second_line, ';');
    num_of_samples = length(sub_strs) - 7;

    raw_data = readmatrix(fpath,  'NumHeaderLines',1, "Delimiter",";", "TrimNonNumeric", true);
    disp(['Number of pulses: ', num2str(size(raw_data, 1))]);
    time_stamp = raw_data(:, 3)/1e3; % ps to ns
    disp(['Max time stamp (s): ', num2str(time_stamp(end) / 1e9)]);

    samples = raw_data(:, 8:end);
    % voltagePulses = LSB_2_VOLT * (samples - BASE_LINE) * POLARITY;
    BASE_LINE = mean(samples(:, 1:N_BASELINE_SAMPLES), 2);
    voltagePulses = LSB_2_VOLT * (samples - BASE_LINE) * POLARITY;
    % print size of voltagePulses
    disp(['Size of voltagePulses: ', num2str(size(voltagePulses))]);
    voltagePulses = voltagePulses(:, 1:DOWNSAMPLE_FACTOR:end);
    % print size of voltagePulses
    disp(['Size of voltagePulses after downsampling: ', num2str(size(voltagePulses))]);
    pulseHeights = max(voltagePulses, [], 2);

    for i=1:length(pulseHeights)
        time_stamp(i) = time_stamp(i) + CFD_TIMER.get_CFD_timing(voltagePulses(i, :))*2*DOWNSAMPLE_FACTOR;
    end

    % Plot pulse height distribution
    figure;
    histogram(pulseHeights, 300, 'BinLimits', [0 0.5]);
    xlabel('Pulse height (V)');
    ylabel('Counts');
    title(['CH ', num2str(channel_number), ' pulse height distribution']);
    grid on;

    % Plot some voltage pulses
    indices = find(pulseHeights > PH_THRESHOLD);
    figure;
    for i = 1:min(10, length(indices))
        plot(voltagePulses(indices(end-i+1), :));
        hold on;
    end
    hold off;
    xlabel('Sample number');
    ylabel('Voltage(V)');
    title(['CH ', num2str(channel_number),' pulses']);
    grid on;

    % Save the data to hdf5 file
    fpath_hdf5 = strrep(fpath, '.CSV', '.h5');
    if exist(fpath_hdf5, 'file')
        delete(fpath_hdf5);
    end
    h5create(fpath_hdf5, '/time_stamps', size(time_stamp(indices)));
    h5create(fpath_hdf5, '/pulse_heights', size(pulseHeights(indices)));
    h5create(fpath_hdf5, '/voltage_pulses', size(voltagePulses(indices, :)));
    h5write(fpath_hdf5, '/time_stamps', time_stamp(indices));
    h5write(fpath_hdf5, '/pulse_heights', pulseHeights(indices));
    h5write(fpath_hdf5, '/voltage_pulses', voltagePulses(indices, :));
end