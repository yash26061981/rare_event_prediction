function outCell = convertstr2cell(instr, len, skip)
%     outCell = cell(len,1);
    outCell = [{'Site'},{'RCA'}];
    for k = 1:len
        str = instr{skip+k};
        str1 = cell(1,2);
        strcell = textscan(str,'%s','Delimiter',',','EmptyValue',-Inf);
        str1{1} = char(strcell{1}(1));
        str1{2} = char(strcell{1}(2));
        outCell = [outCell;str1];
    end
end