function err = NARNet_test(inData, fdbk, hidl)
    global FDBK_DELAYS  INTERPOLATE_DATA ;
    if INTERPOLATE_DATA
        Y = applySplineInterpolation(inData);
    else
        Y = inData;
    end
    len = length(Y);
    % data settings
    N  = 0.9 * len; % number of samples
    % prepare training data
    yt = Y(1:N);

    % prepare validation data
    yv = Y(N+1:end);
    
    %---------- network parameters -------------
    % good parameters (you don't know 'tau' for unknown process)
    inputDelays = 1:fdbk;  % input delay vector
    hiddenSizes = [35 15 7];   % network structure (number of neurons)
    %-------------------------------------

    % nonlinear autoregressive neural network
    net = narnet(inputDelays, hiddenSizes);
    net.trainParam.showWindow = false;
    net.trainParam.epochs = 10000;
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

    % train net with prepared training data
    net = train(net,Xs,Ts,Xi,Ai);
    % view trained net
%     view(net)

    % close feedback for recursive prediction
    net = closeloop(net);
    % view closeloop version of a net
%     view(net);

    % prepare validation data for network simulation
    yini = yt(end-max(inputDelays)+1:end); % initial values from training data
    % combine initial values and validation data 'yv'
    T = tonndata([yini yv],true,false);
    [Xs,Xi,Ai] = preparets(net,{},{},T);

    % predict on validation data
    predict = net(Xs,Xi,Ai);

    % validation data
    Yv = yv;
%     Yv = cell2mat(yv);
    % prediction
    Yp = cell2mat(predict);
    % error
    e = Yv - Yp;
    err = abs(sum(e));
end