# Find coincidence between five channels

## Algorithm

Channel 0 is set as the trigger channel. Say there is an event at time `t_0` in channel 0. If there are four other events from channel 1-4 (one event per channel) in the time window (`t_0-w`, `t_0+w`) and the pulse heights of these four events are all above a certain threshold `h`, then these five events are selected and saved as a conicidence.

`w` is set to 500 ns and can be changed by changing the value of parameter `TIME_WINDOW`

`h` is set to 0.05 V and can be changed by changing the value of parameter `PH_THRESHOLD`

Pulse height = max of all samples in the pulse
Pulse integral = sum of all samples in the pulse

## Test

In `CSV2hdf5.m`, set up the input parameters as
```matlab
input_dir = 'test/testdata/'
CSV_file_name_pattern = 'DataR_CH_{channel_number}_@DT5730S_30718_run4.CSV'
POLARITY = -1
DC_OFFSET = 0.2
PH_THRESHOLD = 0.05 % V, discard pulses with height less than this value
VMAX = 2.0;
```

In `main.m`, set the input parameters as
```matlab
input_dir = 'test/testdata/'
output_dir = 'test/'
H5_file_name_pattern = 'DataR_CH_{channel_number}_@DT5730S_30718_run4.h5'
TIME_WINDOW = 500 % ns. width of coincidence window / 2
PH_THRESHOLD = 0.05 % V. minimum pulse height for the pulse to be accepted
```

Run `CSV2hdf5.m` to process the CSV in `test/testdata` and save HDF5 files.

Run the `main.m` file to extract the coincidences.

1240 coincidences are expected to be found for this test dataset.

A HDF5 file named `coincidences.h5` that saves all the coincidences should be created under `test`. This file contains four datasets:
- `time_stamps`: A `N x 5` matrix. `N` is the number of coincidences. Each row is one coincidence. Column i is the pulse timestamp from channel i. Unit: ps
- `pulse_heights`: A `N x 5` matrix. Each row is one coincidence. Column i is the pulse height from channel i. Unit: V
- `voltage_pulses`: A `N x 5 x N_s` matrix. `N` is the number of coincidences, and `N_s` is the number of samples in one pulse. Unit: V
- `pulse_integrals`: A `N x 5` matrix. Each row is one coincidence. Column i is the integral of the whole pulse from channel i, i.e., pulse integral = sum of all samples in the pulse. Unit: V*ns/dt

The HDF5 file can be viewed using [HDF View](https://www.hdfgroup.org/downloads/hdfview/) software.

## Run
Change the parameters in `CSV2hdf5.m` according to your measurement and run.

Change the parameters in `main.m` according to your measurement and run.

A HDF5 file with four datasets that saves all the coincidences should be created.

Matlab code is generated from a python script by chatgpt.