% This function can handle matrices
% dim is the dimension over which you want to measure sparseness
% if you have stimuli x neurons, lifetime sparseness is dim 1, population
% sparseness is dim 2
% m x n matrix
% if dim = 1, returns size n vector
% if dim = 2, returns size m vector
% but if you only want to characterise the sparseness of a single array,
% call it with an n x 1 array and set dim = 1
% ie calcSparseness(array, 1)
% if you are measuring sparseness of an image, make sure to turn the image
% matrix into a linear array eg, image(:)

function [result] = calcSparseness(input, dim)

% the size of the dimension along which we are taking the sparseness
dimsize = size(input, dim);

if (find(input < 0))
   fprintf('Warning: zero-ing out negative numbers!');
%    fprintf('Warning: taking the absolute value of input!');
end

input(input<0) = 0;
%input = abs(input);

result = squeeze((1 - (sum(input/dimsize, dim)).^2./sum(input.^2/dimsize, dim))/(1-1/dimsize));