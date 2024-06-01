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


class TSincInterpolator:
    """Interpolate pulse using a terminated sinc function.
    """
    def __init__(self, numInterP:int, tsincWidth:int=6, taperConst:int=30):
        """Initialize the pulse interpolator.

        Args:
            numInterP (int): number of parts a time step is evenly divided into after interpolation
            tsincWidth (int): number of lobes of tsinc function used in interpolation, default to 6
            taperConst (int): tapering constant, default=30
        """
        self.numInterP = numInterP
        self.tsincWidth = tsincWidth
        self.taperConst = taperConst
        self.sincCoefs = np.zeros(tsincWidth * numInterP)
        self._getTSincCoefficients()

    def _getTSincCoefficients(self):
        """Calculate the tsinc function values.
        """
        self.sincCoefs[0] = 1
        for j in range(1, self.tsincWidth * self.numInterP):
            phi = j * np.pi / self.numInterP
            tmp = j / self.taperConst
            tmp = np.sin(phi) / phi * np.exp(-tmp**2)
            self.sincCoefs[j] = tmp

class DIACFD:
    def __init__(self, fraction=0.75, delay=20, num_interp_pts=1):
        self.fraction = fraction
        self.delay = delay
        self.num_interp_pts = num_interp_pts
        self.tsinc = TSincInterpolator(num_interp_pts)
    
    def get_CFD_timing(self, pulse):
        ymax, imax = self._get_interpolated_pulse_max(pulse)
        threshold = self.fraction * ymax
        # # find the first point that is smaller than the threshold
        # for i in range(imax, 0, -1):
        #     if pulse[i] <= threshold:
        #         break
        i = self._binary_search_value_range(pulse, 0, imax, threshold)
        # linear interpolation
        x1 = i
        # x2 = i + 1
        y1 = self._get_interpolated_pulse_at(pulse, i)
        y2 = self._get_interpolated_pulse_at(pulse, i+1)
        x = x1 + (threshold - y1) / (y2 - y1)
        return x/self.num_interp_pts
    
    def _get_interpolated_pulse_max(self, pulse):
        imax = np.argmax(pulse)
        if self.num_interp_pts == 1 or imax == 0 or imax == len(pulse) - 1:
            return pulse[imax], imax
        low = imax - 1 if pulse[imax - 1] > pulse[imax + 1] else imax
        high = imax if pulse[imax - 1] > pulse[imax + 1] else imax+1
        low *= self.num_interp_pts
        high *= self.num_interp_pts
        imax = self._binary_search_argmax(pulse, low, high)
        ymax = self._get_interpolated_pulse_at(pulse, imax)
        return ymax, imax

    def _binary_search_argmax(self, pulse, low, high):
        if low >= high:
            return low
        if high - low == 1:
            return low if self._get_interpolated_pulse_at(pulse, low) > self._get_interpolated_pulse_at(pulse, high) else high
        mid = (low + high) // 2
        left = self._binary_search_argmax(pulse, low, mid-1)
        right = self._binary_search_argmax(pulse, mid+1, high)
        return mid if self._get_interpolated_pulse_at(pulse, mid) > self._get_interpolated_pulse_at(pulse, left) and self._get_interpolated_pulse_at(pulse, mid) > self._get_interpolated_pulse_at(pulse, right) else left if self._get_interpolated_pulse_at(pulse, left) > self._get_interpolated_pulse_at(pulse, right) else right

    def _binary_search_value_range(self, pulse, low, high, value):
        if high - low <= 1:
            return low
        mid = (low + high) // 2
        if self._get_interpolated_pulse_at(pulse, mid) < value:
            return self._binary_search_value_range(pulse, mid, high, value)
        else:
            return self._binary_search_value_range(pulse, low, mid, value)

    def _get_interpolated_pulse_at(self, pulse, i):
        k = i % self.num_interp_pts
        j = i // self.num_interp_pts
        if k == 0:
            return pulse[j]
        tmp = 0
        for l in range(self.tsinc.tsincWidth):
            if j+1+l < len(pulse):
                tmp += pulse[j+1+l] * self.tsinc.sincCoefs[(l+1)*self.num_interp_pts - k]
            if j - l >= 0:
                tmp += pulse[j-l] * self.tsinc.sincCoefs[l * self.num_interp_pts + k]
        return tmp


if __name__ == "__main__":
    numInterp = 8
    cfd = DIACFD(0.75, 20, num_interp_pts=numInterp)

    with h5py.File("test/coincidences.h5", "r") as f:
        coincident_pulses = f["voltage_pulses"][:]
    
    def get_interpolated_pulse(p):
        interPulseLen = (len(p)-1) * numInterp
        interpolatedPulse = np.zeros(interPulseLen)
        for i in range(interPulseLen):
            interpolatedPulse[i] = cfd._get_interpolated_pulse_at(p, i)
        return interpolatedPulse

    # Plot the data
    fig, ax = plt.subplots(2, 3, figsize=(18, 12), sharex=True)
    marker_colors = ['r', 'g', 'b', 'c', 'm', 'y']
    for ch in range(5):
        for i in range(5):
            pulse = coincident_pulses[i, ch, :]
            x = np.arange(len(pulse)) * 4
            interpolated_pulse = get_interpolated_pulse(pulse)
            x_interpolated = np.arange(len(interpolated_pulse)) * 4 / numInterp
            ymax, imax = cfd._get_interpolated_pulse_max(pulse)
            ax[ch//3][ch%3].scatter(x_interpolated, interpolated_pulse, color=marker_colors[i], s=1)
            ax[ch//3][ch%3].scatter(x, pulse, color=marker_colors[i], s=10) #, marker='x')
            # plot the max point
            ax[ch//3][ch%3].scatter(imax*4/numInterp, ymax, color='k', s=10)
        ax[ch//3][ch%3].set_xlabel("Time (ns)")
        ax[ch//3][ch%3].set_ylabel("Voltage (V)")
        ax[ch//3][ch%3].set_title(f"Channel {ch}")
        # ax.legend()
    plt.show()
