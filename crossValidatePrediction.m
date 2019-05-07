function crossValidatePrediction
    global RESULTS_DIR
    RESULTS_DIR = 'D:\Prediction_Project\Ericsson_Prediction\InputRawFiles\';
    inFile1 = 'predicted_faults_29-01-2016 to 01-02-2016.xls';
    inFile2 = '2ndFeb';
    outFile = ['crossValidated_' inFile2 '.dat'];
    
    
    [~,~,pData] = xlsread([RESULTS_DIR inFile1],'Sheet0');
    
    inData = read_last2Instanrs_from_datFile_fromJava([RESULTS_DIR inFile2 '.dat']);
    
    predictedData = pData(3:end,:);
    actualData = inData(2:end,:);
    
    %%%exclude infra
    infraRCA = {'Indus Shared Site Power Issue', 'Non Indus and Infratel Shared Site-Power Issue',...
        'Mains Fail No Power Backup', 'No Fuel'};
    aRCA = actualData(:,2);
    [irca] = ismember(aRCA, infraRCA);
    actualData(irca,:) = [];
    
    %%%%%%%
    
    
    pkey = cell(length(predictedData),1);
    for k = 1:length(predictedData)
        pkey{k} = sprintf('%s,%s',predictedData{k,1},predictedData{k,2});
    end
    akey = cell(length(actualData),1);
    for k = 1:length(actualData)
        akey{k} = sprintf('%s,%s',actualData{k,1},actualData{k,2});
    end
    [i1, ~] = ismember(pkey,akey);
    predlength = length(pkey);
    pkey(~i1) = [];
    writetoTextFile(pkey,outFile);
    str1 = sprintf('\t\t------- Statistics of %s ------------',inFile1);
    str2 = sprintf('       Isntances happened = %d',length(akey));
    str3 = sprintf('      Predicted Isntances = %d',predlength);
    str4 = sprintf('        Matched Isntances = %d',length(pkey));
    str5 = sprintf('\n        Recall  = %2.2f%%',(length(pkey)/length(akey))*100);
    str6 = sprintf('     Precision  = %2.2f%%\n\n',(length(pkey)/predlength)*100);
    disp(str1);
    disp(str2);
    disp(str3);
    disp(str4);
    disp(str5);
    disp(str6);
   
end