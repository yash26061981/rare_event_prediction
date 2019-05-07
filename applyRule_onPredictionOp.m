function applyRule_onPredictionOp() %(inFile,filetowrite)

    global RESULTS_DIR MIN_REQ_LEN  TOTAL_DAYS APPLY_RULE_ON_FINAL_PRED_OP IS_AREA_SITE_CLUBBED...
        USE_JAVA_RESULT DATEOFIP
    
    MIN_REQ_LEN = 4;  TOTAL_DAYS = 100;
    minlen = MIN_REQ_LEN; daystotal = TOTAL_DAYS;
    APPLY_RULE_ON_FINAL_PRED_OP = false;
    IS_AREA_SITE_CLUBBED = true;
    USE_JAVA_RESULT = true;
    
    % rules name, length
    RulesList; %#ok<*NODEF>
    
    DATEOFIP = '27012016'; 
    len = sprintf('_len_0%d', MIN_REQ_LEN);
    inFile = ['predict_' DATEOFIP len '_Months_3_Club_2_Instances_2.xlsx'];
%     inFile = 'predict_27092015_len_04_Months_3_Club_2_Instances_2.xlsx';
    
    if USE_JAVA_RESULT
        pJavaFile1 = [DATEOFIP len '\predicted_pre_filter_10_percent_27thJan.dat'];
        pJavaFile2 = [DATEOFIP len '\31stJan.dat'];
        filetowrite = [inFile(1:end-5) '_Analysed_Java.xlsx'];
    else
        filetowrite = [inFile(1:end-5) '_Analysed.xlsx'];
    end
    
    if USE_JAVA_RESULT
        RESULTS_DIR = [pwd, '\Results\JavaCodeCrossValidation\'];
    else
        RESULTS_DIR = [pwd, '\Results\'];
    end
    
    if ~APPLY_RULE_ON_FINAL_PRED_OP 
%         [~,~,aData] = xlsread([RESULTS_DIR inFile],'ActualInstance');
        if USE_JAVA_RESULT
            pData = read_from_datFile_fromJava(pJavaFile1);
            hData = read_last2Instanrs_from_datFile_fromJava(pJavaFile2);
        else
            [~,~,pData] = xlsread([RESULTS_DIR inFile],'Predicted+Instance');
            [~,~,hData] = xlsread([RESULTS_DIR inFile],'Happened+Instance');
        end
        
%         [~,~,mData] = xlsread([RESULTS_DIR inFile],'Matched');

        % remove particular fault type
%         removeAllTitleCut = false;
%         aData = remove_titlecutfaulttype_from_data(aData,removeAllTitleCut);
%         pData = remove_titlecutfaulttype_from_data(pData,removeAllTitleCut);
%         hData = remove_titlecutfaulttype_from_data(hData,removeAllTitleCut);
%         mData = remove_titlecutfaulttype_from_data(mData,removeAllTitleCut);    

        pkey = pData(2:end,1);
        pinstance = pData(2:end,2);
%         ppredinst = pData(2:end,3);

        hkey = hData(2:end,1);
%         hinstance = hData(2:end,2);

%         mkey = mData(2:end,1);
%         mrca = mData(2:end,2);
%         mkeysz = numel(mkey);
%         mkeydata = cell(mkeysz,1);
%         for k =1:mkeysz
%             mkeydata{k} = sprintf('%s, %s',mkey{k},mrca{k});
%         end
        pkeysz = numel(pkey);
        pkeydata = cell(pkeysz,5);
        for k = 1:pkeysz
            val = char(pkey(k));
            pkeydata{k,1} = val;
            sepVal = textscan(val,'%s','Delimiter',',');
            pkeydata{k,2} = char(sepVal{1}(1));
            pkeydata{k,3} = char(sepVal{1}(2));
            pkeydata{k,4} = str2num(char(pinstance(k)));
            pkeydata{k,5} = pinstance(k);
%             pkeydata{k,6} = str2num(char(ppredinst(k)));
        end
        pkeydata_ruled = pkeydata;
        torem = zeros(pkeysz,1);
        for k = 1:pkeysz
            indx = findIndx(Rules(:,1)', pkeydata{k,3});
            if indx ~= -1
                reqlen = Rules{indx,2};
                instances = pkeydata{k,4};  
                isfilter = applyRuleCases(pkeydata{k,3}, instances, reqlen);
                if isfilter
                    torem(k,1) = 1;
                else
                    if (strcmp(pkeydata{k,3},'Battery1') || strcmp(pkeydata{k,3},'PIU Failure1'))
                        if computeProbability(10,pkeydata{k,3})
                            torem(k,1) = 1;
                        end
                    end
                end
            end
    %         if strcmp(pkeydata{k,3},'Communications Between BSC and BTS Interrupted') && (torem(k,1) == 1)
    %             str = sprintf('Removed - %s---%s',pkeydata{k,2},pkeydata{k,3});
    %             disp(str);
    %         end

        end
        % removed as per the rule
        torem = logical(torem);
        pkeydata_ruled(torem,:) = [];
    
        pdr = pkeydata_ruled(:,1);
        pd = pkeydata(:,1);
        hp = hkey;
        [i1,~] = ismember(pd,hp);
        mkey = pkeydata(i1,:);
        [i2,~] = ismember(pdr, hp);
        comP = pkeydata_ruled(i2,:);
%         % pd are the predicted as per rule, hp are happened and mp are matched
%         pd = pkeydata_ruled(:,1);
%         hp = hkey;
%         mp = mkeydata;
%         [i1,~] = ismember(pd,hp);
%         [i2,~] = ismember(hp, pd);
%         % comP are the matched prediction and comNP are the false prediction
%         comP = pkeydata_ruled(i1,:);
%         comNP = pkeydata_ruled(~i1,:);
%         % in without Rule matched, how much is mathced with rule and how many
%         % are not. comPM are the matched prediction with rule and comPMR are
%         % the removed matched prediction beacause of rule.
%         [i3,~] = ismember(mp,comP(:,1));
%     %     comPM = mp(i3,:);
%         comPMR = mp(~i3,:);
%         [i4, ~] = ismember(pkeydata(:,1),comPMR);
%         comPMR = pkeydata(i4,:);
%         % comNH are the happened, but not predicted.
%         comNH = hp(~i2,:);
% 
%         pd = pkeydata(:,1);
%         mp = mkeydata;
%         [i1,~] = ismember(pd,mp);
%         [i2,~] = ismember(pd,comP(:,1));
    
        bts_rca_PredictedMatched = [{'OriginalPredicted'},{'Original_Matched'},...
            {'Rule_Matched'},{'bitstream'}];
        for j = 1:length(pkeydata)
            str = sprintf('%s',pkeydata{j,1});
            str1 = char(pkeydata{j,5});
            if i1(j)
                str2 = 'Matched';
            else
                str2 = '';
            end
            if torem(j)
                str3 = 'removed';
            else
                str3 = 'kept';
            end

            bts_rca_PredictedMatched = [bts_rca_PredictedMatched; {str},{str2},{str3},{str1}];
        end
    
%         bts_rca_rulePredicted = [{'BTS_RCA_Rule_Prediction'},{''},{''}];
%         for j = 1:length(pkeydata_ruled)
%             str = sprintf('%s',pkeydata_ruled{j,1});
%             str1 = char(pkeydata_ruled{j,5});
%             len = (length(find(pkeydata_ruled{j,4} > 0)));
%             str2 = sprintf('len = %d', len);
%             bts_rca_rulePredicted = [bts_rca_rulePredicted; {str},{str1},{str2}];
%         end

%         comP_rulePredicted = [{'BTS_RCA_Rule_Prediction'},{''},{''}];
%         for j = 1:length(comP)
%             str = sprintf('%s',comP{j,1});
%             str1 = char(comP{j,5});
%             len = (length(find(comP{j,4} > 0)));
%             str2 = sprintf('len = %d', len);
%             comP_rulePredicted = [comP_rulePredicted; {str},{str1},{str2}];
%         end
%         comN_rulePredicted = [{'BTS_RCA_Rule_NotMatchedPrediction'},{''},{''}];
%         for j = 1:length(comNP)
%             str = sprintf('%s',comNP{j,1});
%             str1 = char(comNP{j,5});
%             len = (length(find(comNP{j,4} > 0)));
%             str2 = sprintf('len = %d', len);
%             comN_rulePredicted = [comN_rulePredicted; {str},{str1},{str2}];
%         end
%         comPMR_rulePredicted = [{'BTS_RCA_Rule_RemovedMatchedPrediction'},{''},{''}];
%         for j = 1:length(comPMR)
%             str = sprintf('%s',comPMR{j,1});
%             str1 = char(comPMR{j,5});
%             len = (length(find(comPMR{j,4} > 0)));
%             str2 = sprintf('len = %d', len);
%             comPMR_rulePredicted = [comPMR_rulePredicted; {str},{str1},{str2}];
%         end
% 
%         comNH_ruleHappened = [{'BTS_RCA_Rule_NotMachedHappened'},{''},{''}];
%         for j = 1:length(comNH)
%             str = sprintf('%s',comNH{j});
%             str1 = char(hinstance{j});
%             len = (length(find(str2num(hinstance{j}) > 0)));
%             str2 = sprintf('len = %d', len);
%             comNH_ruleHappened = [comNH_ruleHappened; {str},{str1},{str2}];
%         end
        pkeydata_ruled(:,2:4) = [];
    %     xlswrite(filetoread,bts_rca_rulePredicted,'RulesPredicted');
    %     xlswrite(filetoread,comP_rulePredicted,'RulesMatched');
    %     xlswrite(filetoread,comN_rulePredicted,'NotMatchedPred');
    %     xlswrite(filetoread,comNH_ruleHappened,'NotMatchedHapp');
        if exist([RESULTS_DIR filetowrite],'file')
            delete([RESULTS_DIR filetowrite]);
        end
        sheettowrite = ['predicted_' inFile(9:16)];
        xlswrite([RESULTS_DIR filetowrite],bts_rca_PredictedMatched,sheettowrite);
        delete_emptyWorksheet_and_named_worksheet([RESULTS_DIR filetowrite]);
    %     xlswrite([RESULTS_DIR filetowrite],comPMR_rulePredicted,'Incorreclty_Removed');
    %     xlswrite([RESULTS_DIR filetowrite],comN_rulePredicted,'Not_Removed');
    
        str1 = sprintf('\t\t------- Before Rule for %s, length %d and %d days ------------',inFile(9:16),minlen,daystotal);
%         str7 = sprintf(' Actual Isntances happened = %d',length(aData));
        str2 = sprintf('       Isntances happened = %d',length(hkey));
        str3 = sprintf('      Predicted Isntances = %d',length(pkeydata));
        str4 = sprintf('        Matched Isntances = %d',length(mkey));
        str5 = sprintf('\n        Recall  = %2.2f%%',(length(mkey)/length(hkey))*100);
        str6 = sprintf('     Precision  = %2.2f%%\n\n',(length(mkey)/length(pkeydata))*100);
        disp(str1);
%         disp(str7);
        disp(str2);
        disp(str3);
        disp(str4);
        disp(str5);
        disp(str6);

        str1 = sprintf('\t\t------- After Rule for %s, length %d and %d days ------------',inFile(9:16),minlen,daystotal);
%         str7 = sprintf(' Actual Isntances happened = %d',length(aData));
        str2 = sprintf('       Isntances happened = %d',length(hkey));
        str3 = sprintf('      Predicted Isntances = %d',length(pkeydata_ruled));
        str4 = sprintf('        Matched Isntances = %d',length(comP));
        str5 = sprintf('\n        Recall  = %2.2f%%',(length(comP)/length(hkey))*100);
        str6 = sprintf('     Precision  = %2.2f%%\n\n',(length(comP)/length(pkeydata_ruled))*100);
        disp(str1);
%         disp(str7);
        disp(str2);
        disp(str3);
        disp(str4);
        disp(str5);
        disp(str6);
    
        str1 = sprintf('      Incorrectly Removed Matched Instances = %d',(length(mkey)-length(comP)));
        str2 = sprintf('           Not Removed Un-Matched Instances = %d',(length(pkeydata_ruled)-length(comP)));
        disp(str1);
        disp(str2);
%         analyse_rules_faultwise(filetowrite);
        analyse_rules_faultwise_StatisticalAnalysis(filetowrite);
    else
        [~,~,pData] = xlsread([RESULTS_DIR inFile],'Predicted+Instance');

        % remove particular fault type
        removeAllTitleCut = false;       
        pData = remove_titlecutfaulttype_from_data(pData,removeAllTitleCut);

        pkey = pData(2:end,1);
        pinstance = pData(2:end,2);

        pkeysz = numel(pkey);
        pkeydata = cell(pkeysz,5);
        for k = 1:pkeysz
            val = char(pkey(k));
            pkeydata{k,1} = val;
            sepVal = textscan(val,'%s','Delimiter',',');
            if IS_AREA_SITE_CLUBBED
                siteval = char(sepVal{1}(1));
                sitesepVal = textscan(siteval,'%s','Delimiter','()');
                pkeydata{k,2} = char(sitesepVal{1}(2));
            else
                pkeydata{k,2} = char(sepVal{1}(1));
            end            
            pkeydata{k,3} = char(sepVal{1}(2));
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
                isfilter = applyRuleCases(pkeydata{k,3}, instances, reqlen);
                if isfilter
                    torem(k,1) = 1;
                else
                    if (strcmp(pkeydata{k,3},'Battery1') || strcmp(pkeydata{k,3},'PIU Failure1'))
                        if computeProbability(10,pkeydata{k,3})
                            torem(k,1) = 1;
                        end
                    end
                end
            end
        end
        % removed as per the rule
        torem = logical(torem);
        pkeydata_ruled(torem,:) = [];
        
        bts_rca_rulePredicted = [{'BTS_RCA_Rule_Predicted'},{'Instances'},{'Length'}];
        bts_site_rca_comb = [{'site_rca'}];
        for j = 1:length(pkeydata_ruled)
            str = sprintf('%s',pkeydata_ruled{j,1});
            str1 = char(pkeydata_ruled{j,5});
            len = (length(find(pkeydata_ruled{j,4} > 0)));
            str2 = sprintf('%d', len);
            bts_rca_rulePredicted = [bts_rca_rulePredicted; {str},{str1},{str2}];
            str = sprintf('%s, %s',pkeydata_ruled{j,2},pkeydata_ruled{j,3});
            bts_site_rca_comb = [bts_site_rca_comb; {str}];
        end
        
        if exist([RESULTS_DIR filetowrite],'file')
            delete([RESULTS_DIR filetowrite]);
        end
        sheettowrite = ['predicted_' inFile(9:16)];
        xlswrite([RESULTS_DIR filetowrite],bts_rca_rulePredicted,sheettowrite);
        delete_emptyWorksheet_and_named_worksheet([RESULTS_DIR filetowrite]);
    
        predicted = convertstr2cell(bts_site_rca_comb, length(pkeydata_ruled), 1);
        predictedInfo = cell2dataset(predicted);
        export(predictedInfo,'file',[RESULTS_DIR [sheettowrite '.dat']],'delimiter',',');
        

        str1 = sprintf('\t\t------- Before Rule for %s, length %d and %d days ------------',inFile(9:16),minlen,daystotal);
        str2 = sprintf('      Predicted Isntances = %d',length(pkeydata));
        disp(str1);
        disp(str2);

        str1 = sprintf('\t\t------- After Rule for %s, length %d and %d days ------------',inFile(9:16),minlen,daystotal);
        str2 = sprintf('      Predicted Isntances = %d',length(pkeydata_ruled));
        disp(str1);
        disp(str2);

    end
end
