function discoverRules_faultwise
    global RESULTS_DIR USE_OVERLAP_WINDOW USE_INSTANCE_SIZE USE_LAST_VAL_IN_PRED WIDTH_RANGE MIN_GAP
    
    USE_OVERLAP_WINDOW = true;
    USE_INSTANCE_SIZE = -1;
    USE_LAST_VAL_IN_PRED = true;
    WIDTH_RANGE = 3:10;
    MIN_GAP = 1;
    
    warning('off');
    
    RESULTS_DIR = [pwd '\Results\JavaCodeCrossValidation\01022016\testcases\'];
    ruleToDiscover = 'Battery';
   
    inFile = 'Analysed_Java_2Slots_2345.xlsx';
    sheettoread = 'Predicted_Matched';
    filetowrite = [inFile(1:end-5) '_rule_' ruleToDiscover '.xlsx'];
    
    if exist([RESULTS_DIR filetowrite],'file')
        delete([RESULTS_DIR filetowrite]);
    end
    
    [~,~,pData] = xlsread([RESULTS_DIR inFile],sheettoread);
    [row,col] = size(pData(2:end,:));
    
    ruleDiscoverData = [{'OriginalPredicted'},{'Slot1_Matched'},{'Slot2_Matched'},...
        {'Rule_Matched'},{'BitStream'},{'RangeWidth'},{'RangeDensity'},{'S_Ratio'},{'Conclusion'}];

    for k = 1:row
        site_rca = char(pData(k+1,1));
        sepVal = textscan(site_rca,'%s','Delimiter',',-<>');
        rca = char(sepVal{1}(2));
        if strcmp(rca,ruleToDiscover)
            originstance1 = str2num(char(pData(k+1,col)));
            [maxSR, maxW, maxD, res] = discoverRuleforgivenInstant(originstance1);
            
            if (maxW == 0)
                conc = 'Removed';
            elseif res == false
                conc = 'Kept';
            else
                conc = 'Removed';
            end 
            if isnan(pData{k+1,2})
                strpdata2 = '';
            else
                strpdata2 = char(pData(k+1,2));
            end
            if isnan(pData{k+1,3})
                strpdata3 = '';
            else
                strpdata3 = char(pData(k+1,3));
            end
            
            strw = sprintf('%d',maxW); strd = sprintf('%d',maxD); strr = sprintf('%f',maxSR);
            ruleDiscoverData = [ruleDiscoverData;{char(pData(k+1,1))},{strpdata2},...
                {strpdata3},{char(pData(k+1,4))},{char(pData(k+1,5))},{strw},{strd},{strr},{conc}];
        end
    end
    xlswrite([RESULTS_DIR filetowrite],ruleDiscoverData);
%     delete_emptyWorksheet_and_named_worksheet([RESULTS_DIR filetowrite]);

end