clc
clear variables
close all
%% Determening paths and setting folders
currdir = pwd;
addpath(pwd);
filedir = uigetdir();
cd(filedir);

files_nuc = dir('*.tif');
files_reg = dir('*.csv');


%% collecting labels (y)

Y = zeros(1,1);

for i = 1:numel(files_reg)
    Y_temp = csvread([num2str(i),'_label.csv']);
    Y = [Y; Y_temp];
end

Y = Y_temp;

%% Collecting images for training (X)
nucleus = struct([]);
x_size = zeros(numel(files_nuc),1);
y_size = zeros(numel(files_nuc),1);
y = zeros(sum(Y>0),1);

counter = 0;
for i = 1:numel(files_nuc)
    if Y(i) > 0 && Y(i) < 5
        counter = counter + 1;
        nucleus{counter} = imread([num2str(i),'.tif']);
        [x_size(counter), y_size(counter)] = size(nucleus{counter});
        y(counter) = Y(i);
    end
end

reshape_factor = median([x_size; y_size]);
X = zeros(numel(nucleus), reshape_factor^2);

for i = 1:numel(nucleus)    
    nucleus{i} = imresize(nucleus{i}, [reshape_factor, reshape_factor]);
    nucleus{i} = nucleus{i}(:)';
    X(i,:) = nucleus{i};
end


% Randomly select 100 data points to display
sel = randperm(size(X, 1));
sel = sel(1:100);

displayData(X(sel, :));

%% Setup the parameters you will use for this exercise
input_layer_size  = reshape_factor^2;  % 20x20 Input Images of Digits
hidden_layer_size = 150;   % 100 hidden units
num_labels = length(unique(y));          % 10 labels, from 1 to 10   
                          % (note that we have mapped "0" to label 10)

                         
initial_Theta1 = randInitializeWeights(input_layer_size, hidden_layer_size);
initial_Theta2 = randInitializeWeights(hidden_layer_size, num_labels);
%initial_Theta3 = randInitializeWeights(hidden_layer_size, num_labels);

% Unroll parameters
initial_nn_params = [initial_Theta1(:) ; initial_Theta2(:)];

fprintf('\nTraining Neural Network... \n')

%  After you have completed the assignment, change the MaxIter to a larger
%  value to see how more training helps.
options = optimset('MaxIter', 50000);

%  You should also try different values of lambda
lambda = 0.1;

% Create "short hand" for the cost function to be minimized
costFunction = @(p) nnCostFunction(p, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, X, y, lambda);

% Now, costFunction is a function that takes in only one argument (the
% neural network parameters)
[nn_params, cost] = fmincg(costFunction, initial_nn_params, options);

% Obtain Theta1 and Theta2 back from nn_params
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));
             
%Theta3 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1)) +...
%    (hidden_layer_size * (hidden_layer_size + 1))):end),...
%                 num_labels, (hidden_layer_size + 1));             

fprintf('Program paused. Press enter to continue.\n');
pause;

fprintf('\nVisualizing Neural Network... \n')

displayData(Theta1(:, 2:end));

fprintf('\nProgram paused. Press enter to continue.\n');
pause;

%% ================= Part 10: Implement Predict =================
%  After training the neural network, we would like to use it to predict
%  the labels. You will now implement the "predict" function to use the
%  neural network to predict the labels of the training set. This lets
%  you compute the training set accuracy.

pred = predict(Theta1, Theta2, X);

fprintf('\nTraining Set Accuracy: %f\n', mean(double(pred == y)) * 100);                          