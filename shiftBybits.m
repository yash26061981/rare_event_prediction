function outData = shiftBybits(numb, inData)
    sz = max(size(inData));
    outData = zeros(1,sz);
    if numb > 0 % right shift
        for k = numb+1:sz
            outData(k) = inData(k-numb);
        end
    else
        numb = abs(numb);
        for k = numb+1:sz
            outData(k-numb) = inData(k);
        end
    end
end