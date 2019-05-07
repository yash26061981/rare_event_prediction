function analyse_rules_faultwise(inFile1)
    global RESULTS_DIR USE_JAVA_RESULT %MIN_REQ_LEN TOTAL_MONTH
%     MIN_REQ_LEN = 8;  TOTAL_MONTH = 3;
%     minlen = MIN_REQ_LEN; months = TOTAL_MONTH;
    warning('off');
    analysed_files = 1;
%     RESULTS_DIR = [pwd, '\Results\'];

%     filetoread = 'Results\predict_28102015_len_08_Months_3_Club_2_Instances_2.xlsx';
%     filetowrite = 'predict_28102015_len_08_Months_3_Club_2_Instances_2_BatteryAnalysis_new.xlsx';
%     filetoread = 'Results_ClubDays2\predict_30102015_len_10_forMonths_3.xlsx';
%     inFile = {'predict_08102015_len_08_Months_3_Club_2_Instances_2_Analysed.xlsx',...
%                'predict_27092015_len_08_Months_3_Club_2_Instances_2_Analysed.xlsx',...
%                'predict_28102015_len_08_Months_3_Club_2_Instances_2_Analysed.xlsx'};
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
%     combpredMatchedData = [{'Month'},{'Site,RCA'},{'Matched'},{'Rules_Op'},{'BitStream'}];
    for k = 1:analysed_files
        sheettoread = ['predicted_' inFile{k}(9:16)];
        [~,~,pData{k}] = xlsread([RESULTS_DIR inFile{k}],sheettoread);
        predMatchedData = [{'Site,RCA'},{'Matched'},{'Rules_Op'},{'BitStream'}];
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
            predMatchedData = [predMatchedData;{char(pData{k}(l+1,1))},{str},...
                {char(pData{k}(l+1,3))},{char(pData{k}(l+1,4))}];
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