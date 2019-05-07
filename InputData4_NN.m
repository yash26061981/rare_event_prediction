function InputData4_NN ()%(dateofip,len)
    global RESULTS_DIR DATA_DIR;
    currDir = pwd;
    RESULTS_DIR = [currDir, '\Results\'];
    DATA_DIR = [currDir, '\Data\'];
    
    dateofip = '27092015'; 
    len = '_len_04';
    rca_analyse = false;
    use_byte_pred = false;
    
    if rca_analyse
        rca_types = {'Battery','PIU Failure','All RCS signalling links are down'...
            'Communications Between BSC and BTS Interrupted'};
        rca_to_analyse = rca_types{4};
    end  
    
    fileToRead = ['predict_' dateofip len '_Months_3_Club_2_Instances_2.xlsx'];
    dataToLoad = ['analysedSplitted_' dateofip len '_Months_3_Club_2_Instances_2.mat'];
    
    iFile = [dateofip len '\iP_' dateofip len '.dat'];
    aFile = [dateofip len '\actual_' dateofip '.dat'];
    hFile = [dateofip len '\happened_' dateofip len '.dat'];
    if use_byte_pred
        byteFile = [dateofip len '\rcabytes_' dateofip len '.dat'];
        if exist([RESULTS_DIR byteFile],'file')
            delete([RESULTS_DIR byteFile]);
        end
        byteIndx = 0;
    end
    if rca_analyse
        rcaFile = [dateofip len '\' rca_to_analyse '_' dateofip len '.dat'];
        if exist([RESULTS_DIR rcaFile],'file')
            delete([RESULTS_DIR rcaFile]);
        end
        rcaexcelFile = [dateofip len '\' rca_to_analyse '_' dateofip len '.xlsx'];
        if exist([RESULTS_DIR rcaexcelFile],'file')
            delete([RESULTS_DIR rcaexcelFile]);
        end
        rcaIndx = 0;
        rca_runtest = [{'Site_RCA'},{'Instances'},{'RunTest_Result'},...
            {'Ones_Stats (Mean, Std)'},{'Zeros_Stats (Mean, Std)'}];
    end
    
    if ~exist([RESULTS_DIR dateofip len '\'],'dir')
        mkdir([RESULTS_DIR dateofip len '\']);
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
    
    datafile = [DATA_DIR, dataToLoad];
    load(datafile);
    keysz = numel(AnalyseData_Splitted.Info);
%     PredictedInstances = repmat(struct('key','IN','val','IN'),1,keysz);

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
            if rca_analyse
                if strcmp(rcaInfo(j).name, rca_to_analyse)
                    rcaIndx = rcaIndx + 1;
                    rcaInstances{rcaIndx,1} = str;
                    rcaInstances{rcaIndx,2} = (siteInfo.bitStream(j,:));
                    [result,pos,neg] = run_test_to_check_randomness(siteInfo.bitStream(j,:));
                    if result % i.e true, i.e. reject H0:  the sequence was produced in a random manner
                        rcaInstances{rcaIndx,3} = 'Non-Random';
                    else
                        rcaInstances{rcaIndx,3} = 'Random';
                    end
                    mpos = mean(pos); mneg = mean(neg);
                    stdpos = std(pos); stdneg = std(neg);
                    pos_str = sprintf('Mean = %f, Std = %f',mpos,stdpos);
                    neg_str = sprintf('Mean = %f, Std = %f',mneg,stdneg);
                    rca_runtest = [rca_runtest;{str},{num2str(siteInfo.bitStream(j,:))},...
                        {rcaInstances{rcaIndx,3}},{pos_str},{neg_str}];
                end
            end
        end
        if use_byte_pred
            byteIndx = byteIndx + 1;
            [bytes,~] = getByte_BitStream(rcaSz,siteInfo.bitStream,0);
            str = sprintf('%s, Total RCA Count %d',siteName,rcaSz);
            ByteInstances{byteIndx,1} = str;
            ByteInstances{byteIndx,2} = bytes;
        end
    end
    writetoTextFile(PredictedInstances,iFile);
    if rca_analyse
        writetoTextFile(rcaInstances,rcaFile);
        xlswrite([RESULTS_DIR rcaexcelFile],rca_runtest,1);
    end
    if use_byte_pred
        writetoTextFile(ByteInstances,byteFile);
    end
    
    file = [RESULTS_DIR, fileToRead];
    [~, ~ , dataA] = xlsread(file, 'ActualInstance+Instance');
    [~, ~ , dataH] = xlsread(file, 'Happened+Instance');
    
    hkey = dataH(2:end,1);
    hval = dataH(2:end,2);
    akey = dataA(2:end,1);
    aval = dataA(2:end,2);
    
   
    keysz = max(size(hkey));
    keyvalPair = cell(keysz,1);
    for i = 1:keysz
        keyvalPair{i,1} = hkey{i};
%         keyvalPair{i,2} = str2num(hval{i});
    end
    writetoTextFile(keyvalPair,hFile);
    
    keysz = max(size(akey));
    keyvalPair = cell(keysz,1);
    for i = 1:keysz
        keyvalPair{i,1} = akey{i};
%         keyvalPair{i,2} = str2num(aval{i});
    end
    writetoTextFile(keyvalPair,aFile);    
end