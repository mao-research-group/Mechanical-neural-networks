function acc = prediction(k,params,optims,X,y)
    acc = [];
    for i = 1:size(X,1)
        F = zeros(size(params.C,2),1);
        F(2*params.ind_input) = X(i,:);
        u_output = [y(i,1),y(i,2);y(i,3),y(i,4)];
        [~,uerr,u_sol,~,~] = Spring2D(k,F,u_output,params,optims,'0');
        acc(i,1) = uerr;
    end