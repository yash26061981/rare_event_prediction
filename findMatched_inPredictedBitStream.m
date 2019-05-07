function [actualInstance, instanceHappened,instancePredicted,instanceMatched] = ...
    findMatched_inPredictedBitStream(actualHappened, happenedWithReq, predictedWithReq,inFile,toWrite)
    global NO_INSTANCES RESULTS_DIR
    
    showNextDays = NO_INSTANCES;
    
    szActdata = numel(actualHappened);
    szHapdata = numel(happenedWithReq);
    szPredata = numel(predictedWithReq);
    
    predLastDate = numel(predictedWithReq(1).rcaInstant);
    
    bts_rca_Act = {'BTS_RCA_Combination_Actual'}; bts_rca_Act1 = [{'BTS_RCA_Combination_Actual'},{''},{''},{''}];
    bts_rca_string1 = {'BTS_RCA_Combination1'}; bts_rca_string11 = [{'BTS_RCA_Combination1'},{''},{''},{''}]; 
    bts_rca_string2 = {'BTS_RCA_Combination2'}; bts_rca_string21 = [{'BTS_RCA_Combination2'},{''},{''},{''}];

    i = predLastDate + (1:showNextDays);    
    for j = 1:szHapdata
        if ~isempty(find(happenedWithReq(j).rcaInstant(i) == 1) > 0)
            str = sprintf('%s, %s',happenedWithReq(j).site, happenedWithReq(j).rca);
            bts_rca_string1 = [bts_rca_string1; {str}];

            str1 = int2str(happenedWithReq(j).rcaInstant(1:predLastDate));
            str2 = [];
            for k = 1:showNextDays
                str2 = [str2,sprintf('%d ',happenedWithReq(j).rcaInstant(predLastDate + k))];
            end
            len = (length(find(happenedWithReq(j).rcaInstant(1:predLastDate) > 0)));
            str3 = sprintf('len = %d', len);
            bts_rca_string11 = [bts_rca_string11; {str},{str1},{str2},{str3}];                
        end
    end

    for j = 1:szPredata
        if ~isempty(find(predictedWithReq(j).Pred1(i-predLastDate) > 0) > 0)
            str = sprintf('%s, %s',predictedWithReq(j).site, predictedWithReq(j).rca);
            bts_rca_string2 = [bts_rca_string2; {str}];

            str1 = int2str(predictedWithReq(j).rcaInstant);
            str2 = [];
            for k = 1:showNextDays
                str2 = [str2,sprintf('%d ',predictedWithReq(j).Pred1(k))];
            end
            len = (length(find(predictedWithReq(j).rcaInstant(1,:) > 0)));
            str3 = sprintf('len = %d', len);
            bts_rca_string21 = [bts_rca_string21; {str},{str1},{str2},{str3}];
        end
    end
        
    for j = 1:szActdata
        if ~isempty(find(actualHappened(j).rcaInstant(i) == 1) > 0)
            str = sprintf('%s, %s',actualHappened(j).site, actualHappened(j).rca);
            bts_rca_Act = [bts_rca_Act; {str}];

            str1 = int2str(actualHappened(j).rcaInstant(1:predLastDate));
            str2 = [];
            for k = 1:showNextDays
                str2 = [str2,sprintf('%d ',actualHappened(j).rcaInstant(predLastDate + k))];
            end
            len = (length(find(actualHappened(j).rcaInstant(1:predLastDate) > 0)));
            str3 = sprintf('len = %d', len);
            bts_rca_Act1 = [bts_rca_Act1; {str},{str1},{str2},{str3}];
        end
    end

    [i1,~] = ismember(bts_rca_string1,bts_rca_string2);
    common_string1 = bts_rca_string1(i1,:);
%     common_string2 = bts_rca_string2(i2(i2>0),:);
    actualInstance = length(bts_rca_Act) - 1;
    instanceHappened = length(bts_rca_string1) -1;
    instancePredicted = length(bts_rca_string2) -1;
    instanceMatched = length(common_string1);

    if toWrite
        if exist([RESULTS_DIR inFile],'file')
            delete([RESULTS_DIR inFile]);
        end
        actHappened = convertstr2cell(bts_rca_Act, actualInstance, 1);
        happened = convertstr2cell(bts_rca_string1, instanceHappened, 1);
        predicted = convertstr2cell(bts_rca_string2, instancePredicted, 1);
        matched = convertstr2cell(common_string1, instanceMatched, 0);
%         sheet = 1;
        xlswrite([RESULTS_DIR inFile],actHappened,'ActualInstance');
        xlswrite([RESULTS_DIR inFile],bts_rca_Act1,'ActualInstance+Instance');
        xlswrite([RESULTS_DIR inFile],happened,'Happened');
        xlswrite([RESULTS_DIR inFile],bts_rca_string11,'Happened+Instance');
        xlswrite([RESULTS_DIR inFile],predicted,'Predicted');
        xlswrite([RESULTS_DIR inFile],bts_rca_string21,'Predicted+Instance');
        xlswrite([RESULTS_DIR inFile],matched,'Matched');
    end
end 
