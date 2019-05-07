function outdata = remove_faulttype_from_data(indata,faultType)
    outdata = indata;
    header = (outdata(1,:))';
    idx = cellfun(@(x) all(isnan(x)),header);
    ii1=all(idx,2);
    header(ii1,:)={'NaN'};
    indx = findIndx(header', 'RCA');
    if indx ~= -1
        keydata = outdata(:,indx);
        [i1,~] = ismember(keydata,faultType);
    else
        key = outdata(:,1);
        keysz = numel(key);
        keydata = cell(keysz,1);
        keydata{1} = 'RCA';
        for k = 2:keysz
            val = char(key(k));
            sepVal = textscan(val,'%s','Delimiter',',');
            keydata{k} = char(sepVal{1}(2));
        end
        [i1,~] = ismember(keydata,faultType);
    end
    
    outdata(i1,:) = [];

end