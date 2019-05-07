function preProcessData()
    currDir = pwd;
%     RESULTS_DIR = [currDir, '\Results\'];
    DATA_DIR = [currDir, '\Data\'];
%     FILE_DIR = [currDir, '\InputFiles\'];
    pathToRead = 'D:\HDB_Data-2015-12-17\HDB Data';
    files = dir(pathToRead);
    sz = numel(files);
    data = []; 
    includeTitle = 1;
%     h = waitbar(0,'Please wait...');
    hd = [{'NOC Ref Id'}, {'Customer'}, {'Title'}, {'Importance'},{'Manually Created'},...
        {'Equipment Type'}, {'Site'}, {'Creation Date'}, {'Closure Date'},...
        {'Assignment Start Date'}, {'Assignment Finish Date'}, {'Assigned FT'},...
        {'Due Date'}, {'Service Area 1'},{'Service Area 2'}, {'Service Area 3'},...
        {'Service Area 4'}, {'Description Log'}, {'DetailedLog'}, {'Solution Report'},...
        {'Probable Cause'},{'NetworkElementName'}, {'PCCategory'}, {'PCSubCategory'},...
        {'FaultTyp'}, {'RootCause'},{'SubRootCause'},{'Equipmentgroup'}];
    hdsz = numel(hd);
    indx = zeros(1,hdsz);
    data = hd; fst = 1;
%     alldata = [];
    for k = 1:sz
        if ~files(k).isdir
            file = [pathToRead, '\', files(k).name]
            [~, ~ , alldata] = xlsread(file,'HDB-Data');
            datain = [];                 
            for l = 1:hdsz
                if fst
                    indx(l) = findIndx(alldata,hd{l});
                end
                datain = [datain alldata(2:end,indx(l))];
            end
            fst = 0;
            rcaData = alldata(2:end,indx(26));
            manuallyCreatedData = alldata(2:end,indx(5));
            manuallyCreatedIndx = cellfun(@(x) all(ismember(x,'Yes')),manuallyCreatedData);
            rcaDataNANIndx = cellfun(@(x) all(isnan(x)),rcaData);
            if includeTitle
                id2 = find(rcaDataNANIndx > 0);
                id1 = find(manuallyCreatedIndx>0);
                [i1,~] = ismember(id2,id1);
                id2(i1) = [];
                len = numel(id2);
                for l = 1:len
                    if(id2(l)+1) == 20689
                        b = 1;
                    end
                    isN = isnan(alldata{(id2(l)+1),indx(3)});
                    if ~((length(isN) == 1) && isN)
                        title = char(alldata((id2(l)+1),indx(3)));
                        [~, rm] = strtok(title,':');
                        if ~isempty(rm)
                            [rm1, ~] = strtok(rm,':');
                            rcaData{id2(l)} = char(rm1);
                        end
                    end              
                end
                rcaDataNANIndx = cellfun(@(x) all(isnan(x)),rcaData);
                datain(:,26) = rcaData;
            end
            clearDataIndx = or(manuallyCreatedIndx,rcaDataNANIndx);
            datain(clearDataIndx,:) = [];
            data = [data;datain];
%             xlswrite([FILE_DIR files(k).name],datain,1);
            clear datain alldata 
            clear rcaData manuallyCreatedData
            clear manuallyCreatedIndx rcaDataNANIndx clearDataIndx id2 id1 i1
            clear hd
%             data = [data;datain];
        end
%         waitbar(k/sz,h)
    end
%     xlswrite('ericsson_data.xlsx',data,1);
    save([DATA_DIR 'Ericsson_InputFileData_IncTitle.mat'], 'data');
%     delete(h)
%     save([DATA_DIR 'indata.mat'], 'data');
%     inFile1 = 'inputFile.xlsx';
%     xlswrite([RESULTS_DIR inFile1],data,1);
end