function conv = Check_conv_CE(fcost,k_error,iter,optims)
    % Check convergence
    conv = 0;
    formatSpec = 'Iteration:%d  Cost:%e  Error(k):%e\n';
    fprintf(formatSpec,iter,fcost(end),k_error(end));
    if iter > 1
        if k_error(iter) <= optims.k_conv
            conv = 1;
            disp('k converges');
        elseif iter >= optims.MaxIter
            conv = 1;
            disp('maximum iteration');
        end
    else
        if iter >= optims.MaxIter
            conv = 1;
            disp('maximum iteration');
        end
    end