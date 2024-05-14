% CoMPASS CSV files are pre-processed and saved as hdf5 files 
% read data from h5 files
% each h5 file contains a 2D array with two columns: timestamp (ns) and pulse height (V)
timestamp_pulseheights = cell(1, 5);
for i = 1:5
    filename = sprintf('input/timestamp_pulseheight_CH%d_10k.h5', i-1);
    info = h5info(filename);
    dataset = info.Datasets(1);
    tmp = h5read(filename, '/timestamp_pulseheight');
    timestamp_pulseheights{i} = transpose(tmp);
    disp(['Number of pulses found in CH', num2str(i-1), ': ', num2str(size(timestamp_pulseheights{i}, 1))]);
end

% sort the events by timestamp
events = Pulse.empty;
for i = 1:5
    for j = 1:size(timestamp_pulseheights{i}, 1)
        events(end+1) = Pulse(timestamp_pulseheights{i}(j, 1), i-1, j, timestamp_pulseheights{i}(j, 2));
    end
end
time_stamps = [events.time];
[~,sortIdx] = sort(time_stamps);
events = events(sortIdx);

% Find the coincidence
% Change these two parameters when necessary
TIME_WINDOW = 500; % ns
PH_THRESHOLD = 0.05; % V
coincidences = get_coincidence(events, TIME_WINDOW, PH_THRESHOLD);
disp(['Number of coincidences found: ', num2str(length(coincidences))]);

% Save coincidences in a CSV file
results = zeros(length(coincidences), 5);
for i = 1:length(coincidences)
    coincidence = coincidences(i);
    for j = 1:5
        results(i, j) = int64(coincidence{1}(j).time*1000);
    end
end
writematrix(results, 'output/coincidences.csv', 'Delimiter',',');
