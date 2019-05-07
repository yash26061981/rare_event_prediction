function instancePredicted = writeTouserDefinedFile(preddata,inFile,toWrite,inFile1)
    global NO_INSTANCES RESULTS_DIR IS_AREA_SITE_CLUBBED
    
    dontWriteExcel = 0;
    if nargin < 4 
        dontWriteExcel = 1;
    end
    showNextDays = NO_INSTANCES;
    szPredata = numel(preddata);
    
    predLastDate = numel(preddata(1).rcaInstant);

    i = predLastDate + (1:showNextDays); 
    
    if ~dontWriteExcel
        bts_rca_string1 = {'BTS_RCA_Combination',{''}};
    end
    bts_rca_string2 = {'BTS_RCA_Combination'};

    for j = 1:szPredata
        if ~isempty(find(preddata(j).Pred1(i-predLastDate) > 0) > 0)
            if IS_AREA_SITE_CLUBBED
                val = preddata(j).site;
                sepVal = textscan(val,'%s','Delimiter','()');
                site = char(sepVal{1}(2));
            else
                site = preddata(j).site;
            end
            str = sprintf('%s, %s',site, preddata(j).rca);
            bts_rca_string2 = [bts_rca_string2; {str}];
            if ~dontWriteExcel
                str1 = int2str(preddata(j).rcaInstant);
                str2 = sprintf('%s, %s',preddata(j).site, preddata(j).rca);
                bts_rca_string1 = [bts_rca_string1; {str2, str1}];
            end
        end
    end
    instancePredicted = length(bts_rca_string2) -1;

    if toWrite
        if exist([RESULTS_DIR inFile],'file')
            delete([RESULTS_DIR inFile]);
        end
        
        predicted = convertstr2cell(bts_rca_string2, instancePredicted, 1);
        predictedInfo = cell2dataset(predicted);
        export(predictedInfo,'file',[RESULTS_DIR inFile],'delimiter',',');
        if ~dontWriteExcel
            if exist([RESULTS_DIR inFile1],'file')
                delete([RESULTS_DIR inFile1]);
            end
            xlswrite([RESULTS_DIR inFile1],bts_rca_string1,'Predicted+Instance');
        end
    end
end 
