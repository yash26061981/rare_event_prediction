function outPut_Vect = applySplineInterpolation(inData_Vect)
    global SAMPLES;
    
    duration = 1/SAMPLES;
    y = inData_Vect;
    L = length(y);
    x = 0:L-1;
    xx = 0:duration:L-1;
    outPut_Vect = spline(x,y,xx);
end