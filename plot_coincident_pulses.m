%% plot 5 pulses in a coincidence

% Define the index of the coincidence that you want to plot
coincidence_index = 1;

% Load the data
filename = 'test/coincidences.h5';
info = h5info(filename);
dataset_name = '/voltage_pulses';
coincident_pulses = h5read(filename, dataset_name);
% matlab uses column-major layout by default
coincident_pulses = permute(coincident_pulses, [3 2 1]);

% Plot the data
figure;
hold on;
for i = 1:5
    plot(squeeze(coincident_pulses(coincidence_index, i, :)), 'DisplayName', sprintf('Channel %d', i-1));
end
xlabel('Time (ns) / 2');
ylabel('Voltage (V)');
legend;
hold off;