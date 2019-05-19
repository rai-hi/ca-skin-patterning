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

for i=1:round(prob*size_x*size_y)
    x=round(rand(1)*size_x);
    y=round(rand(1)*size_y);
    if x==0
        x=1;
    end
    if y==0
        y=1;
    end
    grid(y,x)=1;
end