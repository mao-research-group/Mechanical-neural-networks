function [fcost,u_error,sgCurr] = Spring2Dbatch(k0,X_batch,y_batch,params,optims,condition)
    fGrad = [];fcost = 0;u_error = 0;
    parfor i = 1:size(X_batch,1)
        F = zeros(size(params.C,2),1);
        F(2*params.ind_input) = X_batch(i,:);
        u_output = [y_batch(i,1),y_batch(i,2);y_batch(i,3),y_batch(i,4)];
        [fcost_temp,u_error_temp,u_sol,eori,F_err] = Spring2D(k0,F,u_output,params,optims,condition);
        [~,~,~,eadj,~] = Spring2D(k0,F_err,u_output,params,optims,condition);
        fGrad(:,i) = eadj.*eori;
        fcost = fcost + fcost_temp;
        u_error = u_error + u_error_temp;
    end
    fcost = fcost/optims.batch_size;
    u_error = u_error/optims.batch_size;
    sgCurr = mean(fGrad,2);
