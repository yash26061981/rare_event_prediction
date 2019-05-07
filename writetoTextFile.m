function writetoTextFile(data2write,ifile)
    global RESULTS_DIR;
    ifid = fopen([RESULTS_DIR ifile],'w');
    
    [r,c] = size(data2write);        
    for k = 1: r
        key = char(data2write(k,1));
        if c > 1
            fprintf(ifid,'%s: ',key);
            ival = data2write{k,2};
            sz = max(size(ival));
            for m = 1:sz
                iv = ival(m);
                if m == sz
                    fprintf(ifid,'%d\n',iv);
                else
                    fprintf(ifid,'%d ',iv);
                end
            end
        else
            fprintf(ifid,'%s\n',key);
        end
    end    
    fclose(ifid);
end