function predict_CVData_48Hours%(inst)
    global NO_INSTANCES TOTAL_DAYS START_DATE END_DATE CLUB_DAYS MIN_REQ_LEN DAYS4CV FDBK_DELAYS  ...
        HIDDEN_LAYERS TOTAL_MONTH READ_FILE ANALYSE_DATA FMT RESULTS_DIR DATA_DIR INTERPOLATE_DATA ...
        MAX_ITERATION ERR_LIMIT SAMPLES APPLY_K_MEANS_RULE USE_DUAL_NARNET TOTAL_DAYS_FOR_PRED_TRAINING...
        TOTAL_DAYS_PREDICTED USE_ONLY_BYTE_PRED;
    warning('off');
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Global Variables Settings
    %% To use bit wise prediction or byte wise prediction or combination of both
    USE_ONLY_BYTE_PRED = false;     USE_DUAL_NARNET = true;
    
    %% Narnet global settings
    FDBK_DELAYS = 15;     HIDDEN_LAYERS = [35 15 7];   INTERPOLATE_DATA = 0;      SAMPLES = 10;     
    ERR_LIMIT = 0.1;     MAX_ITERATION = 20;    APPLY_K_MEANS_RULE = 0;     
    
    %% Statistics used for prediction 
    NO_INSTANCES = 2;    CLUB_DAYS = 4;   MIN_REQ_LEN = 4;   TOTAL_MONTH = 10; 
    TOTAL_DAYS_FOR_PRED_TRAINING = 200;

    %% To read from file and process it or use processed one.
    READ_FILE = 1;     ANALYSE_DATA = 1;
    
    %% Computed back days for CV and total days of prediction
    
    endMonth = 10; %Please change as per the requirement. 
    yearofeval = 2015;
    
    DAYS4CV = (CLUB_DAYS * NO_INSTANCES) * 1;%inst;
    TOTAL_DAYS_PREDICTED = (CLUB_DAYS * NO_INSTANCES);
    FMT = 'dd-mm-yyyy'; 
     
    lastdateofendMonth = eomday(yearofeval,endMonth);
    lastdateforpredinput = lastdateofendMonth - DAYS4CV;
    END_DATE = datenum(sprintf('%d-%d-%d',lastdateforpredinput,endMonth,yearofeval),FMT);
    startdateforpredinput = END_DATE - TOTAL_DAYS_FOR_PRED_TRAINING + 1;
    START_DATE = startdateforpredinput;
    TOTAL_DAYS = (END_DATE - START_DATE + 1)/CLUB_DAYS;
    
    %% To check result and data directories.
    RESULTS_DIR = [pwd, '\Results\'];
    DATA_DIR = [pwd, '\Data\'];
    if ~exist(RESULTS_DIR,'dir')
        mkdir(RESULTS_DIR);
    end
    if ~exist(DATA_DIR,'dir')
        mkdir(DATA_DIR);
    end

    %%  File Names Settings    
    datePred = END_DATE + 1;
    dVec = datevec(datePred);
    if USE_ONLY_BYTE_PRED
        datfile = sprintf('byte_predict_%02i%02i%i_len_%02i_Months_%d_Club_%d_Instances_%d.dat',...
                        dVec(3),dVec(2),dVec(1),MIN_REQ_LEN,TOTAL_MONTH,CLUB_DAYS,NO_INSTANCES);
        xlsinfile = sprintf('byte_predict_%02i%02i%i_len_%02i_Months_%d_Club_%d_Instances_%d.xlsx',...
                        dVec(3),dVec(2),dVec(1),MIN_REQ_LEN,TOTAL_MONTH,CLUB_DAYS,NO_INSTANCES);
    elseif USE_DUAL_NARNET
        datfile = sprintf('dual_predict_%02i%02i%i_len_%02i_Months_%d_Club_%d_Instances_%d.dat',...
                        dVec(3),dVec(2),dVec(1),MIN_REQ_LEN,TOTAL_MONTH,CLUB_DAYS,NO_INSTANCES);
        xlsinfile = sprintf('dual_predict_%02i%02i%i_len_%02i_Months_%d_Club_%d_Instances_%d.xlsx',...
                        dVec(3),dVec(2),dVec(1),MIN_REQ_LEN,TOTAL_MONTH,CLUB_DAYS,NO_INSTANCES);
    else
        datfile = sprintf('predict_%02i%02i%i_len_%02i_Months_%d_Club_%d_Instances_%d.dat',...
                        dVec(3),dVec(2),dVec(1),MIN_REQ_LEN,TOTAL_MONTH,CLUB_DAYS,NO_INSTANCES);
        xlsinfile = sprintf('predict_%02i%02i%i_len_%02i_Months_%d_Club_%d_Instances_%d.xlsx',...
                        dVec(3),dVec(2),dVec(1),MIN_REQ_LEN,TOTAL_MONTH,CLUB_DAYS,NO_INSTANCES);
    end
%     xlsoutfile = sprintf('predict_%02i%02i%i_len_%02i_Months_%d_Club_%d_Instances_%d_Analysed.xlsx',...
%         dVec(3),dVec(2),dVec(1),MIN_REQ_LEN,TOTAL_MONTH,CLUB_DAYS,NO_INSTANCES);
    analysed = sprintf('analysed_%02i%02i%i_len_%02i_Months_%d_Club_%d_Instances_%d.mat',...
        dVec(3),dVec(2),dVec(1),MIN_REQ_LEN,TOTAL_MONTH,CLUB_DAYS,NO_INSTANCES);
    analysed_actual = sprintf('analysedActual_%02i%02i%i_len_%02i_Months_%d_Club_%d_Instances_%d.mat',...
        dVec(3),dVec(2),dVec(1),MIN_REQ_LEN,TOTAL_MONTH,CLUB_DAYS,NO_INSTANCES);
    analysed_splitted = sprintf('analysedSplitted_%02i%02i%i_len_%02i_Months_%d_Club_%d_Instances_%d.mat',...
        dVec(3),dVec(2),dVec(1),MIN_REQ_LEN,TOTAL_MONTH,CLUB_DAYS,NO_INSTANCES);
    extractedInputRecord = 'Ericsson_Extracted_Data_IncTitle_IncSubRCA.mat';
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Main Code
    if ANALYSE_DATA
        if READ_FILE
            hedaersToUse = [{'Service Area 4'},{'Site'},{'Creation Date'},{'RootCause'},{'SubRootCause'}];
            hdsz = numel(hedaersToUse);    indx = zeros(1,hdsz); extractedRecords = [];
            
            load([DATA_DIR 'Ericsson_InputFileData_IncTitle.mat']);
            headers = data(1,:);
            for k = 1:hdsz
                indx(k) = findIndx(headers, hedaersToUse{k});
            end
            [extractedRecords, ~] = ...
                makeRecordsFromInputDataFile(extractedRecords, data(:,indx(1)),...
                data(:,indx(2)), data(:,indx(3)), data(:,indx(4)), data(:,indx(5)));
                                          
            save([DATA_DIR extractedInputRecord], 'extractedRecords');
        else
            load([DATA_DIR extractedInputRecord]);
        end
        adddaystopredict = true; getActual = false;
        [AnalyseData, AnalyseData_Splitted] = ...
            analyseDataByDaysAppearance(extractedRecords, adddaystopredict,getActual);

        adddaystopredict = true; getActual = true;
        AnalyseData_Actual = analyseDataByDaysAppearance(extractedRecords, adddaystopredict,getActual);

%         extractedRecords_Splitted = splitforCrossValidation(extractedRecords);
%         adddaystopredict = false; getActual = false;
%         AnalyseData_Splitted = analyseDataByDaysAppearance(extractedRecords, adddaystopredict,getActual);
        
        save([DATA_DIR analysed], 'AnalyseData');
        save([DATA_DIR analysed_actual], 'AnalyseData_Actual');
        save([DATA_DIR analysed_splitted], 'AnalyseData_Splitted');
    else
        load([DATA_DIR analysed]);
        load([DATA_DIR analysed_actual]);
        load([DATA_DIR analysed_splitted]);
    end
   
    predictedHappened = predict_nextBitStream_testing(AnalyseData);
    predictedActual = predict_nextBitStream_testing(AnalyseData_Actual);
    
    predicted_splitted = predict_byte_bits_Narnet(AnalyseData_Splitted);
%     predicted_splitted = predict(AnalyseData_Splitted);
    
    
    [actualInstance, instanceHappened,instancePredicted,instanceMatched] = ...
        findMatched_inPredictedBitStream(predictedActual, predictedHappened, predicted_splitted,xlsinfile, 1);
    writeTouserDefinedFile(predicted_splitted,datfile, 1);
    
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

    wlstr1 = sprintf('--------------------------------------------------------------------\n');
    wlstr2 = sprintf('Minimum Unique Instances = %d, Days for CV %d days and for last %d Days\n',...
        MIN_REQ_LEN, DAYS4CV, TOTAL_DAYS_FOR_PRED_TRAINING);
    str1 = sprintf(' All   Isntances happened on (%s)/%02i = %d',daysstr,dVec(2),actualInstance);
    str2 = sprintf('       Isntances happened on (%s)/%02i = %d',daysstr,dVec(2),instanceHappened);
    str3 = sprintf('      Predicted Isntances on (%s)/%02i = %d',daysstr,dVec(2),instancePredicted);
    str4 = sprintf('        Matched Isntances on (%s)/%02i = %d',daysstr,dVec(2),instanceMatched);
    str5 = sprintf('\n        Recall  = %2.2f%%',(instanceMatched/instanceHappened)*100);
    str6 = sprintf('     Precision  = %2.2f%%\n\n',(instanceMatched/instancePredicted)*100);

    disp(wlstr1);
    disp(wlstr2);
    disp(str1);
    disp(str2);
    disp(str3);
    disp(str4);
    disp(str5);
    disp(str6);
%     applyRule_onPredictionOp(xlsinfile, xlsoutfile);
end

