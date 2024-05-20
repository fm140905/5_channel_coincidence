'''
Description: 
Author: Ming Fang
Date: 2024-05-20 15:12:02
LastEditors: Ming Fang
LastEditTime: 2024-05-20 15:27:27
'''
import h5py
from matplotlib import pyplot as plt
import numpy as np


def create_time_series(pulses, time_stamps):
    start_time = np.min(time_stamps)
    shift_samples = ((time_stamps - start_time)/2000).astype(int)
    time_series_length = np.max(shift_samples) + len(pulses[1])
    # print(shift_samples)
    # print(time_series_length)
    time_series = np.zeros((pulses.shape[0], time_series_length))
    for i in range(len(pulses)):
        time_series[i, :shift_samples[i]] = pulses[i, 0]
        time_series[i, shift_samples[i]:shift_samples[i]+len(pulses[i])] = pulses[i]
        time_series[i, shift_samples[i]+len(pulses[i]):] = pulses[i][-1]
    return time_series



if __name__ == "__main__":
    coincidence_index = 1
    # Load the data
    with h5py.File("test/coincidences.h5", "r") as f:
        coincident_pulses = f["voltage_pulses"][:]
        time_stamps = f["time_stamps"][:]

    # Plot the data
    fig, ax = plt.subplots()
    time_series = create_time_series(coincident_pulses[coincidence_index], time_stamps[coincidence_index])
    for i in range(5):
        ax.plot(2*np.arange(time_series.shape[1]), time_series[i], label=f"Channel {i}")
    ax.set_xlabel("Time (ns)")
    ax.set_ylabel("Voltage (V)")
    ax.legend()
    plt.show()
