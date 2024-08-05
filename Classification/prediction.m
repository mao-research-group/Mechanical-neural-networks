function [pred,acc] = prediction(k,params,optims,X,y)
    pred = [];
    parfor i = 1:size(X,1)
        F = zeros(size(params.C,2),1);
        F(2*params.ind_input) = X(i,:);
        u_output = y(i,:);
        [~,pred_temp,~,~] = Spring2D(k,F,u_output,params,optims,'0');
        pred_temp_x = pred_temp(2*params.ind_output-1);
        pred_temp_y = pred_temp(2*params.ind_output);
        pred(i,:) = sqrt(pred_temp_x.^2)';
        pred(i,:) = pred(i,:)/sum(pred(i,:));
    end
    [~,ind_pred] = max(pred,[],2);
    [~,ind_y] = max(y,[],2);
    acc = sum(ind_pred == ind_y)/length(ind_pred);