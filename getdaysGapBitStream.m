function bitStream = getdaysGapBitStream(rcaInstances,adddaystopredict)
    global TOTAL_DAYS START_DATE END_DATE CLUB_DAYS FMT TOTAL_DAYS_PREDICTED;
    
    len = numel(rcaInstances);
    
    startDate = START_DATE;
    if adddaystopredict
        endDate = END_DATE + TOTAL_DAYS_PREDICTED;
        reqInst = TOTAL_DAYS + (TOTAL_DAYS_PREDICTED/CLUB_DAYS) ;
    else
        endDate = END_DATE;
        reqInst = TOTAL_DAYS;
    end
    
    stream = zeros(1,reqInst);
    rcaInstancesDates = uint32(zeros(1,len));
    for i = 1: len
        str = sprintf('%d-%d-%d',rcaInstances(i).date,rcaInstances(i).month,rcaInstances(i).year);
        rcaInstancesDates(i) = datenum(str,FMT);
    end
    rcaInstancesDates = sort(rcaInstancesDates,'ascend');
    block = startDate:1:endDate;
    [i1,~] = ismember(block,rcaInstancesDates);
    total_len = numel(block)/CLUB_DAYS;
    for k = 1:(total_len - 1)
        sumBlock = sum(i1(((k-1)*CLUB_DAYS + 1) : (k*CLUB_DAYS)));
        if sumBlock > 0
            stream(k) = 1;
        end
    end
    bitStream = stream;
end