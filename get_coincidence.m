%%% Find the coincidences.
    %%% lst: list of pulses sorted by time
    %%% TIME_WINDOW: time window in ns
    %%% PH_THRESHOLD: pulse height threshold in V
    %%% Return: list of coincidences, each coincidence is a list of 5 pulses
function coincidences = get_coincidence(lst, TIME_WINDOW, PH_THRESHOLD)
    coincidences = {};
    N = length(lst);
    for i = 1:N-1
        if lst(i).channel ~= 0 % trgger channel = 0
            continue;
        end
        t_start = lst(i).time - TIME_WINDOW; % ns
        t_end = lst(i).time + TIME_WINDOW;
        flag = [false, false, false, false, false];
        coincidence = Pulse.empty;
        % get number of pulses within (t_start, t_end)
        j_start = i;
        while j_start >= 1 && lst(j_start).time >= t_start
            j_start = j_start - 1;
        end
        j_end = i;
        while j_end <= N && lst(j_end).time <= t_end
            j_end = j_end + 1;
        end
        for j = j_start+1:j_end-1
            if lst(j).time <= t_start
                continue;
            elseif lst(j).time >= t_end
                break;
            else
                if lst(j).pulse_height > PH_THRESHOLD % reject low-amplitude pulses
                    flag(lst(j).channel + 1) = true;
                    coincidence(end+1) = lst(j);
                end
            end
        end
        % check if the coincidence has 5 pulses and all channels are triggered
        if length(coincidence) == 5 && all(flag)
            % sort by channel
            channel_number = [coincidence.channel];
            [~,sortIdx] = sort(channel_number);
            coincidence = coincidence(sortIdx);
            coincidences{end+1} = coincidence;
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
