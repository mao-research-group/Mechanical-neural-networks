function [fcost,u_sol,e_sol,F_err] = Spring2D(k0,F,u_output,params,optims,condition)
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
    u_sol_output = zeros(2*length(params.ind_output),1);
    u_sol_output(1:2:end) = u_sol(2*params.ind_output-1);
    u_sol_output(2:2:end) = u_sol(2*params.ind_output);
    d_sol_output = sqrt(u_sol(2*params.ind_output-1).^2);
    d_sol_output_norm = d_sol_output/sum(d_sol_output);
    
    if isempty(u_output)
        fcost = [];
        F_err = [];
    else
        fcost = -log(u_output*d_sol_output_norm);
        
        F_err = zeros(size(params.C,2),1);
    
        v = sym('v',[1,length(u_output)],'real');
        ux = sym('ux',[length(u_output),1],'real');
        uy = sym('uy',[length(u_output),1],'real');
        u_sym = sym(zeros(2*length(u_output),1));
        u_sym(1:2:end) = ux;
        u_sym(2:2:end) = uy;
        u = sqrt(ux.^2);
        u_norm = u/sum(u);
    
        J = jacobian(-(log(v*u_norm)),u_sym);
        
        F_sym = -J;
        F_sym = subs(F_sym,u_sym,u_sol_output);
        F_sym = subs(F_sym,v,u_output);
        F_err(2*params.ind_output-1) = double(F_sym(1:2:end));
        F_err(2*params.ind_output) = double(F_sym(2:2:end));
    end
    