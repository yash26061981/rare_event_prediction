function emptyCount = checkIf_NaN_or_Empty(data)
    value = data;
    emptyCount = 0;
    
    if iscell(value)
        if isempty(value{1})
            emptyCount = 1;
        elseif isnan(value{1})
            emptyCount = 1;
        end
    else
        if isempty(value)
            emptyCount = 1;
        elseif isnan(value)
            emptyCount = 1;
        end
    end
    if ~emptyCount
        value = uint8(data{1});
        valU = unique(value);
        if length(valU) == 1
            if valU == 32
                emptyCount = 1;
            end
        end
    end
end