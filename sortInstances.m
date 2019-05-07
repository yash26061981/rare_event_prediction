function sortedInstance = sortInstances(rcaInstances)
    global FMT
    if ~isempty(rcaInstances)
        rcaSz = numel(rcaInstances);
        datearray = zeros(1,rcaSz);
        for j = 1: rcaSz
            datestring = sprintf('%d-%d-%d',rcaInstances(j).date,rcaInstances(j).month,rcaInstances(j).year);
            t = datenum(datestring,FMT);
            datearray(j) = t;
        end 
        datearray = unique(datearray);
        dataSort = sort(datearray,'descend');
        rcaSz = numel(dataSort);
        newInstances = repmat(struct('date', 0, 'month', 0, 'year', 0),1,rcaSz);
        for j = 1:rcaSz
            t = dataSort(j);
            newdate = datevec(datestr(t),FMT);
            newInstances(j).year = newdate(1);
            newInstances(j).month = newdate(2);
            newInstances(j).date = newdate(3);
        end
        sortedInstance = newInstances;
    else
        sortedInstance = [];
    end
end
