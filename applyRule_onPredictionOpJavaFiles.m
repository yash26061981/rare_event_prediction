function applyRule_onPredictionOpJavaFiles %(inFile,filetowrite)

    global RESULTS_DIR DAYS USE_SLOT_2 COUNT_ALL_MATCHED_IN_SLOTS USE_RULE_DISCOVERY USE_SUB_RCA
    
    USE_SUB_RCA = true;
    COUNT_ALL_MATCHED_IN_SLOTS = false;
    USE_RULE_DISCOVERY = false;
    USE_SLOT_2 = false;
    % rules name, length
    RulesList; %#ok<*NODEF>
    testCases = [{'2345'},{'6789'},{'10111213'},{'14151617'}];
    id = 1;
    DAYS = testCases{id};
    
    RESULTS_DIR = [pwd, '\Results\JavaCodeCrossValidation\24022016\'];
    
    pJavaFile1 = [testCases{id} '\intermediate.dat'];
    pJavaFile2 = [testCases{id+1} '\input.dat'];
    
    if USE_SLOT_2
        pJavaFile3 = [testCases{id+2} '\input.dat'];
    end
    if USE_SLOT_2
        filetowrite = ['Analysed_Java_2Slots_' DAYS '.xlsx'];
    else
        filetowrite = ['Analysed_Java_' DAYS '.xlsx'] ;
    end
        
    
    pData = read_from_datFile_fromJava(pJavaFile1);
    h1Data = read_last2Instanrs_from_datFile_fromJava(pJavaFile2);
    if USE_SLOT_2
        h2Data = read_last2Instanrs_from_datFile_fromJava(pJavaFile3);
    end
        
    pkey = pData(2:end,1);
    pinstance = pData(2:end,2);

    h1key = h1Data(2:end,1);
    if USE_SLOT_2
        h2key = h2Data(2:end,1);
    end
    
    pkeysz = numel(pkey);
    pkeydata = cell(pkeysz,5);
    for k = 1:pkeysz
        val = char(pkey(k));
        pkeydata{k,1} = val;
        if USE_SUB_RCA
            sepVal = textscan(val,'%s%s','Delimiter',',');
            pkeydata{k,2} = char(sepVal{1}(1));
            rcaVal = textscan(char(sepVal{2}(1)),'%s%s','Delimiter','<>');
            pkeydata{k,3} = char(rcaVal{1}(1));
        else
            sepVal = textscan(val,'%s','Delimiter',',');
            pkeydata{k,2} = char(sepVal{1}(1));
    %         rcaVal = textscan(char(sepVal{1}(2)),'%s','Delimiter','-<>');
            pkeydata{k,3} = char(sepVal{1}(2));
        end
        pkeydata{k,4} = str2num(char(pinstance(k)));
        pkeydata{k,5} = pinstance(k);
    end
    pkeydata_ruled = pkeydata;
    torem = zeros(pkeysz,1);
    for k = 1:pkeysz
        indx = findIndx(Rules(:,1)', pkeydata{k,3});
        if indx ~= -1
            reqlen = Rules{indx,2};
            instances = pkeydata{k,4};  
            %%% to remove those instances whose length is less than 6
            sumInst = sum(instances);
            if sumInst < 4
                torem(k,1) = 1;
            else
                isfilter = applyRuleCases(pkeydata{k,3}, instances, reqlen);
                if isfilter
                    torem(k,1) = 1;
                end
            end
        end
    end
    
    % removed as per the rule
    torem = logical(torem);
    pkeydata_ruled(torem,:) = [];

    pdr = pkeydata_ruled(:,1);
    pd = pkeydata(:,1);
    h1p = h1key;
    
    [before_rule_slot1_match,~] = ismember(pd,h1p);
    slot1_Matched = pd(before_rule_slot1_match,1);
    [after_rule_slot1_match,~] = ismember(pdr, h1p);
    slot1_Rule_Matched = pdr(after_rule_slot1_match,1);
    
    beforeRule_Matched = length(slot1_Matched);
    afterRule_Matched = length(slot1_Rule_Matched);
    if USE_SLOT_2
        h2p = h2key;
        if COUNT_ALL_MATCHED_IN_SLOTS
            remPd = pd;
            remPdr = pdr;
        else
            remPd = pd;
            remPd(before_rule_slot1_match,1) = {'Slot1Matched'};
            remPdr = pdr(~after_rule_slot1_match,1);
        end
        [before_rule_slot2_match,~] = ismember(remPd,h2p);
        slot2_Matched = pd(before_rule_slot2_match,1);            
        [after_rule_slot2_match,~] = ismember(remPdr, h2p);
        slot2_Rule_Matched = remPdr(after_rule_slot2_match,1);
        
        beforeRule_Matched = beforeRule_Matched + length(slot2_Matched);
        afterRule_Matched = afterRule_Matched + length(slot2_Rule_Matched);
    end
    
    
    if USE_SLOT_2
        bts_rca_PredictedMatched = [{'OriginalPredicted'},{'Slot1_Matched'},{'Slot2_Matched'},...
            {'Rule_Matched'},{'bitstream'}];
    else
        bts_rca_PredictedMatched = [{'OriginalPredicted'},{'Matched'},...
            {'Rule_Matched'},{'bitstream'}];
    end
    
    for j = 1:length(pkeydata)
        str = sprintf('%s',pkeydata{j,1});
        str1 = char(pkeydata{j,5});
        str2 = '';
        if before_rule_slot1_match(j)
            str2 = 'Matched';
        end
        if USE_SLOT_2
            str3 = '';
            if COUNT_ALL_MATCHED_IN_SLOTS
                if before_rule_slot2_match(j)
                    str3 = 'Matched';
                end
            else
                if (before_rule_slot2_match(j) && ~before_rule_slot1_match(j))
                    str3 = 'Matched';
                end
            end                
        end
        str4 = 'kept';
        if torem(j)
            str4 = 'removed';
        end
            
        if USE_SLOT_2
            bts_rca_PredictedMatched = [bts_rca_PredictedMatched; {str},{str2},{str3},{str4},{str1}];
        else
            bts_rca_PredictedMatched = [bts_rca_PredictedMatched; {str},{str2},{str4},{str1}];
        end
        
    end


    str1 = sprintf('\t\t------- Before Rule for %s ------------',DAYS);
    str2 = sprintf('       Isntances happened = %d',length(h1key));
    str3 = sprintf('      Predicted Isntances = %d',length(pkeydata));
    str4 = sprintf('  Slot1 Matched Isntances = %d',length(slot1_Matched));
    if USE_SLOT_2
        str41 = sprintf('  Slot2 Matched Isntances = %d',length(slot2_Matched));
    end
    str5 = sprintf('\n        Recall  = %2.2f%%',(beforeRule_Matched/length(h1key))*100);
    str6 = sprintf('     Precision  = %2.2f%%\n\n',(beforeRule_Matched/length(pkeydata))*100);
    disp(str1);
%         disp(str7);
    disp(str2);
    disp(str3);
    disp(str4);
    if USE_SLOT_2
        disp(str41);
    end
    disp(str5);
    disp(str6);

    str1 = sprintf('\t\t------- After Rule for %s ------------',DAYS);
%         str7 = sprintf(' Actual Isntances happened = %d',length(aData));
    str2 = sprintf('       Isntances happened = %d',length(h1key));
    str3 = sprintf('      Predicted Isntances = %d',length(pkeydata_ruled));
    str4 = sprintf('  Slot1 Matched Isntances = %d',length(slot1_Rule_Matched));
    if USE_SLOT_2
        str41 = sprintf('  Slot2 Matched Isntances = %d',length(slot2_Rule_Matched));
    end
    str5 = sprintf('\n        Recall  = %2.2f%%',(afterRule_Matched/length(h1key))*100);
    str6 = sprintf('     Precision  = %2.2f%%\n\n',(afterRule_Matched/length(pkeydata_ruled))*100);
    disp(str1);
%         disp(str7);
    disp(str2);
    disp(str3);
    disp(str4);
    if USE_SLOT_2
        disp(str41);
    end
    disp(str5);
    disp(str6);

    str1 = sprintf('      Incorrectly Removed Matched Instances = %d',(beforeRule_Matched-afterRule_Matched));
    str2 = sprintf('           Not Removed Un-Matched Instances = %d',(length(pkeydata_ruled)-afterRule_Matched));
    disp(str1);
    disp(str2);

    
    sz = numel(bts_rca_PredictedMatched(2:end,1));
    faultType = repmat(struct('RCA','rca','Matched',struct('kept',0,'removed',0),...
        'Not_Matched',struct('kept',0,'removed',0),'count',1),sz,1);
    indx = 1;
    for l = 1:sz
        val = char(bts_rca_PredictedMatched(l+1,1));
        sepVal = textscan(val,'%s','Delimiter',',');
        rca = char(sepVal{1}(2));
        findx = findIndxbyField(faultType(1:indx), 'RCA', rca);
        if ~findx
            findx = indx;
            faultType(findx).RCA = rca;
            indx = indx +1;
        else
            faultType(findx).count = faultType(findx).count + 1;
        end
        if USE_SLOT_2
            if (strcmp(bts_rca_PredictedMatched(l+1,2),'Matched') || ...
                    strcmp(bts_rca_PredictedMatched(l+1,3),'Matched'))
                if strcmp(bts_rca_PredictedMatched(l+1,4),'kept')
                    faultType(findx).Matched.kept = faultType(findx).Matched.kept +1;
                else
                    faultType(findx).Matched.removed = faultType(findx).Matched.removed +1;
                end
            else
                if strcmp(bts_rca_PredictedMatched(l+1,4),'kept')
                    faultType(findx).Not_Matched.kept = faultType(findx).Not_Matched.kept +1;
                else
                    faultType(findx).Not_Matched.removed = faultType(findx).Not_Matched.removed +1;
                end
            end  
        else
            if (strcmp(bts_rca_PredictedMatched(l+1,2),'Matched'))
                if strcmp(bts_rca_PredictedMatched(l+1,3),'kept')
                    faultType(findx).Matched.kept = faultType(findx).Matched.kept +1;
                else
                    faultType(findx).Matched.removed = faultType(findx).Matched.removed +1;
                end
            else
                if strcmp(bts_rca_PredictedMatched(l+1,3),'kept')
                    faultType(findx).Not_Matched.kept = faultType(findx).Not_Matched.kept +1;
                else
                    faultType(findx).Not_Matched.removed = faultType(findx).Not_Matched.removed +1;
                end
            end  
        end
    end
    sheettowrite = 'Predicted_Matched';
    xlswrite([RESULTS_DIR filetowrite],bts_rca_PredictedMatched,sheettowrite);
    faultType(indx:end) = [];
    
    analysis = [{'Fault Type'},{'Matched(kept)'},...
        {'Matched(removed)'},{'Not_Matched(kept)'},{'Not_Matched(removed)'},{'Count'},{'SuccessRatio (%)'}];
    
    for l = 1: numel(faultType(:))
        srratio = (faultType(l).Matched.kept + faultType(l).Not_Matched.removed)/(faultType(l).count);
        str2 = sprintf('%0.2f',srratio*100);
        analysis = [analysis; {faultType(l).RCA},{faultType(l).Matched.kept},...
            {faultType(l).Matched.removed},{faultType(l).Not_Matched.kept},...
            {faultType(l).Not_Matched.removed},{faultType(l).count},{str2}];
    end
    sheettowrite = 'Analysis';
    xlswrite([RESULTS_DIR filetowrite],analysis,sheettowrite);
    delete_emptyWorksheet_and_named_worksheet([RESULTS_DIR filetowrite]);
end
