function clubInst = get_clubbed_one_zeros(instances, findclub)
    if findclub
        isPresent = find(instances(1 : end) > 0);
    else
        isPresent = find(instances(1 : end) == 0);
    end
    l = 1; count = 1;
    for k = 1:(length(isPresent)-1)
        if (isPresent(k)+1) == isPresent(k+1)
            count = count +1;
        else
            clubInst(l) = count;
            l = l+1;
            count = 1;
        end
    end 
    clubInst(l) = count;
end