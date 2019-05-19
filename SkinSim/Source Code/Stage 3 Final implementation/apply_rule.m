function new_grid = apply_rule( grid,conv_matrix )
%APPLY_RULE Uses conv2() to apply a rule specified by the convolution
%matrix, conv to a grid of binary states, grid.
%
%   Inputs:
%    grid - binary matrix of cell states
%    conv_matrix - convolution kernel representing neighbourhood
%
%   Output: grid of updated cell states

% Defines the size of the padding area depending on size of 
% the conv. matrix
border_size=(size(conv_matrix)-1)/2; 

% Produces matrix padded with wraparound values
padded=pad_matrix(grid,conv_matrix); 

% Initialise grid to store updated state values. All states initially 
% start the same as the current ones.
new_grid=padded;

% Sum for each value calculated and stored
sum=conv2(padded*1,conv_matrix,'same');

% Values in the new states matrix set to alive if sum>0
new_grid(sum>0)=1;

% Values in the new states matrix set to dead if sum<0
new_grid(sum<0)=0;

% Otherwise the cell state remains the same as the previous generation

% Padded area removed to give original sized matrix
new_grid=new_grid(border_size(1)+1:end-border_size,...
    border_size(1)+1:end-border_size);

