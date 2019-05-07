function nextInst = applyNonLinearARNeuralNetwork_outasFdbk(inData,indx)
    global NO_INSTANCES FDBK_DELAYS HIDDEN_LAYERS;
    
    Y = inData(indx,:);
    T= tonndata(Y,true,false);
    trainFcn = 'trainlm';  % Levenberg-Marquardt
    feedbackDelays = 1:2;
    hiddenLayerSize = 10;
    net = narnet(feedbackDelays,hiddenLayerSize,'open',trainFcn);
%     net.input.processFcns = {'removeconstantrows','mapminmax'};
    [x,xi,ai,t] = preparets(net,{},{},T);
    net.divideParam.trainRatio = 0.78;
    net.divideParam.valRatio = 0.22;
    net.divideParam.testRatio = 0;
    net.trainParam.showWindow = false;
    net.performFcn = 'mse';  % Mean squared error
    % Train the Network
    [net, ~, Ys, ~, Xf, Af ] = train(net,x,t,xi,ai,'useParallel','no');
    y = net(x,xi,ai);
    
    Xnew = Ys; Xinew = Xf; Ainew = Af; Ypred = {[]};
    for i=1:NO_INSTANCES
       [Ynew, Xfnew, Afnew] = net(Xnew,Xinew,Ainew);
       Ypred = [Ypred Ynew ];
       Xnew = Ynew; Xinew = Xfnew; Ainew = Afnew;
    end
    nextInst = cell2mat(Ypred);
end