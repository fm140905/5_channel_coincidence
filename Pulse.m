
% custom data type with fields: time stamp, channel number, pulse index, pulse height
classdef Pulse
    properties
        time
        channel
        index
        pulse_height
    end
    
    methods
        function obj = Pulse(time, channel, index, pulse_height)
            obj.time = time;
            obj.channel = channel;
            obj.index = index;
            obj.pulse_height = pulse_height;
        end
    end
end

