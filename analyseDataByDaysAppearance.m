function [AnalyseData,AnalyseData_splitted]  = analyseDataByDaysAppearance(AnalysedData, adddaystopredict, getActual)
    global MIN_REQ_LEN TOTAL_DAYS;
    areaSz = numel(AnalysedData);
    minLen = MIN_REQ_LEN;
    if getActual
        minLen = 1;
    end
    
    areaStruct = [];
    if ~getActual
        areaStruct_splitted = [];
    end
    total = 1;
    for areaId = 1: areaSz
        areaName = AnalysedData(areaId).name;
        siteSz = numel(AnalysedData(areaId).Site);
        for siteId = 1:siteSz
            siteName = AnalysedData(areaId).Site(siteId).name;
            rcaSz = numel(AnalysedData(areaId).Site(siteId).RCA);
            siteStruct = [];
            siteStruct.name = siteName;
            if ~getActual
                siteStruct_splitted = [];
                siteStruct_splitted.name = siteName;
            end
            rcaIndx = 1; rcaPresent = 0;
            for rcaId = 1: rcaSz
                rcaName = AnalysedData(areaId).Site(siteId).RCA(rcaId).name;
                rcaInfo = AnalysedData(areaId).Site(siteId).RCA(rcaId).instance;
                if ~isempty(rcaInfo) %&& (numel(rcaInfo)> minLen)
                    bitStream = getdaysGapBitStream(rcaInfo,adddaystopredict);
                    if getActual
                        bitLen = length(find(bitStream(:) > 0));
                    else
                        bitLen = length(find(bitStream(1:TOTAL_DAYS) > 0));
                    end
                    if bitLen >= minLen
                        siteStruct.rca(rcaIndx).name = rcaName;
                        siteStruct.bitStream(rcaIndx,:) = bitStream;
                        if ~getActual
                            siteStruct_splitted.rca(rcaIndx).name = rcaName;
                            siteStruct_splitted.bitStream(rcaIndx,:) = bitStream(1:TOTAL_DAYS);
                        end
                        
                        rcaIndx = rcaIndx + 1;
                        rcaPresent = 1;
                    end
                end
            end
            if rcaPresent
                areaStruct.Info(total).site = siteStruct;
                areaStruct.Info(total).area = areaName;
                if ~getActual
                    areaStruct_splitted.Info(total).site = siteStruct_splitted;
                    areaStruct_splitted.Info(total).area = areaName;
                end
                
                total = total+1;
            end
        end
    end 
    AnalyseData = areaStruct;
    if ~getActual
        AnalyseData_splitted = areaStruct_splitted;
    else
        AnalyseData_splitted = [];
    end
        
    
end