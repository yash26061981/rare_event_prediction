function [newInstances, deletedInstance] = deleteDuplicateInstances(rcaInstances)
    global FMT
    rcaSz = max(size(rcaInstances));
    datearray = zeros(1,rcaSz);
    for j = 1: rcaSz
        datestring = sprintf('%d-%d-%d',rcaInstances(j).date,rcaInstances(j).month,rcaInstances(j).year);
        t = datenum(datestring,FMT);
        datearray(j) = t;
    end 
    u = unique(datearray);
%     hist = histc(datearray,u);
%     duplicate = u(hist>1);
%     duplicateIndx = find(datearray == u(hist>1));
    deletedInstance = length(datearray) - length(u);
%     for j = 1:length(duplicate)
%         indx = find(datearray == duplicate(j));
%         for k = 2:length(indx)
%             rcaInstances(indx(k)) = [];
%         end
%     end
    newInstances = repmat(struct('date', 0, 'month', 0, 'year', 0),1,length(u));
    for j = 1:length(u)
        t = u(j);
        newdate = datevec(datestr(t),FMT);
        newInstances(j).year = newdate(1);
        newInstances(j).month = newdate(2);
        newInstances(j).date = newdate(3);
    end
end
