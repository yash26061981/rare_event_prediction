function [maxSR, maxW, maxD, res] = discoverRuleforgivenInstant(inInstance)

    global USE_OVERLAP_WINDOW USE_INSTANCE_SIZE USE_LAST_VAL_IN_PRED WIDTH_RANGE MIN_GAP
    
%     USE_OVERLAP_WINDOW = true;
%     USE_INSTANCE_SIZE = -1;
%     USE_LAST_VAL_IN_PRED = true;
    
    width = WIDTH_RANGE; %3:10;
    minGap = MIN_GAP; %1;
    maxSR = 0; maxW = 0; maxD = 0;
    
    originstance1 = inInstance;
    if USE_LAST_VAL_IN_PRED
        originstance1(end+1) = 1;
    end
    if USE_INSTANCE_SIZE == -1
        originstance = originstance1;
    else
        originstance = originstance1(end-USE_INSTANCE_SIZE+1: end);
    end
    instance = originstance(1:end-1);
    for w = width(1):width(end)
        if USE_OVERLAP_WINDOW
            stepSize = -1;
        else
            stepSize = -w;
        end
        slots = length(instance):stepSize:w; 
        sratio = zeros(1,length(width(1)-minGap:w-minGap));
        indx = 1;
        drange = width(1)-minGap:w-minGap;
        for d = width(1)-minGap:w-minGap
            trueSlot = 0;
            for slot = 0:(length(slots)-1)
                inst_new = instance(end-w+1-slot : end-slot);
                check_indx = length(instance) - slot + 1;
                num = length(find(inst_new(1:end) > 0));
                if (num >= d) && (originstance(check_indx) == 1)
                    trueSlot = trueSlot + 1;
                end
            end
            sratio(indx) = trueSlot/length(slots);
            indx = indx + 1;                    
        end
    %                 sratio
        [val,id] = max(sratio);
        if val > maxSR
            maxSR = val;
            maxW = w; maxD = drange(id);
        end
    end
    num = find_numbers_in_instant(instance, 1, maxW, 'end');
    if (maxW == 0)
        res = true;
    elseif (num >= maxD) && (originstance(end) == 1)
        res = false;
    else
        res = true;
    end
end