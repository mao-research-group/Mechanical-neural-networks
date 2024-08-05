clear;clc;

%% data
load fisheriris;
X = -meas./max(meas)*0.005*9.8;
y = species;
[unique_labels, ~, label_indices] = unique(y);
num_labels = numel(unique_labels);
one_hot_labels = eye(num_labels);
one_hot_labels = one_hot_labels(label_indices, :);
split_ratio = 0.7;
num_train_examples = round(size(X, 1) * split_ratio);
rand_indices = randperm(size(X, 1));
X_train = X(rand_indices(1:num_train_examples), :);
y_train = one_hot_labels(rand_indices(1:num_train_examples), :);
X_test = X(rand_indices(num_train_examples+1:end), :);
y_test = one_hot_labels(rand_indices(num_train_examples+1:end), :);

%% parameters
params = struct('a',1.6e-2,'n',4,'beta',5,...
    'ind_input',[14,12,13,10],'ind_output',[8,2,3]);
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
ind_fix(1) = 1;
ind_fix(2) = 5;

params.ind_fix = ind_fix;
params.ind_free = 1:size(DT.Points,1);
params.ind_free(params.ind_fix) = [];
params.C = C;
params.bonds = bonds;

optims = struct('alpha',6e-3,'beta1',0.9,'beta2',0.999,...
    'batch_size',16,'epochs',100);

figure;
for i = 1:size(bonds,1)
    plot([DT.Points(bonds(i,1),1),DT.Points(bonds(i,2),1)],[DT.Points(bonds(i,1),2),DT.Points(bonds(i,2),2)],'k-',...
        'LineWidth',1);
    hold on;
end
plot(DT.Points(params.ind_fix,1),DT.Points(params.ind_fix,2),'g^','MarkerSize',10);
plot(DT.Points(params.ind_input,1),DT.Points(params.ind_input,2),'r*','MarkerSize',10);
plot(DT.Points(params.ind_output,1),DT.Points(params.ind_output,2),'b*','MarkerSize',10);
axis equal;axis off;

%% optimization
results.kHist = []; % optimized k
results.fHist = []; % cost function
results.pred_train = []; % prediction of train
results.pred_test = []; % prediction of test
results.acc_train = []; % accuracy of training data
results.acc_test = []; % accuracy of testing data

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
        [results.fHist{epoch}(count),sgCurr] = Spring2Dbatch(k0,X_batch,y_batch,params,optims,'1');
        results.kHist{epoch}(:,count) = Convert_k(k0,params);
        % Adam optimizer
        [k0,m_moment,v_moment] = Train_Adam(k0,sgCurr,m_moment,v_moment,iter,params,optims);
        iter = iter + 1;
        count = count + 1;
    end
    [results.pred_train{epoch},results.acc_train(epoch)] = prediction(results.kHist{epoch}(:,end),params,optims,X_train,y_train);
    [results.pred_test{epoch},results.acc_test(epoch)] = prediction(results.kHist{epoch}(:,end),params,optims,X_test,y_test);
    formatSpec = 'Epoch:%d/%d  Cost:%e  Accuracy(Train):%f  Accuracy(Test):%f\n';
    fprintf(formatSpec,epoch,optims.epochs,mean(results.fHist{epoch}),results.acc_train(epoch),results.acc_test(epoch));
end