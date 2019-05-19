function grid = random_distribution( size_x, size_y, percent )
%RANDOM_DISTRIBUTION Returns a grid of size_x * size_y with randomly
%distributed live cells (of amount specified in percent)
% 
%   Function converts percentage to probability in range 0:1. A matrix of
%   random values in same range is created, and each value compared to
%   probability. If the value is less than or equal to the prob., the
%   corresponding cell is set to 1. Note that the percentage actually changed
%   may differ to the percentage specified as a random distribution is used.
%
%   Inputs:
%    size_x - X dimension of grid
%    size_y - Y dimension of grid
%    percent - Percentage of cells to be set to live
%
%   Output: grid of randomly distributed cell states

prob=percent/100;
grid=zeros(size_y,size_x);

% While number of live cells is less than amount specified
while sum(sum(grid)) < ceil(prob*size_x*size_y)
    % Generate random x & y co-ordinates
    x=round(rand(1)*size_x);
    y=round(rand(1)*size_y);
    
    % Ignore any 0 co-ordinates
    if x~=0 && y~=0
         grid(y,x)=1;
    end
end