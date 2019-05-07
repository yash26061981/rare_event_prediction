function result = applyRuleCases(faultType, instances, reqlen)
    result = false;
    switch faultType
        case {'Indus Shared Site Power Issue1','GSM Cell out of Service1',...
                'SMPS','AMPLIFIER SHELF FAN FAILURE','Abis Signaling Link Interrupted',...
                'Main Processing Module Satellite Card No Second Signal Output',...
                'TRX Hardware Critical Alarm','Cables and connectors',...
                'GPS FLYWHEELING INFO ERROR','TX AMP LOSS','BTS OM Link Interrupted',...
                'RXAMP SECTOR DIV FAILURE','RX SYNTHESIZER OUT OF LOCK',...
                'COMBINER INPUT FAIL FORWARD BUS LINK LOSS','Fading'}
            lastclub1Rule = false;
            check_lasttwo = false;
            result = get_result_from_one_zero_rules(instances, lastclub1Rule, check_lasttwo);
            
        case 'Board Communication Alarm'
            lastclub1Rule = true;
            check_lasttwo = false;
            result = get_result_from_one_zero_rules(instances, lastclub1Rule,check_lasttwo);
        
        case {'Standing Wave Alarm','Non Indus and Infratel Shared Site-Power Issue',...
                'DIGITAL SHELF FAN FAILURE','FUSE FAIL'}
            lastclub1Rule = true;
            check_lasttwo = true;
            result = get_result_from_one_zero_rules(instances, lastclub1Rule,check_lasttwo);
            
        case 'No Fuel'
            if 1
                result = true;
            else
                lastclub1Rule = false;
                check_lasttwo = false;
                result = get_result_from_one_zero_rules(instances, lastclub1Rule, check_lasttwo);
                if result == false
                    isPresent = find(instances(end-reqlen+1 : end) > 0);
                    if isempty(isPresent)
                        result = true;
                    end
                end
            end
        case 'Communications Between BSC and BTS Interrupted'
            lastclub1Rule = false;
            check_lasttwo = false;
            result = get_result_from_one_zero_rules(instances, lastclub1Rule, check_lasttwo);
            if result == false
                % TBD commented for august month prediction
                num = find_numbers_in_instant(instances, 1, 10, 'end');
                if num < 5
                    result = true;
                end
            end
            
        case {'Indus Shared Site Power Issue2','Battery1','PIU Failure1'}
            lastclub1Rule = false;
            check_lasttwo = false;
            result = get_result_from_one_zero_rules(instances, lastclub1Rule, check_lasttwo);
            if result == false
                num = find_numbers_in_instant(instances, 1, 10, 'end');
                if strcmp(faultType,'Battery')
                    if num < 5
                        result = true;
                    end
                elseif strcmp(faultType,'Indus Shared Site Power Issue')
%                     if num < 5
%                         result = true;
%                     end
                else
                    num = find_numbers_in_instant(instances, 1, 6, 'end');
                    if num < 3
                        result = true;
                    end
                end
            end
            
        case 'BTS'
            num = find_numbers_in_instant(instances, 1, 10, 'end');
            if num < 4
                result = true;
            end  
            
        case 'MiniLink'
            num = find_numbers_in_instant(instances, 1, 10, 'end');
            if num < 2
                result = true;
            end 
            
        case 'RECTIFIER FAIL'
            lastclub1Rule = false;
            check_lasttwo = true;
            result = get_result_from_one_zero_rules(instances, lastclub1Rule, check_lasttwo);
            
        case 'SPEC MGT MAJOR ERROR'
            num = find_numbers_in_instant(instances, 1, 4, 'end');
            if num < 3
                result = true;
            end 
            
        case 'FUSE FAIL1'
            num = find_numbers_in_instant(instances, 1, 3, 'end');
            if num < 2
                result = true;
            end 
                
        case {'OML Fault','GSM Cell out of Service','Indus Shared Site Power Issue'}
            result = true;
            
        case 'OML Between Board and main processing module Disconnected'
            if (instances(end) == 1) && (instances(end-1) == 1)
                clubInst = get_clubbed_one_zeros(instances, 1);
                if max(clubInst) < 2
                    result = true;
                end
            else      
                if 1
                    isPresent = find(instances(end-reqlen+1 : end) > 0);
                    if isempty(isPresent)
                        result = true;
                    end
                else
                    isPresent = find(instances(1 : end) > 0);
                    after1len = length(instances) - isPresent(end);
                    l = 0;
                    istrue = true;
                    while istrue
                        clublen = isPresent(end-l) - isPresent(end-l-1);
                        if clublen == 1
                            l = l+1;
                        else
                            istrue = false;
                        end
                        if (l == (length(isPresent)-1))
                            istrue = false;
                            isPresent(2:end+1) = isPresent;
                            isPresent(1) = 0;
                        end
                    end
                    before1len = isPresent(end - l) - isPresent(end - l - 1) -1;
                    if (after1len > before1len)
                        result = true;
                    else
            %                         isPresent = find(instances(end-reqlen+1 : end) > 0);
            %                         if isempty(isPresent)
            %                             isfilter = true;
            %                         end
                    end              
                end
            end
            
        case 'PIU Failure1'
            isPresent = find(instances(end-reqlen+1 : end) > 0);
            if isempty(isPresent)
                result = true;
            end
            len = length(find(instances(end-reqlen+1 : end) > 0));
            if len == reqlen
                result = false;
            end
            
        case 'Battery1'
            isPresent = find(instances(end-reqlen+1 : end) > 0);
            if isempty(isPresent)
                result = true;
            elseif (instances(end) == 0)
                clubInst1 = get_clubbed_one_zeros(instances, 1);
                clubInst0 = get_clubbed_one_zeros(instances, 0);
                if (clubInst0(end) < max(clubInst0(1:end-1)))
                    result = true;
                elseif (clubInst1(end) >= max(clubInst1(1:end-1)))
                    result = true;
                end
            elseif ((instances(end) == 1) && (instances(end-1) == 0))
                clubInst1 = get_clubbed_one_zeros(instances, 1);
                clubInst0 = get_clubbed_one_zeros(instances, 0);
                [~,indx1] = find(clubInst1 > 1);
                if instances(1) == 0
                    indx0 = indx1;
                else
                    if indx1(1) == 1
                        indx1(1:end-1) = indx1(2:end);
                        indx1(end) = [];
                    end
                    indx0 = indx1 - 1;
                end
                maxafter0 = max(clubInst0(indx0));
                if (clubInst0(end) > maxafter0)
                    result = true;
                end
            elseif ((instances(end) == 1) && (instances(end-1) == 1))
                clubInst0 = get_clubbed_one_zeros(instances, 0);
                if (clubInst0(end) < max(clubInst0(1:end-1)))
                    result = true;
                end
            else
                isPresent = find(instances(end-reqlen+1 : end) > 0);
                if isempty(isPresent)
                    result = true;
                end
            end
            
        otherwise
            isPresent = find(instances(end-reqlen+1 : end) > 0);
            if isempty(isPresent)
                result = true;
            end
    end
end