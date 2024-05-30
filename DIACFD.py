'''
Description: cfd timing
Author: Ming Fang
Date: 2022-04-20 17:07:21
LastEditors: Ming Fang
LastEditTime: 2022-04-20 17:22:38
'''
import numpy as np
from pathlib import Path
import matplotlib.pylab as plt
import h5py


class DIACFD:
    def __init__(self, fraction=0.75, delay=20):
        self.fraction = fraction
        self.delay = delay
    
    def get_CFD_timing(self, pulse):
        imax = np.argmax(pulse)
        threshold = self.fraction * pulse[imax]
        # find the first point that is smaller than the threshold
        for i in range(imax, 0, -1):
            if pulse[i] <= threshold:
                break
        # linear interpolation
        x1 = i
        # x2 = i + 1
        y1 = pulse[i]
        y2 = pulse[i + 1]
        x = x1 + (threshold - y1) / (y2 - y1)
        return x
    

# CFD settings
FRACTION = 0.75
DELAY = 20 # ns
CFD_TIMER = DIACFD(FRACTION, DELAY)



if __name__ == "__main__":
    cfd = DIACFD(0.75, 20)
    def shift_interpolated_pulse(x, pulse, shift):
        xp = np.arange(len(pulse))
        x_new = xp - shift
        pulse_new = np.interp(x, x_new, pulse)
        return pulse_new

    with h5py.File("test/coincidences.h5", "r") as f:
        coincident_pulses = f["voltage_pulses"][:]

    # Plot the data
    fig, ax = plt.subplots(2, 3, figsize=(18, 12), sharex=True)
    x = np.linspace(0, len(coincident_pulses[0, 0, :]), len(coincident_pulses[0, 0, :]), endpoint=False)
    for ch in range(5):
        for i in range(10):
            pulse = coincident_pulses[i, ch, :]
            t = cfd.get_CFD_timing(pulse)
            shifted_pulse = shift_interpolated_pulse(x, pulse, 0)
            # ax[ch//3][ch%3].step(x, shifted_pulse/np.max(pulse)) #, label=f"Channel {i}")
            ax[ch//3][ch%3].step(x, pulse/np.max(pulse))
        ax[ch//3][ch%3].set_xlabel("Time (ns) / 2")
        ax[ch//3][ch%3].set_ylabel("Voltage (V)")
        ax[ch//3][ch%3].set_title(f"Channel {ch}")
        # ax.legend()
    plt.show()
