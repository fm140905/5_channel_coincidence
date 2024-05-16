# Find coincidence between five channels

## Algorithm

Channel 0 is set as the trigger channel. Say there is an event at time `t_0` in channel 0. If there are four other events from channel 1-4 (one event per channel) in the time window (`t_0-w`, `t_0+w`) and the pulse heights of these four events are all above a certain threshold h, then these five events are selected and saved as a conicidence.

`w` is set to 500 ns and can be changed by changing the value of parameter `TIME_WINDOW` 
`h` is set to 0.05 V and can be changed by changing the value of parameter `PH_THRESHOLD`

## Test
Run `CSV2hdf5.m` to process the CSV in `test/testdata` and save HDF5 files.

Run the `main.m` file to extract the coincidences.

1240 coincidences are expected to be found.

A HDF5 file with five datasets that saves all the coincidences should be created. These datasets are:
- `time_stamps`: Each row is one coincidence. Column i is the pulse timestamp from channel i. Unit: ps
- `pulse_heights`: Each row is one coincidence. Column i is the pulse height from channel i. Unit: V
- `voltage_pulses`: Each row is one coincidence. Column i is the pulse from channel i. Unit: V
- `pulse_integrals`: Each row is one coincidence. Column i is the integral of the whole pulse from channel i. Unit: V*ns/dt

The HDF5 file can be viewed using [HDF View](https://www.hdfgroup.org/downloads/hdfview/) software.

## Run
Change the parameters in `CSV2hdf5.m` according to your measurement and run.

Change the parameters in `main.m` according to your measurement and run.

A HDF5 file with five datasets that saves all the coincidences should be created.

Matlab code is generated from a python script by chatgpt, and it generates the same csv as the python code, but the performance may not be optimized.