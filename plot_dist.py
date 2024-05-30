import numpy as np
from matplotlib import pyplot as plt
import h5py


if __name__ == "__main__":
    with h5py.File("test/coincidences.h5", "r") as f:
        pulse_integrals = f["pulse_integrals"][:]
        time_stamps = f["time_stamps"][:]
    time_stamps = time_stamps / 1e3 # ps to ns
    dts_1 = time_stamps[:, 1] - time_stamps[:, 0]
    dts_2 = time_stamps[:, 2] - time_stamps[:, 0]
    dts_3 = time_stamps[:, 3] - time_stamps[:, 0]
    dts_4 = time_stamps[:, 4] - time_stamps[:, 0]
    fig, ax = plt.subplots(1, 2, figsize=(12, 6))
    ax[0].hist(dts_2-dts_1, bins=300, range=(-100, 100))
    ax[1].hist(dts_4-dts_3, bins=300, range=(-100, 100))
    xs = dts_2-dts_1
    ys = dts_4-dts_3
    fig, ax = plt.subplots()
    ax.scatter(xs[:10000], ys[:10000], s=1)
    # ax.set_xlim([0,1])
    # ax.set_ylim([0,1])
    plt.show()
