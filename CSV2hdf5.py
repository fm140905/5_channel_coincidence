import numpy as np
from matplotlib import pyplot as plt
import h5py


if __name__ == '__main__':
    ################################################################
    #### Change the following parameters if needed ####
    input_dir = "/media/ming/Elements/1m_Cf252center_10MAY24_550LSB_CFD_run2/RAW/"
    CSV_file_name_pattern = "DataR_CH_channel_number_@DT5730S_30718_1m_Cf252center_10MAY24_CFD_run2.CSV"
    PH_THRESHOLD = 0.05 # V, discard pulses with height less than this value
    POLARITY = 1
    DC_OFFSET = 0.2
    VMAX = 2.0 # V
    ################################################################

    NBITS = 14
    LSB_2_VOLT = VMAX / (2**NBITS - 1)
    N_BASELINE_SAMPLES = 8
    # BASE_LINE = int(DC_OFFSET*(2**NBITS-1))
    # if POLARITY == -1:
    #     BASE_LINE = int((1-DC_OFFSET)*(2**NBITS-1))
        

    for channel_number in range(5):
        fpath = input_dir + CSV_file_name_pattern.replace("_channel_number_", str(channel_number))
        with open(fpath) as f:
            header = f.readline().strip()
            print(header)
            second_line = f.readline().strip()
            sub_strs = second_line.split(";")
            num_of_samples = len(sub_strs) - 7

        use_columns = np.arange(7, num_of_samples+7)
        # insert 2 to the beginning of the use_columns
        use_columns = np.insert(use_columns, 0, 2)
        # read the whole file
        raw_data = np.loadtxt(fpath, skiprows=1, usecols=use_columns, delimiter=";") #, max_rows=10001)
        print("Number of pulses: ", raw_data.shape[0])
        time_stamp = raw_data[:, 0]/1e3 # ps to ns
        print("Max time stamp (s): ", time_stamp[-1]/1e9)

        samples = raw_data[:,1:]
        # BASE_LINE = np.mean(samples, axis=1)
        # baseline is the average of the first 8 samples
        BASE_LINE = np.mean(samples[:, :N_BASELINE_SAMPLES], axis=1)
        voltagePulses = LSB_2_VOLT * (samples - BASE_LINE[:, np.newaxis]) * POLARITY
        pulseHeights = np.max(voltagePulses, axis=1)

        fig, ax = plt.subplots(1, 1, figsize=(6, 6))
        ax.hist(pulseHeights, bins=300, range=(0, 0.5))
        ax.set_xlabel('Pulse height (V)')
        ax.set_ylabel('Counts')
        ax.set_title("Pulse height distribution")
        plt.show()

        indices = np.where(pulseHeights > PH_THRESHOLD)[0]
        fig, ax = plt.subplots(1, 1, figsize=(6, 6))
        for i in range(10):
            ax.plot(voltagePulses[indices[-i]])
        ax.set_xlabel('Sample number')
        ax.set_ylabel('Voltage(V)')
        ax.grid(True)
        # ax.legend()
        plt.show()
        
        # Save the data to hdf5 file
        fpath_hdf5 = fpath.replace(".CSV", ".h5")
        with h5py.File(fpath_hdf5, 'w') as f:
            f.create_dataset('time_stamps', data=time_stamp[indices])
            f.create_dataset('pulse_heights', data=pulseHeights[indices])
            f.create_dataset('voltage_pulses', data=voltagePulses[indices])
