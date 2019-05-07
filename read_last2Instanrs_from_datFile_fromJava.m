function pdata = read_last2Instanrs_from_datFile_fromJava(javafile)
    global RESULTS_DIR USE_SUB_RCA
    club_data = 1;
    ifid = fopen([RESULTS_DIR javafile],'r');
    if club_data
        pdata = [{'Site_RCA'}];
    else
        adata = [{'Site'},{'RCA'}];
        pdata = [{'Site_RCA'}];
    end
    delim1 = ':';
    delim2 = ',|';
    while 1
        tline = fgets(ifid);
        if tline == -1
            break;
        end
        deline = textscan(tline,'%s%s', 'Delimiter', delim1);
        if USE_SUB_RCA
            siteRcaline = textscan(char(deline{1,1}(1)),'%s%s%s', 'Delimiter', delim2);
        else
            siteRcaline = textscan(char(deline{1,1}(1)),'%s%s', 'Delimiter', delim2);
        end
        instances = str2num(char(deline{1,2}(1)));
        if (instances(1,end) == 1) || (instances(1,end-1) == 1)
            if club_data
                if USE_SUB_RCA
                    str = sprintf('%s,%s<%s>',char(siteRcaline{1,1}),char(siteRcaline{1,2}),...
                        char(siteRcaline{1,3}));
                else
                    str = sprintf('%s,%s',char(siteRcaline{1,1}),char(siteRcaline{1,2}));
                end
                pdata = [pdata;{str}];
            else
                adata = [adata;siteRcaline{1,1},siteRcaline{1,2}];
%                 pdata = adata;
            end
        end        
    end
    
    if ~club_data
        infraRCA = {'Indus Shared Site Power Issue', 'Non Indus and Infratel Shared Site-Power Issue',...
            'Mains Fail No Power Backup', 'No Fuel'};
        aRCA = adata(:,2);
        [irca] = ismember(aRCA, infraRCA);
        adata(irca,:) = [];
        for k = 2: length(adata)
            str = sprintf('%s,%s',char(adata{k,1}),char(adata{k,2}));
            pdata = [pdata;{str}];
        end
        
    end   
end
