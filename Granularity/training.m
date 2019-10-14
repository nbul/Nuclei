%% Load data


%% Randomly Partition the Data into Training and Validation Sets
cv = cvpartition(y, 'holdout', .5);
Xtrain = X(cv.training,:);
Ytrain = y(cv.training,1);

Xtest = X(cv.test,:);
Ytest = y(cv.test,1);


%% Train and Predict Using Bagged Decision Trees
mdl = fitensemble(Xtrain,Ytrain,'bag',200,'tree','type','Classification');
ypred = predict(mdl,Xtest);
Confmat_bag = confusionmat(Ytest,ypred);

%% Confusion Matrix

figure,
heatmap(Confmat_bag, 0:9, 0:9, 1,'Colormap','red','ShowAllTicks',1,...
    'UseLogColorMap',true,'Colorbar',true);
title('Confusion Matrix: Ensemble of Bagged Classification Trees')