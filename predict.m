function predicted = predict(AnalysedData)
    global NO_INSTANCES;
    instance = NO_INSTANCES;
    
    dataSz = numel(AnalysedData.Info);
    h = waitbar(0,'Please wait...');
    PredictedInstances = repmat(struct('area','IN','site','IN','rca','IN',...
        'rcaInstant',[],'Pred1',zeros(1,instance)),1,dataSz);
    total = 0;    
    for i = 1: dataSz
        areaName = AnalysedData.Info(i).area;
        siteInfo = AnalysedData.Info(i).site;
        siteName = siteInfo.name;
        rcaInfo = siteInfo.rca;
        rcaSz = numel(rcaInfo);
        data = siteInfo.bitStream;
        for j = 1:rcaSz
            next = applyNonLinearARNeuralNetwork_RecTraining(data,j);
%             next = applyNonLinearARNeuralNetwork_outasFdbk(data,j);
            [~,szC] = size(next);
            if szC ~= 0
                total = total +1;
                PredictedInstances(total).area = areaName;
                PredictedInstances(total).site = siteName;
                PredictedInstances(total).rca = rcaInfo(j).name;
                PredictedInstances(total).rcaInstant = siteInfo.bitStream(j,:);

                for k = 1:instance
                    bits1 = next(:,k);
%                         [~,bits1] = getByte_BitStream(rcaSz,next(k),1);
                    PredictedInstances(total).Pred1(k) = uint8(bits1);
                end                
            end
        end
        waitbar(i/dataSz,h)
    end
    delete(h)
    if total < dataSz
        PredictedInstances((dataSz+1) : total) = [];
    end
    predicted = PredictedInstances;
end