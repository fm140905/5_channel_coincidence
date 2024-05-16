%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script reads the data from the hdf5 files, finds the coincidences and
% saves the coincident events to a new hdf5 file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change these parameters when necessary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
input_dir = "test/testdata/"
output_dir = "test/"
H5_file_name_pattern = "DataR_CH_channel_number_@DT5730S_30718_run4.h5"
TIME_WINDOW = 500 % ns
PH_THRESHOLD = 0.05 % V
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CoMPASS CSV files are pre-processed and saved as hdf5 files 
% read data from h5 files
time_stamps = cell(1, 5);
pulse_heights = cell(1, 5);
voltage_pulses = cell(1, 5);
for i = 1:5
    filename = strcat(input_dir, strrep(H5_file_name_pattern, '_channel_number_', num2str(i-1)));
    info = h5info(filename);
    dataset = info.Datasets(1);
    tmp = h5read(filename, '/time_stamps');
    time_stamps{i} = tmp;
    disp(['Number of pulses found in CH', num2str(i-1), ': ', num2str(size(time_stamps{i}, 1))]);
    
    tmp = h5read(filename, '/pulse_heights');
    pulse_heights{i} = tmp;

    tmp = h5read(filename, '/voltage_pulses');
    voltage_pulses{i} = tmp;
end

% sort the events by timestamp
events = Pulse.empty;
for i = 1:5
    for j = 1:size(time_stamps{i})
        events(end+1) = Pulse(time_stamps{i}(j), i-1, j, pulse_heights{i}(j));
    end
end
time_stamps = [events.time];
[~,sortIdx] = sort(time_stamps);
events = events(sortIdx);

% Find the coincidence
coincidences = get_coincidence(events, TIME_WINDOW, PH_THRESHOLD);
disp(['Number of coincidences found: ', num2str(length(coincidences))]);

% Extract the data from coincidences
coincident_event_timestamps = zeros(length(coincidences), 5, 'int64');
coincident_event_pulse_heights = zeros(length(coincidences), 5);
coincident_event_voltage_pulses = zeros(length(coincidences), 5, size(voltage_pulses{1}, 2));
for i = 1:length(coincidences)
    coincidence = coincidences(i);
    for j = 1:5
        coincident_event_timestamps(i, j) = int64(coincidence{1}(j).time*1000);
        coincident_event_pulse_heights(i, j) = coincidence{1}(j).pulse_height;
        coincident_event_voltage_pulses(i, j, :) = voltage_pulses{coincidence{1}(j).channel+1}(coincidence{1}(j).index, :);
    end
end

% sum the pulses to get the total integral
coincident_event_integrals = sum(coincident_event_voltage_pulses, 3);

% Save the data to hdf5 file
fpath_hdf5 = strcat(output_dir, 'coincidences.h5');
if exist(fpath_hdf5, 'file')
    delete(fpath_hdf5);
end
h5create(fpath_hdf5, '/time_stamps', size(coincident_event_timestamps));
h5create(fpath_hdf5, '/pulse_heights', size(coincident_event_pulse_heights));
h5create(fpath_hdf5, '/voltage_pulses', size(coincident_event_voltage_pulses));
h5create(fpath_hdf5, '/pulse_integrals', size(coincident_event_integrals));
h5write(fpath_hdf5, '/time_stamps', coincident_event_timestamps);
h5write(fpath_hdf5, '/pulse_heights', coincident_event_pulse_heights);
h5write(fpath_hdf5, '/voltage_pulses', coincident_event_voltage_pulses);
h5write(fpath_hdf5, '/pulse_integrals', coincident_event_integrals);


