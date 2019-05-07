function [newInstances, isEmpty] = removeInstancesAfterDate(rcaInstances)
    global END_DATE DAYS4CV FMT;
    
    toremove = END_DATE - DAYS4CV;
    rcaSz = numel(rcaInstances);
    indx = 1;
    for j = 1: rcaSz
        datestring = sprintf('%d-%d-%d',rcaInstances(j).date,rcaInstances(j).month,rcaInstances(j).year);
        t = datenum(datestring,FMT);
        if t <= toremove
            newInstances(indx) = rcaInstances(j);
            indx = indx + 1;
        end
    end
    if indx > 1
        isEmpty = 0;
    else
        isEmpty = 1;
        newInstances = [];
    end
end