function outVal = trainFeedForwardNetwork_BitStream(data,inst)
    sample = 10; 
    dur = 1/sample;
    for k = 1:inst
%         y = data; L = length(y);
%         x = 0:L-1;  xx = 0:dur:L-1;
%         yy = spline(x,y,xx);
%         
%         t = yy; 
%         LL = length(xx);  x = 0:(LL-1);
        t = data;
        net = feedforwardnet(20);
        net = configure(net,inx,data);
%         y1 = net(x);
        % plot(x,t,'o',x,y1,'x')
        net = train(net,inx,data);
%         y2 = net(x);
%         plot(x,t,'o',x,y1,'x',x,y2,'*')
        xx = 0:dur:L;
        x1 = 0:length(xx)-1;
        y3 = net(x1);
        outVal(k) = y3(end)
        data = [data, outVal(k)];
%         plot(x,t,'o',x,y1,'x',x,y2,'*',x1,y3,'+')
    end
%     plot(x,t,'o',x,y1,'x',x,y2,'*',x1,y3,'+')
end