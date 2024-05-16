import h5py
import numpy as np


## custom data type with fields: time stamp, channel number, pulse index, pulse height
class Pulse:
    def __init__(self, time, channel, index, pulse_height):
        self.time = time
        self.channel = channel
        self.index = index
        self.pulse_height = pulse_height

    def __lt__(self, other):
        return self.time < other.time

    def __le__(self, other):
        return self.time <= other.time

    def __eq__(self, other):
        return self.time == other.time

    def __ne__(self, other):
        return self.time != other.time

    def __gt__(self, other):
        return self.time > other.time

    def __ge__(self, other):
        return self.time >= other.time

    def __str__(self):
        return f"({self.time}, {self.channel})"


def get_coincidence(lst):
    '''
    Find the coincidences.
    lst: list of pulses sorted by time
    TIME_WINDOW: time window in ns
    PH_THRESHOLD: pulse height threshold in V
    Return: list of coincidences, each coincidence is a list of 5 pulses
    '''
    coincidences = []
    N = len(lst)
    for i in range(N - 1):
        if lst[i].channel != 0: # trgger channel = 0
            continue
        t_start = lst[i].time - TIME_WINDOW # ns
        t_end = lst[i].time + TIME_WINDOW
        flag = [False, False, False, False, False]
        coincidence = []
        # get number of pulses within (t_start, t_end)
        j_start = i
        while j_start >= 0 and lst[j_start].time >= t_start:
            j_start -= 1
        j_end = i
        while j_end < N and lst[j_end].time <= t_end:
            j_end += 1
        for j in range(j_start, j_end):
            if lst[j].time <= t_start:
                continue
            elif lst[j].time >= t_end:
                break
            else:
                if lst[j].pulse_height > PH_THRESHOLD: # pulse height threshold
                    flag[lst[j].channel] = True
                    coincidence.append(lst[j])
        # check if the coincidence has 5 pulses and all channels are triggered
        if len(coincidence) == 5 and flag[0] and flag[1] and flag[2] and flag[3] and flag[4]:
            # sort by channel
            coincidence.sort(key=lambda x: x.channel)
            coincidences.append(coincidence)
    return coincidences


if __name__ == '__main__':
    ################################################################
    #### Change the following parameters if needed ####
    input_dir = "/media/ming/Elements/1m_Cf252center_10MAY24_550LSB_CFD_run2/RAW/"
    H5_file_name_pattern = "DataR_CH_channel_number_@DT5730S_30718_1m_Cf252center_10MAY24_CFD_run2.h5"
    output_dir = input_dir
    TIME_WINDOW = 30 # ns
    PH_THRESHOLD = 0.05 # V
    ################################################################

    # read data from h5 files
    timestamps = [] # ns
    pulse_heights = [] # V
    voltage_pulses = [] # V
    for i in range(5):
        with h5py.File(input_dir + H5_file_name_pattern.replace("_channel_number_", str(i)), "r") as f:
            tmp = f["time_stamps"][:]
            # print shape
            print(f"{tmp.shape[0]} pulses are found in CH{i}")
            timestamps.append(tmp)
            tmp = f["pulse_heights"][:]
            pulse_heights.append(tmp)
            tmp = f["voltage_pulses"][:]
            voltage_pulses.append(tmp)

    # sort the events by timestamp
    events = []
    for i in range(5):
        for j in range(timestamps[i].shape[0]):
            events.append(Pulse(timestamps[i][j], i, j, pulse_heights[i][j]))
    events.sort()

    # Find the coincidence
    coincidences = get_coincidence(events)
    print(len(coincidences))

    conicident_events_timestamps = []
    coincident_event_pulse_heights = []
    coincident_event_voltage_pulses = []
    for coincidence in coincidences:
        conicident_events_timestamps.append([pulse.time*1000 for pulse in coincidence]) # ns to ps
        coincident_event_pulse_heights.append([pulse.pulse_height for pulse in coincidence])
        coincident_event_voltage_pulses.append([voltage_pulses[pulse.channel][pulse.index] for pulse in coincidence])
    
    # to np array
    conicident_events_timestamps = np.array(conicident_events_timestamps, dtype=int)
    coincident_event_pulse_heights = np.array(coincident_event_pulse_heights)
    coincident_event_voltage_pulses = np.array(coincident_event_voltage_pulses)
    coincident_event_pulse_integrals = np.sum(coincident_event_voltage_pulses, axis=2) # integrate the pulses
    
    # save to h5 file
    with h5py.File(output_dir + "/coincidences.h5", "w") as f:
        f.create_dataset("timestamps", data=conicident_events_timestamps)
        f.create_dataset("pulse_heights", data=coincident_event_pulse_heights)
        f.create_dataset("voltage_pulses", data=coincident_event_voltage_pulses)
        f.create_dataset("pulse_integrals", data=coincident_event_pulse_integrals)

    print("Data saved to coincidences.h5")