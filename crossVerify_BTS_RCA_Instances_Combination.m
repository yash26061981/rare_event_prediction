function crossVerify_BTS_RCA_Instances_Combination()
    load('D:\AreaWiseDetails\Predicted_Data_48Hours_Optimised\Data\analysed_Actual_BTS_RCA_Combination.mat');
    sz = numel(actdata);
    comb = [{'Site'}, {'RCA'}, {'Total_Instances'}];
    for k = 1:sz
        data = actdata(k);
        len = int2str(length(find(data.rcaInstant(1,:) > 0)));
%         str = sprintf('%s - [%s] - Instances = %d',data.site, data.rca, len);
        comb = [comb ; {data.site},{data.rca},{len}];        
    end
    xlswrite('bts_rca_instances.xlsx',comb,1);

end