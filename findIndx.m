function indx = findIndx(inarr, string1)
   sz = max(size(inarr));
   ind = strfind(inarr(1,:),string1);
   indx = -1;
   for k= 1: sz
       if ind{k} == 1
           indx = k;
           break;
       end
   end
end