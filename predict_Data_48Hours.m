function predict_Data_48Hours
    global NO_INSTANCES TOTAL_DAYS START_DATE END_DATE CLUB_DAYS MIN_REQ_LEN DAYS4CV FDBK_DELAYS  ...
        HIDDEN_LAYERS READ_FILE ANALYSE_DATA FMT RESULTS_DIR DATA_DIR INTERPOLATE_DATA ...
        MAX_ITERATION ERR_LIMIT SAMPLES APPLY_K_MEANS_RULE USE_DUAL_NARNET TOTAL_DAYS_FOR_PRED_TRAINING...
        TOTAL_DAYS_PREDICTED APPLY_RULE_ON_PRED_OP IS_AREA_SITE_CLUBBED;
    warning('off');
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Global Variables Settings
    NO_INSTANCES = 2;    FDBK_DELAYS = 15;     HIDDEN_LAYERS = [35 15 7];
    INTERPOLATE_DATA = 0;      SAMPLES = 10;     FMT = 'dd-mm-yyyy';
    ERR_LIMIT = 0.1;     MAX_ITERATION = 20;    USE_DUAL_NARNET = true;
    APPLY_RULE_ON_PRED_OP = true;       IS_AREA_SITE_CLUBBED = true;
    
    CLUB_DAYS = 2;      READ_FILE = 0;     ANALYSE_DATA = 0;
    APPLY_K_MEANS_RULE = 0;     DAYS4CV = (CLUB_DAYS * NO_INSTANCES) * 0;
    TOTAL_DAYS_FOR_PRED_TRAINING = 100;     TOTAL_DAYS_PREDICTED = (CLUB_DAYS * NO_INSTANCES);
    MIN_REQ_LEN = 4;
    
    endMonth = 10; yearofeval = 2015; 
    lastdateofendMonth = eomday(yearofeval,endMonth);
    lastdateforpredinput = lastdateofendMonth - DAYS4CV;
    END_DATE = datenum(sprintf('%d-%d-%d',lastdateforpredinput,endMonth,yearofeval),FMT);
    startdateforpredinput = END_DATE - TOTAL_DAYS_FOR_PRED_TRAINING + 1;
    START_DATE = startdateforpredinput;
    
    TOTAL_DAYS = (END_DATE - START_DATE + 1)/CLUB_DAYS;

    RESULTS_DIR = [pwd, '\Results\'];
    DATA_DIR = [pwd, '\Data\'];
    if ~exist(RESULTS_DIR,'dir')
        mkdir(RESULTS_DIR);
    end
    if ~exist(DATA_DIR,'dir')
        mkdir(DATA_DIR);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  File Names Settings    
    datePred = END_DATE + 1;
    dVec = datevec(datePred);
    
    datfile = sprintf('predict_%02i%02i%i_len_%02i_IpPred_%d_Club_%d_Instances_%d.dat',...
        dVec(3),dVec(2),dVec(1),MIN_REQ_LEN,TOTAL_DAYS,CLUB_DAYS,NO_INSTANCES);
    xlsinfile = sprintf('predict_%02i%02i%i_len_%02i_IpPred_%d_Club_%d_Instances_%d.xlsx',...
        dVec(3),dVec(2),dVec(1),MIN_REQ_LEN,TOTAL_DAYS,CLUB_DAYS,NO_INSTANCES);
%     xlsoutfile = sprintf('predict_%02i%02i%i_len_%02i_Months_%d_Club_%d_Instances_%d_Analysed.xlsx',...
%         dVec(3),dVec(2),dVec(1),MIN_REQ_LEN,TOTAL_MONTH,CLUB_DAYS,NO_INSTANCES);
    analysed = sprintf('analysed_%02i%02i%i_len_%02i_IpPred_%d_Club_%d_Instances_%d.mat',...
        dVec(3),dVec(2),dVec(1),MIN_REQ_LEN,TOTAL_DAYS,CLUB_DAYS,NO_INSTANCES);
    extractedInputRecord = 'Ericsson_Extracted_Data_IncTitle.mat';
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Main Code
    if ANALYSE_DATA
        if READ_FILE
            hedaersToUse = [{'Service Area 4'},{'Site'},{'RootCause'},{'Creation Date'}];
            hdsz = numel(hedaersToUse);    indx = zeros(1,hdsz); extractedRecords = [];
            
            load([DATA_DIR 'Ericsson_InputFileData_IncTitle.mat']);
            headers = data(1,:);
            for k = 1:hdsz
                indx(k) = findIndx(headers, hedaersToUse{k});
            end
            [extractedRecords, ~] = ...
                makeRecordsFromInputDataFile(extractedRecords, data(:,indx(1)),...
                data(:,indx(3)), data(:,indx(4)), data(:,indx(2)));
                                          
            save([DATA_DIR extractedInputRecord], 'extractedRecords');
        else
            load([DATA_DIR extractedInputRecord]);
        end
        adddaystopredict = false; getActual = false;
        [~, AnalyseData] = ...
            analyseDataByDaysAppearance(extractedRecords, adddaystopredict,getActual);
        
        save([DATA_DIR analysed], 'AnalyseData');
    else
        load([DATA_DIR analysed]);
    end
%     predicted_splitted = predict_byte_bits_Narnet(AnalyseData);    
    instancePredicted = writeTouserDefinedFile(predicted_splitted,datfile, 1,xlsinfile);
    
    daysstr = [];
    adddays = dVec(3);
    for k = 1: NO_INSTANCES
        for l = 1:CLUB_DAYS
            adddays = adddays + (l-1);
            str = sprintf('%02i,',adddays);
            daysstr = [daysstr str];
        end
        adddays = dVec(3) + CLUB_DAYS;
    end
%     daysstr = sprintf('%02i,%02i',dVec(3),dVec(3)+1);
    wlstr1 = sprintf('--------------------------------------------------------------------\n');
    wlstr2 = sprintf('Minimum Unique Instances = %d with last %d Days\n',...
        MIN_REQ_LEN,TOTAL_DAYS_FOR_PRED_TRAINING);
    str1 = sprintf('      Predicted Isntances on (%s)/%02i = %d',daysstr,dVec(2),instancePredicted);

    disp(wlstr1);
    disp(wlstr2);
    disp(str1);
%     applyRule_onPredictionOp(xlsinfile, xlsoutfile);
end

