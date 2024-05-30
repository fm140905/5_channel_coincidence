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


if __name__ == "__main__":
    # Load the data
    with h5py.File("test/coincidences.h5", "r") as f:
        coincident_pulses = f["voltage_pulses"][:]

    for coincidence_index in range(20):
        # Plot the data
        fig, ax = plt.subplots()
        for i in range(5):
            time_series = coincident_pulses[coincidence_index,i, :]
            ax.plot(2*np.arange(len(time_series)), time_series, label=f"Channel {i}")
        ax.set_xlabel("Time (ns)")
        ax.set_ylabel("Voltage (V)")
        ax.legend()
        plt.show()
