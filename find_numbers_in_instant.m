function num = find_numbers_in_instant(instances, findnumber, len, last)
    if strcmp(last, 'end')
        inst_new = instances(end-len+1: end);
    else
        inst_new = instances(1: len);
    end
    if findnumber == 0
        isPresent = find(inst_new(1:end) == 0);
    else
        isPresent = find(inst_new(1:end) > 0);
    end
    num = length(isPresent);        
end