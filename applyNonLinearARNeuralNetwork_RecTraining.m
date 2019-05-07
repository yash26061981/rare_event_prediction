function nextInst = applyNonLinearARNeuralNetwork_RecTraining(inData,indx)
    global FDBK_DELAYS INTERPOLATE_DATA APPLY_K_MEANS_RULE...
        MAX_ITERATION ERR_LIMIT NO_INSTANCES HIDDEN_LAYERS;
    
    if INTERPOLATE_DATA
        Y = applySplineInterpolation(inData(indx,:));
    else
        Y = inData(indx,:);
    end
    fdbk = FDBK_DELAYS;
    if APPLY_K_MEANS_RULE
        fdbk = use_kmeansClusteringFor_Fdbk(Y);
    end
    iter = 1;
    err = 1;
    len = length(Y);
    % data settings
    N  = fix(0.8 * len); % number of samples
    % prepare training data
    yt = Y(:,1:N);

    % prepare validation data
    yv = Y(:,N+1:end);
    
    %---------- network parameters -------------
    % good parameters (you don't know 'tau' for unknown process)
    inputDelays = 1:fdbk;  % input delay vector
    hiddenSizes = HIDDEN_LAYERS; %[35 15 7];   % network structure (number of neurons)
    %-------------------------------------
    trainFcn = 'trainlm';  % Levenberg-Marquardt
    % nonlinear autoregressive neural network
    net = narnet(inputDelays, hiddenSizes,'open',trainFcn);
%     net.input.processFcns = {'removeconstantrows','mapminmax'};
    net.trainParam.showWindow = false;
    net.trainParam.epochs = 100000;
    net.performFcn = 'mse';  % Mean squared error
    
    T = tonndata(yt,true,false);
    % [Xs,Xi,Ai,Ts,EWs,shift] = preparets(net,Xnf,Tnf,Tf,EW)
    %
    % This function simplifies the normally complex and error prone task of
    % reformatting input and target timeseries. It automatically shifts input
    % and target time series as many steps as are needed to fill the initial
    % input and layer delay states. If the network has open loop feedback,
    % then it copies feedback targets into the inputs as needed to define the
    % open loop inputs.
    %
    %  net : Neural network
    %  Xnf : Non-feedback inputs
    %  Tnf : Non-feedback targets
    %   Tf : Feedback targets
    %   EW : Error weights (default = {1})
    %
    %   Xs : Shifted inputs
    %   Xi : Initial input delay states
    %   Ai : Initial layer delay states
    %   Ts : Shifted targets
    [Xs,Xi,Ai,Ts] = preparets(net,{},{},T);
    
    while (err > ERR_LIMIT)
        % train net with prepared training data
        net = train(net,Xs,Ts,Xi,Ai);
        % view trained net
    %     view(net)

        % close feedback for recursive prediction
%         net_close = closeloop(net);
        net_close = net;
        % view closeloop version of a net
    %     view(net);

        % prepare validation data for network simulation
        yini = yt(:,end-max(inputDelays)+1:end); % initial values from training data
        % combine initial values and validation data 'yv'
        T = tonndata([yini yv],true,false);
        [Xs_c,Xi_c,Ai_c] = preparets(net_close,{},{},T);

        % predict on validation data
        predict = net_close(Xs_c,Xi_c,Ai_c);

        % validation data
        Yv = yv;
    %     Yv = cell2mat(yv);
        % prediction
        Yp = cell2mat(predict);
        if isempty(Yp)
            e = 1;
        else
            % error
            e = Yv - Yp;
        end
        
        prevErr = err;
        err = abs(sum(e));
        if prevErr == err
            break;
        elseif iter == MAX_ITERATION
            break;
        end
        iter = iter + 1;
    end
    
    samples = max(inputDelays);
    nextInst = zeros(1,NO_INSTANCES);
    for k = 1:NO_INSTANCES
%         Y1 = Y(:,(end - (samples +  NO_INSTANCES - 1):end));
        Y1 = Y(:,(end - samples : end));
        Y1 = tonndata(Y1,true,false);

        [xc,xic,aic,~] = preparets(net_close,{},{},Y1);
        Ypred =  net_close(xc,xic,aic);

        nextInst(:,k) = cell2mat(Ypred);
        Y(:,end+k) = uint8(nextInst(:,k));
    end        

end