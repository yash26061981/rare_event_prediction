function [byte,bits] = getByte_BitStream(len,data,todo)

    bits = zeros(len,1);
    [~,c] = size(data);
    byte = zeros(1,c);
    if todo == 0
        for k = 1:c
            for j = 1:len
                byte(k) = byte(k) + (data(j,k) * 2^(j-1));
            end
        end
    else
        val = data;
        if val > ((2^len)-1)
            val = (2^len)-1;
        end
        for j = 1:len
            bits(j) = rem(val,2);
            fval = double(val)/2;
            if fval < 1
                val = 0;
            else
                val = uint16((double(val)/2)-0.5);
            end
        end
    end
end