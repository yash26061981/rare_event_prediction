function show_trend(nameIp, dataIp, includeHeader)
    global FIG_DIR
    
    [r,~] = size(nameIp);
    [~,c] = size(str2num(dataIp{2}));
    divP = 4;
    rmd = rem(c,divP);
    perQ = uint8((c/divP) - 0.5);
    
    if includeHeader
        st = 2;
        dfig = zeros(r-1,divP);
        nfig = cell(r-1,1);
    else
        st = 1;
        dfig = zeros(r,divP);
        nfig = cell(r,1);
    end

%     figure
    for i = st: r
        for j = 1:divP
            ind2add = (j-1)*perQ;
            perQ1 = perQ;
            if j == divP
                perQ1 = perQ + rmd; 
            end
            for k = 1: perQ1
                indx = ind2add + k;
                data = str2num(dataIp{i});
                if data(indx) == 1
                    dfig(i-1,j) = dfig(i-1,j) + 1;
                end
            end
        end
        nfig{i-1} = nameIp{i};
        figure
        plot(dfig(i-1,:)); title(nfig{i-1});
        f1n = sprintf('trend_%d.jpg',i-1);
        saveas(gcf, [FIG_DIR f1n]);
    end    
end