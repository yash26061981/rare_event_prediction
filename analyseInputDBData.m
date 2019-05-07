function analyseInputDBData
    global RESULTS_DIR
    RESULTS_DIR = ['D:\Prediction_Project\Ericsson_Prediction\MatlabCode\Results\'...
                    'JavaCodeCrossValidation\01022016\testcases\'];
    
    inFile2 = 'input_10Feb_Len1';%'input';
    outFile = ['analysed_' inFile2 '.xlsx'];
    ifid = fopen([RESULTS_DIR inFile2 '.dat'],'r');
    pdata = [{'Site'},{'RCA'},{'Instances'},{'No_ofOccurences'},{'Last2Days'}];
    while 1
        tline = fgets(ifid);
        if tline == -1
            break;
        end
        
        deline = textscan(tline,'%s%s', 'Delimiter', ':');
        siteRcaline = textscan(char(deline{1,1}(1)),'%s%s', 'Delimiter', ',');
        instances = str2num(char(deline{1,2}(1)));
        sumInst = sum(instances);
        if sumInst ~= 0
            str = sprintf('%d',sumInst);
            str1 = sprintf('%d',(instances(1,end)+instances(1,(end-1))));
            pdata = [pdata;siteRcaline{1,1}(1),siteRcaline{1,2}(1), deline{1,2},{str},{str1}];
        end 
        
    end
    xlswrite([RESULTS_DIR outFile],pdata,1);
end