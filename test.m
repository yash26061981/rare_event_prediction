function test()
    global RESULTS_DIR;
    RESULTS_DIR = [pwd, '\Results\'];
    
    dateofip = '28102015'; 
    len = '_len_08';
    rca_to_analyse = 'StatisticalAnalysis';
    total_line = 1469;
        
    fileToRead = [dateofip len '\predicted_pre_filter_10_percent_' dateofip '.dat'];
%     rcaFile = [dateofip len '\' rca_to_analyse '.dat'];
    rcaexcelFile = [dateofip len '\' rca_to_analyse '_pre_filter_10_percent.xlsx'];
    
%     RESULT = dlmread([RESULTS_DIR fileToRead],'\n');
%     rcaIndx = 0;
    
    ifid = fopen([RESULTS_DIR fileToRead],'r');
    tests = {'BRADLEY_RUN_TEST', 'REGULARITY_INDEX_TEST'};
    runtest = 2;
    if runtest == 1
        rca_runtest = [{'Site_RCA'},{'Instances'},{'RunTest_Result'},...
            {'Ones_Stats_Mean'}, {'Ones_Stats_Std'},...
            {'Zeros_Stats_Mean'}, {'Zeros_Stats_Std'}];
    else
        rca_runtest = [{'Site_RCA'},{'Instances'},{'RegularityIndx'},...
            {'RunStats'},{'RunUniformity'},{'Ones_Stats_Mean'}, {'Ones_Stats_Std'},...
            {'Zeros_Stats_Mean'}, {'Zeros_Stats_Std'}];
    end
    
    while 1
        tline = fgets(ifid);
        if tline == -1
            break;
        end
        deline = textscan(tline,'%s%s%s%s%s', 'Delimiter', ':,');
        str = sprintf('%s, %s',deline{1,3}{1},deline{1,4}{1});
        [result,meanStats,stdStats] = run_test_to_check_randomness(deline{1,5}{1}, tests{runtest});
        if runtest == 1
            if result % i.e true, i.e. reject H0:  the sequence was produced in a random manner
                str1 = 'Non-Random';
            else
                str1 = 'Random';
            end
            pos_str_mean = sprintf('%f',meanStats(1));
            pos_str_std = sprintf('%f',stdStats(1));
            neg_str_mean = sprintf('%f',meanStats(2));
            neg_str_std = sprintf('%f',stdStats(2));
            rca_runtest = [rca_runtest;{str},deline{1,5},...
                {str1},{pos_str_mean},{pos_str_std},{neg_str_mean},{neg_str_std}];
        else
            str1 = sprintf('%f',result(1));
            str2 = sprintf('%f',result(2));
            str3 = sprintf('%f',result(3));
            pos_str_mean = sprintf('%f',meanStats(1));
            pos_str_std = sprintf('%f',stdStats(1));
            neg_str_mean = sprintf('%f',meanStats(2));
            neg_str_std = sprintf('%f',stdStats(2));
            rca_runtest = [rca_runtest;{str},deline{1,5},{str1},...
            {str2},{str3},{pos_str_mean},{pos_str_std},{neg_str_mean},{neg_str_std}];
        end
    end
    xlswrite([RESULTS_DIR rcaexcelFile],rca_runtest,1);
        

% data = [0  0  0  0  0  0  0  0  0  0  0  0  0  1  1  1  1  1  1  1  0  0  0  0  0  0  1  1  1  1  1  1  0  1  0  1  0  1  0  0  1  0  1  1
% ];
%     
% r1 = 5; c1 = 10;
% im = zeros(r1,c1);
% data(end:(r1*c1)) = 0.5;
% for r = 1:r1
%     for c=1:c1
%         im(r,c) = data((r-1)*c1 + c);
%     end
% end
% imshow(im)
% 
% fileToRead = 'TCTS Dash board dump from AUG-15 to OCT-15.xlsx';%'AreaWiseDetails.xlsx';
% pathToAdd = 'D:\TCTS_Data\';
% file = [pathToAdd, fileToRead];
% [~, ~ , alldata] = xlsread(file);
% togive = [{'RCA'}, {'REMEDY CODE'}];
% headers = alldata(1,:);
% 
% indxtouse1 = findIndx(headers, togive{1});
% indxtouse2 = findIndx(headers, togive{2});
% 
% data1 = alldata(2:end,indxtouse1);
% data2 = alldata(2:end,indxtouse2);
% 
% idx = cellfun(@(x) all(isnan(x)),data1);
% ii=all(idx,2);
% data1(ii,:)={'NaN'};
% idx = cellfun(@(x) all(isnan(x)),data2);
% ii=all(idx,2);
% data2(ii,:)={'NaN'};
% str1 = {'RCA_REMEDYCODE'};
%  for i = 1:length(data1)
%      str2 = sprintf('%s,%s',data1{i},data2{i});
%      str1 = [str1; {str2}];    
%  end
%  u = unique(str1);
%  pInfo = cell2dataset(u);
%  export(pInfo,'file','ported.dat','delimiter',',');

end