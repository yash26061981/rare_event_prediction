function AnalysedData_TimeSplitted = splitforCrossValidation(AnalysedData)
    
    areaSz = numel(AnalysedData);
    for areaId = 1: areaSz
        siteSz = numel(AnalysedData(areaId).Site);
        for siteId = 1:siteSz
            rcaSz = numel(AnalysedData(areaId).Site(siteId).RCA);
            for rcaId = 1: rcaSz
                rcaInfo = AnalysedData(areaId).Site(siteId).RCA(rcaId).instance;
                [newInstances, ~] = removeInstancesAfterDate(rcaInfo);
                AnalysedData(areaId).Site(siteId).RCA(rcaId).instance = newInstances;
            end
        end
    end 
    AnalysedData_TimeSplitted = AnalysedData;
end