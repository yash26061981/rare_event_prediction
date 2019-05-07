function analyse_rules_faultwise_StatisticalAnalysis(inFile1)
    global RESULTS_DIR USE_JAVA_RESULT %MIN_REQ_LEN TOTAL_MONTH
%     MIN_REQ_LEN = 8;  TOTAL_MONTH = 3;
%     minlen = MIN_REQ_LEN; months = TOTAL_MONTH;

    tests = {'BRADLEY_RUN_TEST', 'REGULARITY_INDEX_TEST'};
    runtest = 2;
    
    warning('off');
    analysed_files = 1;
    inFile = {inFile1};
    if analysed_files == 1
        if USE_JAVA_RESULT
            filetowrite = [inFile{1}(9:16) '_analysed_Java.xlsx'];
        else
            filetowrite = [inFile{1}(9:16) '_analysed.xlsx'];
        end
    else
        filetowrite = '_analysed.xlsx';
    end
    if exist([RESULTS_DIR filetowrite],'file')
        delete([RESULTS_DIR filetowrite]);
    end
    pData = cell(1,analysed_files); 
    faultType = cell(1,analysed_files);
    
    if runtest == 1
        predMatchedData = [{'Site,RCA'},{'Matched'},{'Rules_Op'},{'BitStream'},{'RunTest_Result'},...
            {'Ones_Stats_Mean'}, {'Ones_Stats_Std'},...
            {'Zeros_Stats_Mean'}, {'Zeros_Stats_Std'}];
    else
        predMatchedData = [{'Site,RCA'},{'Matched'},{'Rules_Op'},{'BitStream'},{'RegularityIndx'},...
            {'RunStats'},{'RunUniformity'},{'Ones_Stats_Mean'}, {'Ones_Stats_Std'},...
            {'Zeros_Stats_Mean'}, {'Zeros_Stats_Std'}];
    end
    
    
%     combpredMatchedData = [{'Month'},{'Site,RCA'},{'Matched'},{'Rules_Op'},{'BitStream'}];
    for k = 1:analysed_files
        sheettoread = ['predicted_' inFile{k}(9:16)];
        [~,~,pData{k}] = xlsread([RESULTS_DIR inFile{k}],sheettoread);
        
        sz = numel(pData{k}(2:end,1));
        faultType{k} = repmat(struct('RCA','rca','Matched',struct('kept',0,'removed',0),...
            'Not_Matched',struct('kept',0,'removed',0),'count',1),sz,1);
        indx = 1;
        for l = 1:sz
            val = char(pData{k}(l+1,1));
            sepVal = textscan(val,'%s','Delimiter',',');
            rca = char(sepVal{1}(2));
            findx = findIndxbyField(faultType{k}(1:indx), 'RCA', rca);
            if ~findx
                findx = indx;
                faultType{k}(findx).RCA = rca;
                indx = indx +1;
            else
                faultType{k}(findx).count = faultType{k}(findx).count + 1;
            end

            if strcmp(pData{k}(l+1,2),'Matched')
                if strcmp(pData{k}(l+1,3),'kept')
                    faultType{k}(findx).Matched.kept = faultType{k}(findx).Matched.kept +1;
                else
                    faultType{k}(findx).Matched.removed = faultType{k}(findx).Matched.removed +1;
                end
            else
                if strcmp(pData{k}(l+1,3),'kept')
                    faultType{k}(findx).Not_Matched.kept = faultType{k}(findx).Not_Matched.kept +1;
                else
                    faultType{k}(findx).Not_Matched.removed = faultType{k}(findx).Not_Matched.removed +1;
                end
            end
            if ~strcmp(pData{k}(l+1,2),'Matched')
                str = '';
            else
                str = 'Matched';
            end
            [result,meanStats,stdStats] = run_test_to_check_randomness(char(pData{k}(l+1,4)), tests{runtest});
            if runtest == 1
                if result % i.e true, i.e. reject H0:  the sequence was produced in a random manner
                    str1 = 'Non-Random';
                else
                    str1 = 'Random';
                end
                pos_str_mean = sprintf('%f',meanStats(1));
                pos_str_std = sprintf('%f',stdStats(1));
                neg_str_mean = sprintf('%f',meanStats(2));
                neg_str_std = sprintf('%f',stdStats(2));
                predMatchedData = [predMatchedData;{char(pData{k}(l+1,1))},{str},...
                    {char(pData{k}(l+1,3))},{char(pData{k}(l+1,4))},...
                    {str1},{pos_str_mean},{pos_str_std},{neg_str_mean},{neg_str_std}];
            else
                str1 = sprintf('%f',result(1));
                str2 = sprintf('%f',result(2));
                str3 = sprintf('%f',result(3));
                pos_str_mean = sprintf('%f',meanStats(1));
                pos_str_std = sprintf('%f',stdStats(1));
                neg_str_mean = sprintf('%f',meanStats(2));
                neg_str_std = sprintf('%f',stdStats(2));
                predMatchedData = [predMatchedData;{char(pData{k}(l+1,1))},{str},...
                {char(pData{k}(l+1,3))},{char(pData{k}(l+1,4))},{str1},...
                {str2},{str3},{pos_str_mean},{pos_str_std},{neg_str_mean},{neg_str_std}];
            end
        
%             predMatchedData = [predMatchedData;{char(pData{k}(l+1,1))},{str},...
%                 {char(pData{k}(l+1,3))},{char(pData{k}(l+1,4))}];
%             combpredMatchedData = [combpredMatchedData;{char(inFile{k}(9:16))},{char(pData{k}(l+1,1))},...
%                 {str},{char(pData{k}(l+1,3))},{char(pData{k}(l+1,4))}];
        end
        sheettowrite = [inFile{k}(9:16) '_Predicted_Matched'];
        xlswrite([RESULTS_DIR filetowrite],predMatchedData,sheettowrite);
        faultType{k}(indx:end) = [];
    end
    analysis = [{'Month'},{'Fault Type'},{'Matched(kept)'},...
        {'Matched(removed)'},{'Not_Matched(kept)'},{'Not_Matched(removed)'},{'Count'},{'SuccessRatio (%)'}];
    for k = 1:analysed_files
        for l = 1: numel(faultType{k}(:))
            str1 = sprintf('%s', inFile{k}(9:16));
            srratio = (faultType{k}(l).Matched.kept + faultType{k}(l).Not_Matched.removed)/(faultType{k}(l).count);
            str2 = sprintf('%0.2f',srratio*100);
            analysis = [analysis; {inFile{k}(9:16)},{faultType{k}(l).RCA},{faultType{k}(l).Matched.kept},...
                {faultType{k}(l).Matched.removed},{faultType{k}(l).Not_Matched.kept},...
                {faultType{k}(l).Not_Matched.removed},{faultType{k}(l).count},{str2}];
        end
    end
    
%     sheettowrite = 'Comb_Predicted_Matched';
%     xlswrite([RESULTS_DIR filetowrite],combpredMatchedData,sheettowrite);
    sheettowrite = 'Analysis';
    xlswrite([RESULTS_DIR filetowrite],analysis,sheettowrite);
    delete_emptyWorksheet_and_named_worksheet([RESULTS_DIR filetowrite]);

end