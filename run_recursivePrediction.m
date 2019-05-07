function run_recursivePrediction
    dateofip = {'27092015','23092015','19092015','15092015','11092015','07092015'}; len = '_len_04';
%     dateofip = {'28102015','24102015','20102015','16102015','12102015','08102015'}; len = '_len_08';
    for indx = 1:6
        InputData4_NN(dateofip{1,indx},len);
%        predict_CVData_48Hours(indx);
    end
end