function new_grid = apply_rule( grid,conv_matrix )
%APPLY_RULE Uses conv2() to apply a rule specified by the convolution
%matrix, conv to a grid of binary states, grid.
%  Inputs:
%   grid - matrix of binary values representing states
%   conv - convolution kernel representing neighbourhood of the rule
%  Outputs:
%   new_grid - matrix of binary values representing updated states

% Initialise grid to store updated state values. All states initially start
% the same as the current ones.
new_grid=grid;

% Sum for each value calculated and stored
sum=conv2(grid*1,conv_matrix,'same'); 

new_grid(sum>0)=1; % Values in the new states matrix set to alive if sum>0
new_grid(sum<0)=0; % Values in the new states matrix set to dead if sum<0
% Otherwise the cell state remains the same as the previous generation

end