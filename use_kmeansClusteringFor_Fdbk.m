function fdbk = use_kmeansClusteringFor_Fdbk(indata)

    data = indata;
    % load ctr
    load('Data\20Clusters_Len_Quantile_Fdbk.mat');
    alllen = length(data);
    len = length(find(data(1,:) > 0));
    ind = uint8((alllen/3)-0.5);
%     dv1 = length(find(data(1:ind) > 0));
%     dv2 = length(find(data(ind+1:2*ind) > 0));
    dv3 = length(find(data((2*ind)+1:alllen) > 0));
    lastQ = dv3/len;
    
    D(:,1) = sqrt(((ctr(:,1) - len) .^ 2) + ((ctr(:,2) - lastQ) .^ 2));
    [~,indx] = sort(D,'ascend');
    fdbk = double(uint8(ctr(indx(1),3)));
end