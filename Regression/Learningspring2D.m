clear;clc;close all;

%% 1D data
X = -0.02*9.8+0.04*9.8*rand(100,1);
y = [-0.00*X,0.016*X,0.004*X,0.016*X];
% add noise
% y = y + 1e-4*randn(size(y));
split_ratio = 0.7;
num_train_examples = round(size(X, 1)*split_ratio);
rand_indices = randperm(size(X, 1));
X_train = X(rand_indices(1:num_train_examples), :);
y_train = y(rand_indices(1:num_train_examples), :);
X_test = X(rand_indices(num_train_examples+1:end), :);
y_test = y(rand_indices(num_train_examples+1:end), :);
figure;
plot(y(:,1),y(:,2),'ro');
hold on;
plot(y(:,3),y(:,4),'bo');
axis equal;

%% parameters
params = struct('a',1.6e-2,'n',4,'beta',10,...
    'ind_input',[11],'ind_output',[13,14]);
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
ind_fix = [];
[~,ind_fix(1)] = min(DT.Points(:,1));
[~,ind_fix(2)] = max(DT.Points(:,1));

params.ind_fix = ind_fix;
params.ind_free = 1:size(DT.Points,1);
params.ind_free(params.ind_fix) = [];
params.C = C;
params.bonds = bonds;

optims = struct('alpha',1e-1,'beta1',0.9,'beta2',0.999,...
    'batch_size',16,'epochs',5000);

figure;
triplot(DT,'k-');
hold on;
plot(DT.Points(params.ind_fix,1),DT.Points(params.ind_fix,2),'g^','MarkerSize',10);
plot(DT.Points(params.ind_input,1),DT.Points(params.ind_input,2),'r*','MarkerSize',10);
plot(DT.Points(params.ind_output,1),DT.Points(params.ind_output,2),'b*','MarkerSize',10);
axis equal;axis off;

%% optimization
results.kHist = []; % optimized k
results.fHist = []; % cost function
results.u_error_train = []; % relative error of training data
results.u_error_test = []; % relative error of testing data

% Set the initial guess
k0 = zeros(n_spring,1);

% Initialize moment estimates
m_moment = zeros(n_spring, 1);
v_moment = zeros(n_spring, 1);

iter = 1;
for epoch = 1:optims.epochs
    ind_shuffle = randperm(size(X_train,1));
    X_train_shuffle = X_train(ind_shuffle,:);
    y_train_shuffle = y_train(ind_shuffle,:);
    count = 1;
    for i = 1:optims.batch_size:size(X_train_shuffle,1)
        idx = i:min(i+optims.batch_size-1,size(X_train_shuffle,1));
        X_batch = X_train_shuffle(idx,:);
        y_batch = y_train_shuffle(idx,:);
        % Get gradients
        [results.fHist{epoch}(count),~,sgCurr] = Spring2Dbatch(k0,X_batch,y_batch,params,optims,'1');
        results.kHist{epoch}(:,count) = Convert_k(k0,params);
        % Adam optimizer 
        [k0,m_moment,v_moment] = Train_Adam(k0,sgCurr,m_moment,v_moment,iter,params,optims);
        iter = iter + 1;
        count = count + 1;
    end
    results.u_error_train(:,epoch) = prediction(results.kHist{epoch}(:,end),params,optims,X_train,y_train);
    results.u_error_test(:,epoch) = prediction(results.kHist{epoch}(:,end),params,optims,X_test,y_test);
    formatSpec = 'Epoch:%d/%d  Cost:%e  Error(Train):%e  Error(Test):%e\n';
    fprintf(formatSpec,epoch,optims.epochs,mean(results.fHist{epoch}),mean(results.u_error_train(:,epoch)),mean(results.u_error_test(:,epoch)));
end