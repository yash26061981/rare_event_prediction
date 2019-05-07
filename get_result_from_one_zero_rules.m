function result = get_result_from_one_zero_rules(instances, lastclub1Rule, check_lasttwo)
    result = false;
    isPresent = find(instances(1 : end) > 0);
    if lastclub1Rule == true
        if (instances(end) == 1) && (instances(end-1) == 1)
            clubInst = get_clubbed_one_zeros(instances, 1);
            if max(clubInst) < 2
                result = true;
            end
        elseif (instances(end) == 1)                    
%             if (isPresent(end-1) - isPresent(end-2)) > 1
%                 result = true;
%             end
            clubInst = get_clubbed_one_zeros(instances, 1);
            if max(clubInst) < 2
                result = true;
            end
        else
            club0Inst = get_clubbed_one_zeros(instances,0);
            club0Inst(1) = 0;
            after1len = club0Inst(end);
            if length(club0Inst) >= 3
                if check_lasttwo
                    before1len = max(club0Inst(end - 1), club0Inst(end - 2));
                else
                    before1len = club0Inst(end - 1);
                end
            elseif length(club0Inst) >= 2
                before1len = club0Inst(end - 1);
            else
                before1len = after1len;
            end
                
            if (after1len > before1len)
                result = true;
            end
        end
    else
        if (instances(end) == 1)                    
            if (isPresent(end-1) - isPresent(end-2)) > 1
                result = true;
            end
        else
            club0Inst = get_clubbed_one_zeros(instances,0);
            club0Inst(1) = 0;
            after1len = club0Inst(end);
            if length(club0Inst) >= 3
                if check_lasttwo
                    before1len = max(club0Inst(end - 1), club0Inst(end - 2));
                else
                    before1len = club0Inst(end - 1);
                end
            elseif length(club0Inst) >= 2
                before1len = club0Inst(end - 1);
            else
                before1len = after1len;
            end
                
            if (after1len > before1len)
                result = true;
            end
        end
    end        
end