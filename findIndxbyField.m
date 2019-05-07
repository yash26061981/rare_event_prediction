function indx = findIndxbyField(inarr, field, string1)
   sz = numel(inarr);
   indx = false;
   for k= 1: sz
       val = getfield(inarr(k,1),field);
       if strcmp(val,string1)
           indx = k;
           break;
       end
   end
end
