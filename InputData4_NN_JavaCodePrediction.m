function InputData4_NN_JavaCodePrediction ()%(dateofip,len)
    global RESULTS_DIR DATA_DIR NO_INSTANCES CLUB_DAYS MIN_REQ_LEN TOTAL_MONTH DAYS4CV...
        TOTAL_DAYS_FOR_PRED_TRAINING TOTAL_DAYS START_DATE END_DATE FMT TOTAL_DAYS_PREDICTED;
    
    NO_INSTANCES = 2;    CLUB_DAYS = 4;   MIN_REQ_LEN = 4;   TOTAL_MONTH = 10; 
    TOTAL_DAYS_FOR_PRED_TRAINING = 200;
    endMonth = 10; %Please change as per the requirement. 
    yearofeval = 2015;
    
    DAYS4CV = (CLUB_DAYS * NO_INSTANCES) * 3;%inst;
    TOTAL_DAYS_PREDICTED = (CLUB_DAYS * NO_INSTANCES);
    FMT = 'dd-mm-yyyy'; 
     
    lastdateofendMonth = eomday(yearofeval,endMonth);
    lastdateforpredinput = lastdateofendMonth - DAYS4CV;
    END_DATE = datenum(sprintf('%d-%d-%d',lastdateforpredinput,endMonth,yearofeval),FMT);
    startdateforpredinput = END_DATE - TOTAL_DAYS_FOR_PRED_TRAINING + 1;
    START_DATE = startdateforpredinput;
    TOTAL_DAYS = (END_DATE - START_DATE + 1)/CLUB_DAYS;
    
    RESULTS_DIR = [pwd, '\Results\'];
    DATA_DIR = [pwd, '\Data\'];
    
    input_dir = [num2str(lastdateforpredinput+1) '102015_len_0' num2str(MIN_REQ_LEN)...
        '_ClubDays_' num2str(CLUB_DAYS) '_TotalMonths_' num2str(TOTAL_MONTH)];
    
    extractedInputRecord = 'Ericsson_Extracted_Data_IncTitle_IncSubRCA.mat';
    load([DATA_DIR extractedInputRecord]); %extractedRecords

    
    iFile = [input_dir '\input.dat'];
    aFile = [input_dir '\actual.dat'];
    hFile = [input_dir '\happened.dat'];
    
    if ~exist([RESULTS_DIR input_dir '\'],'dir')
        mkdir([RESULTS_DIR input_dir '\']);
    end
    if exist([RESULTS_DIR iFile],'file')
        delete([RESULTS_DIR iFile]);
    end
    if exist([RESULTS_DIR aFile],'file')
        delete([RESULTS_DIR aFile]);
    end
    if exist([RESULTS_DIR hFile],'file')
        delete([RESULTS_DIR hFile]);
    end

    adddaystopredict = true; getActual = false;
    [AnalyseData, AnalyseData_Splitted] = ...
        analyseDataByDaysAppearance(extractedRecords, adddaystopredict,getActual);

%     lastdateforpredinput = lastdateofendMonth - DAYS4CV + TOTAL_DAYS_PREDICTED;
%     END_DATE = datenum(sprintf('%d-%d-%d',lastdateforpredinput,endMonth,yearofeval),FMT);
%     startdateforpredinput = END_DATE - (TOTAL_DAYS_FOR_PRED_TRAINING + TOTAL_DAYS_PREDICTED) + 1;
%     START_DATE = startdateforpredinput;
%     TOTAL_DAYS = (END_DATE - START_DATE + 1)/CLUB_DAYS;
    
%     adddaystopredict = true; getActual = false;
%     [~, AnalyseData] = ...
%         analyseDataByDaysAppearance(extractedRecords, adddaystopredict,getActual);
    
    adddaystopredict = true; getActual = true;
    [AnalyseData_Actual, ~] = analyseDataByDaysAppearance(extractedRecords, adddaystopredict,getActual);
    
    keysz = numel(AnalyseData_Splitted.Info);
    total = 0;   
    for k = 1:keysz
        siteInfo = AnalyseData_Splitted.Info(k).site;
        siteName = siteInfo.name;
        rcaInfo = siteInfo.rca;
        rcaSz = numel(rcaInfo);
        for j = 1:rcaSz
            total = total +1;
            str = sprintf('%s, %s',siteName,rcaInfo(j).name);
            PredictedInstances{total,1} = str;
            PredictedInstances{total,2} = (siteInfo.bitStream(j,:));
        end
    end
    writetoTextFile(PredictedInstances,iFile);
    
    keysz = numel(AnalyseData.Info);
    total = 0;   
    for k = 1:keysz
        siteInfo = AnalyseData.Info(k).site;
        siteName = siteInfo.name;
        rcaInfo = siteInfo.rca;
        rcaSz = numel(rcaInfo);
        for j = 1:rcaSz
            total = total +1;
            str = sprintf('%s, %s',siteName,rcaInfo(j).name);
            HappenedInstances{total,1} = str;
            HappenedInstances{total,2} = (siteInfo.bitStream(j,:));
        end
    end
    writetoTextFile(HappenedInstances,hFile);
    
    keysz = numel(AnalyseData_Actual.Info);
    total = 0;   
    for k = 1:keysz
        siteInfo = AnalyseData_Actual.Info(k).site;
        siteName = siteInfo.name;
        rcaInfo = siteInfo.rca;
        rcaSz = numel(rcaInfo);
        for j = 1:rcaSz
            total = total +1;
            str = sprintf('%s, %s',siteName,rcaInfo(j).name);
            ActualInstances{total,1} = str;
            ActualInstances{total,2} = (siteInfo.bitStream(j,:));
        end
    end
    writetoTextFile(ActualInstances,aFile);    
end