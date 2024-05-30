classdef DIACFD
    properties
        Fraction
        Delay
    end
    
    methods
        function obj = DIACFD(fraction, delay)
            if nargin == 0
                fraction = 0.75;
                delay = 20;
            end
            obj.Fraction = fraction;
            obj.Delay = delay;
        end
        
        function x = get_CFD_timing(obj, pulse)
            [~, imax] = max(pulse);
            threshold = obj.Fraction * pulse(imax);
            % find the first point that is smaller than the threshold
            for i = imax:-1:1
                if pulse(i) <= threshold
                    break;
                end
            end
            % linear interpolation
            x1 = i;
            y1 = pulse(i);
            y2 = pulse(i + 1);
            x = x1 + (threshold - y1) / (y2 - y1);
        end
    end
end