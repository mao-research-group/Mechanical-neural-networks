clear;clc;

%% parameters
params = struct('a',1.6e-2,'n',4,'beta',10,...
    'ind_input',[11],'ind_output',[13,14],...
    'u_input',[0,-0.005*9.8],'u_output',[0,-5e-4;0,-8e-4]);
% change the u_output to be [0,1;0,0] if you use cross entropy loss
[DT,bonds] = Triangle(params);
n_spring = size(bonds,1);
w1 = 1.5*10^(-3);w2 = 2.5*10^(-3);
thickness = 2*10^(-3);
Y = 5.5e5;
kL = Y*w1*thickness/params.a;
kU = Y*w2*thickness/params.a;
params.LB = kL*ones(n_spring,1);
params.UB = kU*ones(n_spring,1);
C = compatibility_matrix(DT.Points,bonds);
ind_fix = [1,5];

params.ind_fix = ind_fix;
params.ind_free = 1:size(DT.Points,1);
params.ind_free(params.ind_fix) = [];
params.C = C;
params.bonds = bonds;

optims = struct('alpha',5e-3,'beta1',0.9,'beta2',0.999,...
    'k_conv',1e-8,'u_conv',1e-3,'MaxIter',30000);

figure;
for i = 1:size(bonds,1)
    plot([DT.Points(bonds(i,1),1),DT.Points(bonds(i,2),1)],[DT.Points(bonds(i,1),2),DT.Points(bonds(i,2),2)],'k-',...
        'LineWidth',1);
    hold on;
end
plot(DT.Points(params.ind_fix,1),DT.Points(params.ind_fix,2),'g^','MarkerSize',10);
plot(DT.Points(params.ind_input,1),DT.Points(params.ind_input,2),'r*','MarkerSize',10);
plot(DT.Points(params.ind_output,1),DT.Points(params.ind_output,2),'b*','MarkerSize',10);
axis equal;
axis off;

%% optimization
results.kHist = []; % optimized k
results.fHist = []; % cost function
results.k_error = []; % relative error of k
results.u_error = []; % relative error of u

% Set the initial guess 
k0 = zeros(n_spring,1);
F = zeros(size(params.C,2),1);
F(2*params.ind_input-1) = params.u_input(:,1);
F(2*params.ind_input) = params.u_input(:,2);

% Initialize moment estimates
m_moment = zeros(n_spring,1);
v_moment = zeros(n_spring,1);

iter = 1;
while 1
    % Get gradients
    [results.fHist(iter),results.u_error(iter),u,eori,F_backward] = Spring2D_MSE(k0,F,params,optims,'1');
    [~,~,uadj,eadj,~] = Spring2D_MSE(k0,F_backward,params,optims,'1');
    sgCurr = eadj.*eori;
    results.kHist(:,iter) = Convert_k(k0,params);
    if iter == 1
        results.k_error(iter) = NaN;
    else
        results.k_error(iter) = norm(results.kHist(:,iter) - results.kHist(:,iter-1))/norm(results.kHist(:,iter-1));
    end
    % Adam optimizer
    [k0,m_moment,v_moment] = Train_Adam(k0,sgCurr,m_moment,v_moment,iter,params,optims);
    % Convergence
    if Check_conv(results.fHist,results.k_error,results.u_error,iter,optims)
        break;
    else
        iter = iter + 1;
    end
end
