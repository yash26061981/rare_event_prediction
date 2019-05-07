function predicted = predict_byte_bits_Narnet(AnalysedData)
    global NO_INSTANCES USE_DUAL_NARNET USE_ONLY_BYTE_PRED;
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
        
        if USE_ONLY_BYTE_PRED
            [bytes,~] = getByte_BitStream(rcaSz,siteInfo.bitStream,0);
            nextByte = applyNonLinearARNeuralNetwork_RecTraining(bytes,1);
            pbits = zeros(rcaSz,instance);
            for k = 1:instance
                [~, pbits(1:rcaSz,k)] = getByte_BitStream(rcaSz,nextByte(k),1);
            end   
            for j = 1:rcaSz
                total = total +1;
                PredictedInstances(total).area = areaName;
                PredictedInstances(total).site = siteName;
                PredictedInstances(total).rca = rcaInfo(j).name;
                PredictedInstances(total).rcaInstant = siteInfo.bitStream(j,:);

                for k = 1:instance
                    bitp = uint8(pbits(j,k));
                    PredictedInstances(total).Pred1(k) = bitp;
                end
            end            
        else
            if USE_DUAL_NARNET
                [bytes,~] = getByte_BitStream(rcaSz,siteInfo.bitStream,0);
                nextByte = applyNonLinearARNeuralNetwork_RecTraining(bytes,1);
                pbits = zeros(rcaSz,instance);
                for k = 1:instance
                    [~, pbits(1:rcaSz,k)] = getByte_BitStream(rcaSz,nextByte(k),1);
                end   
            end

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
                        if USE_DUAL_NARNET
                            bitp = or(uint8(pbits(j,k)), uint8(next(:,k)));
                        else
                            bitp = uint8(next(:,k));
                        end
                        PredictedInstances(total).Pred1(k) = bitp;
                    end                
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