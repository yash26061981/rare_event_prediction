function prob = computeProbability(prob_to_compute, failure_type)
    prob = 0;
    if prob_to_compute == 0
        prob = 0;
    elseif (strcmp(failure_type,'Battery') || strcmp(failure_type,'PIU Failure'))
        max_arr_sz = 10;
        max_prob_size = prob_to_compute/max_arr_sz;
        arr = zeros(1,max_arr_sz);
        arr(end-max_prob_size+1 : end) = 1;
        randNo = randi(max_arr_sz,1);
        prob = arr(randNo);
    end
end