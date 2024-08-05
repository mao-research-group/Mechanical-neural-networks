function [fcost,sgCurr] = Spring2Dbatch(k0,X_batch,y_batch,params,optims,condition)
    fGrad = [];fcost = 0;
    parfor i = 1:size(X_batch,1)
        F = zeros(size(params.C,2),1);
        F(2*params.ind_input) = X_batch(i,:);
        u_output = y_batch(i,:);
        [fcost_temp,~,eori,F_err] = Spring2D(k0,F,u_output,params,optims,condition);
        [~,~,eadj,~] = Spring2D(k0,F_err,u_output,params,optims,condition);
        fGrad(:,i) = eadj.*eori;
        fcost = fcost + fcost_temp;
    end
    fcost = fcost/optims.batch_size;
    sgCurr = mean(fGrad,2);
