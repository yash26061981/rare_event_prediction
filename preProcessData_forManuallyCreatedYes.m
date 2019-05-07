function preProcessData_forManuallyCreatedYes()
    currDir = pwd;
    DATA_DIR = [currDir, '\Data\'];

    hd = [{'NOC Ref Id'}, {'Customer'}, {'Title'}, {'Importance'},{'Manually Created'},...
        {'Equipment Type'}, {'Site'}, {'Creation Date'}, {'Closure Date'},...
        {'Assignment Start Date'}, {'Assignment Finish Date'}, {'Assigned FT'},...
        {'Due Date'}, {'Service Area 1'},{'Service Area 2'}, {'Service Area 3'},...
        {'Service Area 4'}, {'Description Log'}, {'DetailedLog'}, {'Solution Report'},...
        {'Probable Cause'},{'NetworkElementName'}, {'PCCategory'}, {'PCSubCategory'},...
        {'FaultTyp'}, {'RootCause'},{'SubRootCause'},{'Equipmentgroup'}];
    pathToRead = 'D:\Prediction_Project\Ericsson_Prediction\InputRawFiles\Punjab_Circle';
    files = dir(pathToRead);
    sz = numel(files);
    data = []; 
    
    hdsz = numel(hd);
    indx = zeros(1,hdsz);
    data = hd; fst = 1;
    if 0
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
                data = [data;datain];

                clear datain alldata hd

            end
        end
        save([DATA_DIR 'Ericsson_InputFileAllDataClubbed_Punjab.mat'], 'data');
    else        
        eqipmentTypeToSearch = [{'CF'},{'Blockage'},{'DIP ERROR'}];
        load([DATA_DIR 'Ericsson_InputFileAllDataClubbed_Punjab.mat']);
        allData = data(2:end,:);
        manuallyCreatedData = allData(:,5);
        manuallyCreatedIndx = cellfun(@(x) all(ismember(x,'No')),manuallyCreatedData);
        allData(~manuallyCreatedIndx,:) = [];

        sitesDataNotManuallyCreated = allData(:,7);
        sitesDataNotManuallyCreated_andNan = cellfun(@(x) all(isnan(x)),sitesDataNotManuallyCreated);
        sitesDataNotManuallyCreated(sitesDataNotManuallyCreated_andNan,:) = [];
        siteDataNotManually = unique(sitesDataNotManuallyCreated);

        allData = data(2:end,:);
        allData(manuallyCreatedIndx,:) = [];
        sitesDataManuallyCreated = allData(:,7);
        sitesDataManuallyCreated_andNan = cellfun(@(x) all(isnan(x)),sitesDataManuallyCreated);
        sitesDataManuallyCreated(sitesDataManuallyCreated_andNan,:) = [];
        siteDataManually = unique(sitesDataManuallyCreated);

        eqpmntType = allData(:,6);
        eqpmntTypeSearchIndxAll = zeros(numel(eqpmntType),numel(eqipmentTypeToSearch));
        for k = 1:numel(eqipmentTypeToSearch)
            eqpmntTypeSearchIndxAll(:,k) = cellfun(@(x) all(ismember(x,eqipmentTypeToSearch{k})),eqpmntType);
            if k > 1
                eqpmntTypeSearchIndx = or(eqpmntTypeSearchIndxAll(:,k-1),eqpmntTypeSearchIndxAll(:,k));
            end
        end
        allData(~eqpmntTypeSearchIndx,:) = [];

        dataToSave = [data(1,:); allData];
        save([DATA_DIR 'Ericsson_InputFileData_EqpmntType_ManuallyCreated_Yes.mat'], 'dataToSave', '-v7.3');
    end
end