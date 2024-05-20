'''
Description: 
Author: Ming Fang
Date: 2024-05-20 14:48:33
LastEditors: Ming Fang
LastEditTime: 2024-05-20 14:50:17
'''
import h5py
from matplotlib import pyplot as plt

if __name__ == "__main__":
    coincidence_index = 1
    # Load the data
    with h5py.File("test/coincidences.h5", "r") as f:
        coincident_pulses = f["voltage_pulses"][:]

    # Plot the data
    fig, ax = plt.subplots()
    for i in range(5):
        ax.plot(coincident_pulses[coincidence_index, i, :], label=f"Channel {i}")
    ax.set_xlabel("Time (ns) / 2")
    ax.set_ylabel("Voltage (V)")
    ax.legend()
    plt.show()
