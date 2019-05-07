function newCity = findUnique_renameWrong
    fileToRead = 'cityList.xlsx';
    pathToAdd = 'D:\TCTS_Data\';
    file = [pathToAdd, fileToRead];
    [~, ~ , alldata] = xlsread(file);
    
    datai = unique(alldata(:));
    datac = char(alldata{:});
%     d = strnearest(alldata{1},datai{1});
    for k = 1:length(alldata)
        for m = 1:length(datai)
            d(m) = strdist(alldata{k},datai{m});
        end
        [ds,ids] = sort(d);
%         alldata{k} = 
    end
    
    
    
end