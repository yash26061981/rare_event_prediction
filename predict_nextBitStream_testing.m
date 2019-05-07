function predicted = predict_nextBitStream_testing(AnalysedData)
        
    dataSz = numel(AnalysedData.Info);
    
    PredictedInstances = [];
    total = 1;

    for i = 1: dataSz
        areaName = AnalysedData.Info(i).area;
        siteInfo = AnalysedData.Info(i).site;
        siteName = siteInfo.name;
        rcaInfo = siteInfo.rca;
        rcaSz = numel(rcaInfo);
        for j = 1:rcaSz
            PredictedInstances(total).area = areaName;
            PredictedInstances(total).site = siteName;
            PredictedInstances(total).rca = rcaInfo(j).name;
            PredictedInstances(total).rcaInstant = siteInfo.bitStream(j,:);
            total = total +1;
        end
    end
    predicted = PredictedInstances;
end