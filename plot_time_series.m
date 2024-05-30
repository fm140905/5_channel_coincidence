% Main script
coincidence_index = 1;

% Load the data
filename = 'test/coincidences.h5';
coincident_pulses = h5read(filename, '/voltage_pulses');
coincident_pulses = permute(coincident_pulses, [3 2 1]);
time_stamps = h5read(filename, '/time_stamps');
time_stamps = transpose(time_stamps);

% % Plot the data
% figure;
% hold on;
% time_series = create_time_series(squeeze(coincident_pulses(coincidence_index, :, :)), time_stamps(coincidence_index, :));
% for i = 1:5
%     plot(2*(0:(size(time_series, 2)-1)), time_series(i, :), 'DisplayName', sprintf('Channel %d', i-1));
% end
% xlabel('Time (ns)');
% ylabel('Voltage (V)');
% legend;
% hold off;

% Loop through the first 20 coincidences and plot the data
for coincidence_index = 1:20
    % Create the time series
    time_series = create_time_series(squeeze(coincident_pulses(coincidence_index, :, :)), time_stamps(coincidence_index, :));
    
    % Plot the data
    figure;
    hold on;
    for i = 1:5
        plot(2*(0:(size(time_series, 2)-1)), time_series(i, :), 'DisplayName', sprintf('Channel %d', i-1));
    end
    xlabel('Time (ns)');
    ylabel('Voltage (V)');
    legend;
    hold off;
end

function time_series = create_time_series(pulses, time_stamps)
    % start_time = min(time_stamps);
    % disp(strcat('First trigger at: ', string(start_time), ' ps'));
    % disp(strcat('Triggering time of 5 channels with repspect to the first trigger: ', num2str((time_stamps - start_time)), ' ps'));
    % shift_samples = floor((time_stamps - start_time) / 2000); % 2000 ps is the sampling step
    % time_series_length = max(shift_samples) + size(pulses, 2);

    % time_series = zeros(size(pulses, 1), time_series_length);
    % for i = 1:size(pulses, 1)
    %     time_series(i, 1:shift_samples(i)) = pulses(i, 1);
    %     time_series(i, shift_samples(i)+1:shift_samples(i)+size(pulses, 2)) = pulses(i, :);
    %     time_series(i, shift_samples(i)+size(pulses, 2)+1:end) = pulses(i, end);
    % end
    time_series = pulses;
end
