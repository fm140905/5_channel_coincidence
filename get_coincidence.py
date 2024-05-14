import h5py


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
    # read data from h5 files
    # each file contains a 2D array with two columns: timestamp (ns) and pulse height (V)
    timestamp_pulseheights = []
    for i in range(5):
        with h5py.File(f"input/timestamp_pulseheight_CH{i}.h5", "r") as f:
            tmp = f["timestamp_pulseheight"][:]
            # print shape
            print(f"{tmp.shape[0]} pulses are found in CH{i}")
            timestamp_pulseheights.append(tmp)

    # sort the events by timestamp
    events = []
    for i in range(5):
        for j in range(timestamp_pulseheights[i].shape[0]):
            events.append(Pulse(timestamp_pulseheights[i][j, 0], i, j, timestamp_pulseheights[i][j, 1]))
    events.sort()

    # Find the coincidence
    TIME_WINDOW = 500 # ns
    PH_THRESHOLD = 0.05 # V
    coincidences = get_coincidence(events)
    print(len(coincidences))
    # # save the coincidences in a csv file
    # with open("output/coincidences.csv", "w") as f:
    #     f.write("t0,t1,t2,t3,t4 (unit:ps)\n")
    #     for coincidence in coincidences:
    #         f.write(",".join([f"{int(pulse.time*1000)}" for pulse in coincidence]))
    #         f.write("\n")
    # print(f"Done! {len(coincidences)} coincidences are found.")
