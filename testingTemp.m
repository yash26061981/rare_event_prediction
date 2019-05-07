function testingTemp(touse)
    global FDBK_DELAYS HIDDEN_LAYERS INTERPOLATE_DATA APPLY_RULE SAMPLES;
    HIDDEN_LAYERS = 35;
    INTERPOLATE_DATA = 1;
    APPLY_RULE = 0; SAMPLES = 10;
    
%     touse = 4;
    switch touse
        case 1
            load('Data\analysed_30_08_forMonths_3.mat');
            happenedWithReq = predict_nextBitStream_testing(AnalyseData);
            sz = numel(happenedWithReq);
            bts_rca_string1 = [{'BTS_RCA_Combination1'},{''},{''}]; 
            for j = 1 : sz
                str = sprintf('%s, %s',happenedWithReq(j).site, happenedWithReq(j).rca);
                str1 = int2str(happenedWithReq(j).rcaInstant(1,:));
                len = (length(find(happenedWithReq(j).rcaInstant(1,:) > 0)));
                str2 = sprintf('len = %d', len);
                bts_rca_string1 = [bts_rca_string1; {str},{str1},{str2}];
            end
            xlswrite('allInst_grt8_3Months_ClubDays1',bts_rca_string1,1);
            
        case 2
            filedir = [pwd '\Results_ClubDays2\'];
            [~, ~, alldata] = xlsread([filedir 'predict_30102015_len_10_forMonths_6.xlsx'],'ActualInstance+Instance');
            data = alldata(2:end,:);
            [r,~] = size(data);
            datain = repmat(struct('key','IN','dvect',[],'len',0,'result',0,...
                'fdbk',[],'narResult',[]), r,1);
    %         lenvect = zeros(1,r); 
            indx =1;
            for k = 1:r
                dvector = str2num(data{k,2});
                dvec = dvector(1,1:end-1);
                lenvec = length(find(dvec>0));
                if lenvec > 0
                    datain(indx).key = data{k,1};
                    datain(indx).dvect = dvec;
                    datain(indx).result = dvector(1,end);
                    datain(indx).len = lenvec;
    %                 lenvect(indx) = lenvec;
                    indx = indx +1;
                end
            end
            datain(indx:end) = []; 
    %         lenvect(indx:end) = [];
    %         [cid,ctr] = kmeans(lenvect, 6);
            stfdbk = 10; edfdbk = 40; TOP_RES = 10;
%             h = waitbar(0,'Please wait...');
            for i = 1:indx-1
                ind1 = 1;
                nextInst = zeros(1,length(stfdbk:edfdbk));fdbk = zeros(1,length(stfdbk:edfdbk));
                for k = stfdbk:edfdbk
                    FDBK_DELAYS = k;
%                     next_sam = applyNonLinearARNeuralNetwork(datain(i).dvect,1);
                    e = NARNet_test(datain(i).dvect, k);
                    [szR1,szC1] = size(e);
                    if (szC1 ~= 0 && szR1 ~= 0)
                        nextInst(ind1) = e;
                        fdbk(ind1) = k;
                        ind1 = ind1 +1;
                    end
                end
                [val1,id1] = sort(nextInst,'descend');

                topVal1 = zeros(1,TOP_RES); 
                topFdbk = zeros(1,TOP_RES);
                for k = 1:TOP_RES
                    topVal1(k) = val1(k);
                    topFdbk(k) = fdbk(id1(k));
                end
                datain(i).fdbk = topFdbk;
                datain(i).narResult = topVal1;
%                 waitbar(i/(indx-1),h)
            end
%             delete(h); 
            save('Data\2NarnetResult_30102015_len_10_forMonths_6.mat','datain');
%             load('Data\2NarnetResult_30102015_len_10_forMonths_6.mat');
            sz = numel(datain);
            for k = 1:sz
                data = datain(k);
                dv1 = data.dvect(1:30);
                dv2 = data.dvect(31:60);
                dv3 = data.dvect(61:end);
                dv1q = length(find(dv1(1,:)>0));
                dv2q = length(find(dv2(1,:)>0));
                dv3q = length(find(dv3(1,:)>0));
                len = dv1q + dv2q + dv3q;
                dat(k).key = data.key;
                dat(k).dvect = data.dvect;
                dat(k).len = data.len;
                dat(k).result = data.result;
                dat(k).fdbk = data.fdbk;
                dat(k).narResult = data.narResult;
                dat(k).quantileLen = [dv1q, dv2q, dv3q];
                dat(k).PercentquantileLen = [dv1q/len, dv2q/len, dv3q/len];
            end
            save('Data\NarnetResult_Quantile_30102015_len_10_forMonths_6.mat','dat');
            
            
        case 3
            load('Data\NarnetResult_Quantile_30102015_len_10_forMonths_6.mat');
            sz = numel(dat);
            X = zeros(sz,3);
            for k = 1 :sz
               data = dat(k);
               X(k,1) = data.len ;
               X(k,2) = data.PercentquantileLen(3);
               X(k,3) = data.fdbk(1);
            end
            
            [~,ctr] = kmeans(X, 20);
            save('Data\kmeans_30102015_len_10_forMonths_6.mat','ctr');
        otherwise
            disp('Unknown method.');
    end
end