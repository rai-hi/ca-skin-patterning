function grid = random_distribution( size_x, size_y, percent )
%RANDOM_DISTRIBUTION Returns a grid of size_x * size_y with randomly
%distributed live cells (of amount specified in percent)

% Function converts percentage to probability in range 0:1. A matrix of
% random values in same range is created, and each value compared to
% probability. If the value is less than or equal to the prob., the
% corresponding cell is set to 1. Note that the percentage actually changed
% may differ to the percentage specified as a random distribution is used.

prob=percent/100;
grid=(rand(size_y,size_x)<=prob);

end