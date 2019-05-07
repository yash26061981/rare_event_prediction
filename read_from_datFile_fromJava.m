function pdata = read_from_datFile_fromJava(javafile)
    global RESULTS_DIR USE_SUB_RCA
    
    ifid = fopen([RESULTS_DIR javafile],'r');
    pdata = [{'Site_RCA'},{'Instances'}];
    while 1
        tline = fgets(ifid);
        if tline == -1
            break;
        end
        deline = textscan(tline,'%s%s%s', 'Delimiter', ':');
        if USE_SUB_RCA
            siteRcaline = textscan(char(deline{1,2}(1)),'%s%s%s', 'Delimiter', '|');
            str = sprintf('%s,%s<%s>',char(siteRcaline{1,1}),char(siteRcaline{1,2}),...
                char(siteRcaline{1,3}));
        else
            siteRcaline = textscan(char(deline{1,2}(1)),'%s%s', 'Delimiter', '|');
            str = sprintf('%s,%s',char(siteRcaline{1,1}),char(siteRcaline{1,2}));
        end
        pdata = [pdata;str,deline{end}(1)];
    end
    pdata(end,:) = [];
end
