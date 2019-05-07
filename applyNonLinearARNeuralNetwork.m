function nextInst = applyNonLinearARNeuralNetwork(inData,indx)
    global FDBK_DELAYS HIDDEN_LAYERS INTERPOLATE_DATA APPLY_RULE;
    if INTERPOLATE_DATA
        Y = applySplineInterpolation(inData);
    else
        Y = inData;
    end
    fdbk_new = FDBK_DELAYS;
    if APPLY_RULE
        fdbk_new = use_kmeansClusteringFor_Fdbk(Y,indx);
    end
    fdbk = 1:fdbk_new;
    
    net_ar = narnet(fdbk,HIDDEN_LAYERS);
    net_ar.trainParam.showWindow = false;
    net_ar.trainParam.epochs = 100000;
    T = tonndata(Y,true,false);
    [Xs,Xi,Ai,Ts] = preparets(net_ar,{},{},T);
    net_ar = train(net_ar,Xs,Ts,Xi,Ai);
%     net_ar = removedelay(net_ar,IP_DELAYS);
%     net_ar.trainParam.epochs
    net_ar_closed = closeloop(net_ar);
    samples = fdbk_new;
    
    Y1 = Y(:,(end-samples:end));
    Y1 = tonndata(Y1,true,false);

    [xc,xic,aic,~] = preparets(net_ar_closed,{},{},Y1);
    Ypred =  net_ar_closed(xc,xic,aic);

    nextInst = cell2mat(Ypred);
end