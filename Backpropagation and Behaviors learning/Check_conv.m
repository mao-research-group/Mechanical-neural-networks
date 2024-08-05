function conv = Check_conv(fcost,k_error,u_error,iter,optims)
    % Check convergence
    conv = 0;
    formatSpec = 'Iteration:%d  Cost:%e  Error(u):%e  Error(k):%e\n';
    fprintf(formatSpec,iter,fcost(end),u_error(end),k_error(end));
    if iter > 1
        if k_error(iter) <= optims.k_conv
            conv = 1;
            disp('k converges');
        elseif u_error(iter) <= optims.u_conv
            conv = 1;
            disp('u converges');
        elseif iter >= optims.MaxIter
            conv = 1;
            disp('maximum iteration');
        end
    else
        if u_error(iter) <= optims.u_conv
            conv = 1;
            disp('u converges');
        elseif iter >= optims.MaxIter
            conv = 1;
            disp('maximum iteration');
        end
    end
