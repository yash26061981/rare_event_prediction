function [result,meanStats,stdStats] = run_test_to_check_randomness(instances, test)
    global SIGMOID_MIDPOINT CURVE_MAXVAL CURVE_STEEPNESS W1 W0 
    %ipSeqchar = '1  0  0  0  1  1  1  0  1  0  0  0  1  0  0  0  1  1  1  0  0  0  1  1  1  1  1  1  1  1  1  1  1  1  1  1  0  1  1  1  1  0  1  0  1  0  1  1  1  1';
%     ipSeqchar = '0 0 1 1 0 1 0 0 0 0 1 0 0 1 1 1 1 1 0 0';
%     load('lew_data.mat');
%     instances = zeros(length(data),1);
%     for k = 1:length(data)
%         if data(k) > 0
%             instances(k) = 1;
%         end
%     end
%     ipSeqchar = '0  0  0  0  0  0  0  0  0  0  1  1  0  0  0  0  1  1  0  0  0  0  0  0  0  0  0  0  1  0  1  1  1  0  0  0  0  0  1  0  0  1  0  0  0  0  0  0  0  0';
%     instances = str2num(char(ipSeqchar));
%     instances = '1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1';%'0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1'
    SIGMOID_MIDPOINT = 0.1;
    CURVE_MAXVAL = 1;
    CURVE_STEEPNESS = 30;
    W1 = 0.5;
    W0 = 0.5; 

    if ~(isnumeric(instances))
        instances = str2num(instances);
    end
    
    
    switch test
        case 'BRADLEY_RUN_TEST'
            pos = 1; neg = 0;
            clubInstpos = get_clubbed_one_zeros(instances, pos);
            clubInstneg = get_clubbed_one_zeros(instances, neg);
            totalRun = length(clubInstneg) + length(clubInstpos);
            n1pos = sum(clubInstpos);
            n2neg = sum(clubInstneg);
            mpos = mean(clubInstpos); mneg = mean(clubInstneg);
            stdpos = std(clubInstpos); stdneg = std(clubInstneg);
            meanStats = [mpos, mneg];
            stdStats = [stdpos, stdneg];
            
            runmean = ((2*n1pos*n2neg)/(n1pos + n2neg)) + 1;
            numerator = ((2*n1pos*n2neg)*((2*n1pos*n2neg)-n1pos - n2neg));
            denominator = power((n1pos+n2neg),2) *(n1pos + n2neg - 1);
            sdmean2 = sqrt(numerator/denominator);

            testStat_Z =  (totalRun - runmean)/sdmean2;
    
            alpha = 0.1;
            pval = 1-(alpha/2);

            p = [0.999	0.995	0.990	0.975	0.950	0.900];
            Zp = [3.090 2.576	2.326	1.960	1.645	1.282];

            [~, val] = find(ismember(p,pval) > 0);
            zval = Zp(val);
    
            if abs(testStat_Z) > zval
                result = false; 
                % this means that reject H0:  the sequence was produced in a random
                % manner. Or we can say that sequence is not randomly generated and
                % we can fit some distribution on this sequence.
            else
                result = true;
                % this means that reject Ha:  the sequence was not produced in a
                % random manner. Or we can say that sequence is randomly generated 
                % and we can not fit any distribution on this sequence.
            end
            
        case 'TOPOLOGICAL_BINARY_TEST'
            non_overlapping_block_length = 8;
            k_partitioned = fix(numel(instances)/non_overlapping_block_length);
            
        case 'REGULARITY_INDEX_TEST'
            % to check number of runs and run uniformity
            SIGMOID_MIDPOINT = 0.1;
            CURVE_MAXVAL = 1;
            CURVE_STEEPNESS = 30;
            W1 = 0.5;
            W0 = 0.5; 
            pos = 1; neg = 0;
            clubInstpos = get_clubbed_one_zeros(instances, pos);
            clubInstneg = get_clubbed_one_zeros(instances, neg);
            clubInstneg(1:end-1) = clubInstneg(2:end);
            clubInstneg(end) = [];
            totalRun = length(clubInstneg) + length(clubInstpos);
            
            mpos = mean(clubInstpos); mneg = mean(clubInstneg);
            stdpos = std(clubInstpos); stdneg = std(clubInstneg);
            meanStats = [mpos, mneg];
            stdStats = [stdpos, stdneg];
            
            runs_Stats = (totalRun - 1)/(length(instances) - 1);
            expval = CURVE_STEEPNESS * (runs_Stats - SIGMOID_MIDPOINT);
            logistic_val = CURVE_MAXVAL /(1 + exp(-expval));
            
            run_uniformity = W0 * (stdneg/mneg);% + W1 * (stdpos/mpos);
            
            regularityIndx = run_uniformity*logistic_val;
            result = [regularityIndx,logistic_val,run_uniformity];            
            
        otherwise
            result = 'NA';
    end
end