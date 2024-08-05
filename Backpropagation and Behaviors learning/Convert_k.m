function k_spring = Convert_k(k,params)
    k_spring = k;
    if length(k) == length(params.LB) && length(k) == length(params.UB)
        for i = 1:length(k)
            if params.UB(i) == inf && params.LB(i) ~= inf
                k_spring(i) = log(1+exp(k(i))) + params.LB(i);
            elseif params.UB(i) ~= inf && params.LB(i) == inf
                k_spring(i) = -log(1+exp(k(i))) + params.UB(i);
            elseif params.UB(i) ~= inf && params.LB(i) ~= inf
                k_spring(i) = params.LB(i) + (params.UB(i)-params.LB(i))./(1+exp(-params.beta*k(i)));
            else
                k_spring(i) = k(i);
            end
        end
    else
        disp('error');
    end