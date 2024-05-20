%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script reads the data from the hdf5 files, finds the coincidences and
% saves the coincident events to a new hdf5 file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change these parameters based on your measured data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
input_dir = 'C:\Users\ming\Downloads\1m_Cf252center_10MAY24_550LSB_CFD_run2\RAW\'; %"test/testdata/"
output_dir = "test/";
H5_file_name_pattern = 'DataR_CH_{channel_number}_@DT5730S_30718_1m_Cf252center_10MAY24_CFD_run2.h5'; %"DataR_CH_{channel_number}_@DT5730S_30718_run4.h5"
TIME_WINDOW = 30 % 500 % ns
PH_THRESHOLD = 0.05 % V
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CoMPASS CSV files are pre-processed and saved as hdf5 files 
% read data from h5 files
time_stamps = cell(1, 5);
pulse_heights = cell(1, 5);
voltage_pulses = cell(1, 5);
for i = 1:5
    filename = strcat(input_dir, strrep(H5_file_name_pattern, '_{channel_number}_', num2str(i-1)));
    disp(['Reading data from ', filename]);
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

disp("Finding coincidences...");
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
        coincident_event_timestamps(i, j) = int64(coincidence{1}(j).time*1000); % ns to ps
        coincident_event_pulse_heights(i, j) = coincidence{1}(j).pulse_height;
        coincident_event_voltage_pulses(i, j, :) = voltage_pulses{coincidence{1}(j).channel+1}(coincidence{1}(j).index, :);
    end
end

% sum the pulses to get the total integral
coincident_event_integrals = sum(coincident_event_voltage_pulses, 3);

coincident_event_timestamps = transpose(coincident_event_timestamps);
coincident_event_pulse_heights =  transpose(coincident_event_pulse_heights);
coincident_event_voltage_pulses =  permute(coincident_event_voltage_pulses, [3 2 1]);
coincident_event_integrals = transpose(coincident_event_integrals);

% Save the data to hdf5 file
fpath_hdf5 = strcat(output_dir, 'coincidences.h5');
disp(strcat("Saving coincidences to ", fpath_hdf5));
if exist(fpath_hdf5, 'file')
    delete(fpath_hdf5);
end
h5create(fpath_hdf5, '/time_stamps', size(coincident_event_timestamps), 'Datatype','int64');
h5create(fpath_hdf5, '/pulse_heights', size(coincident_event_pulse_heights));
h5create(fpath_hdf5, '/voltage_pulses', size(coincident_event_voltage_pulses));
h5create(fpath_hdf5, '/pulse_integrals', size(coincident_event_integrals));
h5write(fpath_hdf5, '/time_stamps', coincident_event_timestamps);
h5write(fpath_hdf5, '/pulse_heights', coincident_event_pulse_heights);
h5write(fpath_hdf5, '/voltage_pulses', coincident_event_voltage_pulses);
h5write(fpath_hdf5, '/pulse_integrals', coincident_event_integrals);

%%% Find the coincidences.
    %%% lst: list of pulses sorted by time
    %%% TIME_WINDOW: time window in ns
    %%% PH_THRESHOLD: pulse height threshold in V
    %%% Return: list of coincidences, each coincidence is a list of 5 pulses
function coincidences = get_coincidence(lst, TIME_WINDOW, PH_THRESHOLD)
    coincidences = {};
    N = length(lst);
    for i = 1:N-1
        if lst(i).channel ~= 0 % trgger channel = 0
            continue;
        end
        t_start = lst(i).time - TIME_WINDOW; % ns
        t_end = lst(i).time + TIME_WINDOW;
        flag = [false, false, false, false, false];
        coincidence = Pulse.empty;
        % get number of pulses within (t_start, t_end)
        j_start = i;
        while j_start >= 1 && lst(j_start).time >= t_start
            j_start = j_start - 1;
        end
        j_end = i;
        while j_end <= N && lst(j_end).time <= t_end
            j_end = j_end + 1;
        end
        for j = j_start+1:j_end-1
            if lst(j).time <= t_start
                continue;
            elseif lst(j).time >= t_end
                break;
            else
                if lst(j).pulse_height > PH_THRESHOLD % reject low-amplitude pulses
                    flag(lst(j).channel + 1) = true;
                    coincidence(end+1) = lst(j);
                end
            end
        end
        % check if the coincidence has 5 pulses and all channels are triggered
        if length(coincidence) == 5 && all(flag)
            % sort by channel
            channel_number = [coincidence.channel];
            [~,sortIdx] = sort(channel_number);
            coincidence = coincidence(sortIdx);
            coincidences{end+1} = coincidence;
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
