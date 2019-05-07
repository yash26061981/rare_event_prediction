function next1 = computeFourier(monthdiff)
    global NO_INSTANCES;
    instance = NO_INSTANCES;
    
    diff = monthdiff;
    for i = 1:instance
        Y = fft(diff);
        L = length(diff);
        Yinv = ifft(Y,L+1);
        next1(i) = uint16(abs(Yinv(L+1)));
        diff = [diff, next1(i)];
    end
end