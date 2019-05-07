function computeCorrelation_showTrends()
    global TOP_MATCHED SHIFT RESULTS_DIR FIG_DIR;
    TOP_MATCHED = -1; % SHIFT = 1;
    currDir = pwd;
    RESULTS_DIR = [currDir, '\Results\'];
    
    
    dateVec = '01112015';
    len = '05';
    fileToRead = sprintf('predict_%s_len_%s.xlsx',dateVec,len);
    oFile = sprintf('predict_%s_len_%s_CorrelationPattern.xlsx',dateVec,len);
    trendDir = sprintf('Trends_%s_len_%s\\',dateVec,len);
%     fileToRead = 'predict_24102015_len_25.xlsx';
%     oFile = 'predict_24102015_len_25_CorrelationPattern.xlsx';
    
    if exist([RESULTS_DIR oFile],'file')
        delete([RESULTS_DIR oFile]);
    end
    FIG_DIR = [RESULTS_DIR, trendDir];
    if exist(FIG_DIR,'dir')
        rmdir(FIG_DIR,'s');
    end
    mkdir(FIG_DIR);
    
    
    file = [RESULTS_DIR, fileToRead];
    [~, ~ , alldata] = xlsread(file, 'Predicted+Instance');
    [r, ~] = size(alldata);
    namePred = alldata(:,1); instPred = alldata(:,2);

    corrCoeff = repmat(struct('name','BTS_RCA','matched','BTS_RCA','coeff',0,...
        'Inst',[],'matchedInst',[]),(r-1),1);  
    coeff = zeros(1, (r - 1));

    for i = 2: r 
        data = str2num(char(instPred(i)));
        maxVal = 0; maxIndx = 0;
        for j = 2: r
            temp = str2num(char(instPred(j)));
            c = corr2(data,temp);
            if j~= i
                if c > maxVal
                    maxVal = c;
                    maxIndx = j;
                end
            end
        end
        corrCoeff(i-1).name = namePred(i);
        corrCoeff(i-1).matched = namePred(maxIndx);
        corrCoeff(i-1).coeff = maxVal; 
        corrCoeff(i-1).Inst = instPred(i);
        corrCoeff(i-1).matchedInst = instPred(maxIndx);
        coeff(i-1) = maxVal;
    end
    if TOP_MATCHED == -1
        [~,topIndx] = sort(coeff,'descend');
    else
        topIndx = findNumber_of_Max_Values(TOP_MATCHED,coeff);
    end
    bts_rca_comb = [{'Top matching incidences'},{''},{''}];
    bts_rca_comb = [bts_rca_comb;{'Site , RCA'},{'Incidences (48Hours)'},{'Correlation'}];
    for k = 1:length(topIndx)
        str = cell(2,3);
        str{1,1} = char(corrCoeff(topIndx(k)).name);
        str{2,1} = char(corrCoeff(topIndx(k)).matched);

        str{1,2} = char(corrCoeff(topIndx(k)).Inst);
        str{2,2} = char(corrCoeff(topIndx(k)).matchedInst);

        str{1,3} = '--';
        str{2,3} = double(corrCoeff(topIndx(k)).coeff);

        bts_rca_comb = [bts_rca_comb;str];
        bts_rca_comb = [bts_rca_comb;{''},{''},{''}];
    end

    sheetToWrite1 = 'CorrelatedIncidences';
    xlswrite([RESULTS_DIR oFile],bts_rca_comb,sheetToWrite1);
    
    bts_rca_comb = [{'Top matching incidences'},{''},{''}];
    bts_rca_comb = [bts_rca_comb;{'Site , RCA'},{'Incidences (48Hours)'},{'Correlation'}];
    
    for SHIFT = -3:3
        bts_rca_comb_pattern = [{'Top matching Sequential incidences'},{''},{''}];
        bts_rca_comb_pattern = [bts_rca_comb_pattern;{'Site , RCA'},{'Incidences (48Hours)'},{'Correlation'}];
        if SHIFT < 0
            str = sprintf('past_%d_Instances',SHIFT);
        else
            str = sprintf('future_%d_Instances',SHIFT);
        end
        sheetToWrite = str;
        if SHIFT ~= 0
            corrCoeffPattern = repmat(struct('name','BTS_RCA','matched','BTS_RCA','coeff',0,...
                'Inst',[],'matchedInst',[]),(r-1),1);
            coeffPattern = zeros(1,(r - 1));
            for i = 2: r 
                data = str2num(char(instPred(i)));
                maxVal1 = 0; maxIndx1 = 0;
                for j = 2: r
                    temp = str2num(char(instPred(j)));
                    temp1 = shiftBybits(SHIFT,temp);
                    c1 = corr2(data,temp1);
                    if j~= i
                        if c1 > maxVal1
                            maxVal1 = c1;
                            maxIndx1 = j;
                        end
                    end
                end
                if maxIndx1
                    corrCoeffPattern(i-1).name = namePred(i);
                    corrCoeffPattern(i-1).matched = namePred(maxIndx1);
                    corrCoeffPattern(i-1).coeff = maxVal1; 
                    corrCoeffPattern(i-1).Inst = instPred(i);
                    corrCoeffPattern(i-1).matchedInst = instPred(maxIndx1);
                    coeffPattern(i-1) = maxVal1;
                end
            end
 
            if TOP_MATCHED == -1
                [~,topIndxPattern] = sort(coeffPattern,'descend');
            else
                topIndxPattern = findNumber_of_Max_Values(TOP_MATCHED,coeffPattern);
            end
            for k = 1:length(topIndxPattern)
                str = cell(2,3);
                str{1,1} = char(corrCoeffPattern(topIndxPattern(k)).name);
                str{2,1} = char(corrCoeffPattern(topIndxPattern(k)).matched);

                str{1,2} = char(corrCoeffPattern(topIndxPattern(k)).Inst);
                str{2,2} = char(corrCoeffPattern(topIndxPattern(k)).matchedInst);

                str{1,3} = '--';
                str{2,3} = double(corrCoeffPattern(topIndxPattern(k)).coeff);

                bts_rca_comb_pattern = [bts_rca_comb_pattern;str];
                bts_rca_comb_pattern = [bts_rca_comb_pattern;{''},{''},{''}];
            end
            xlswrite([RESULTS_DIR oFile],bts_rca_comb_pattern,sheetToWrite);
        end
    end
    show_trend(namePred, instPred, 1);
end