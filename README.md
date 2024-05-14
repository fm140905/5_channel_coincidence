# Find coincidence between five channels

## Algorithm

Channel 0 is set as the trigger channel. Say there is an event at time t_0 in channel 0. If there are four other events from channel 1-4 (one event per channel) in the time window (t_0-w, t_0+w) and the pulse heights of these four events are all above a certain threshold h, then these five events are selected and saved as a conicidence.

w is set to 500 ns and can be changed by changing the value of parameter `TIME_WINDOW` 
h is set to 0.05 V and can be changed by changing the value of parameter `PH_THRESHOLD`

## Run
Run the main.m file

A CSV file with five columns that saves all the coincidences should be created. Each row is one coincidence. Column i is the pulse timestamp from channel i. Unit: ps

Matlab code is generated from a python script by chatgpt, and it generates the same csv as the python code, but the performance may not be optimized.