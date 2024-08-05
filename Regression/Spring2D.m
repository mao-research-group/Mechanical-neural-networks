function [fcost,u_error,u_sol,e_sol,F_err] = Spring2D(k0,F,u_output,params,optims,condition)
    if isequal(condition,'1')
        k = Convert_k(k0,params);
    elseif isequal(condition,'0')
        k = k0;
    end
    D = params.C.'*diag(k)*params.C;
    F([2*params.ind_fix-1,2*params.ind_fix]) = [];
    D(:,[2*params.ind_fix-1,2*params.ind_fix]) = [];
    D([2*params.ind_fix-1,2*params.ind_fix],:) = [];
    u_free = D\F;
    
    u_sol = zeros(size(params.C,2),1);
    u_sol(2*params.ind_free-1) = u_free(1:2:end);
    u_sol(2*params.ind_free) = u_free(2:2:end);
    e_sol = params.C*u_sol;
    if isempty(u_output) == 0
        fcost = sum(1/2*(u_sol([2*params.ind_output-1,2*params.ind_output])-u_output(:)).^2);
        u_error = norm(u_sol([2*params.ind_output-1,2*params.ind_output])-u_output(:))/norm(u_output(:));

        F_err = zeros(size(params.C,2),1);
        F_err([2*params.ind_output-1,2*params.ind_output]) = -(u_sol([2*params.ind_output-1,2*params.ind_output])-u_output(:));
    else
        fcost = [];
        u_error = [];
        F_err = [];
    end