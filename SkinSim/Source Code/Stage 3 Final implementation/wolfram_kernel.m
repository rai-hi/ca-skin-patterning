function kernel = wolfram_kernel( dist2,dist3,striped)
%WOLFRAM_KERNEL Generates a convolution kernel for the wolfram rules 
%based on the input parameters. If none specified, default values used.
%   Inputs:
%    dist2 - weighting of cells at distance 2 away from current cell
%    dist3 - weighting of cells at distance 3 away from current cell
%    striped - string. Value either 'off' for no striping, 'h' for
%    horizontal and 'v' for vertical
%   Output: kernel of Wolfram rule

if nargin == 0 % Default values if none specified
    dist2 = -0.4;
    dist3 = -0.6;
    striped='off';
end

% If no striped value set then set to 'off'
if nargin == 2
    striped='off';
end

% Set all values to dist3 (7*7 grid, inner values replaced later)
kernel=ones(7)*dist3;

% Replace inner 5 rows/cols with dist2 value
kernel(2:end-1,2:end-1)=ones(5)*dist2; 

% Replace inner 3 rows/cols with 1s. Produces final values.
kernel(3:end-2,3:end-2)=ones(3);

% If striped, set ignored values to 0
% Horizontal
if strcmp(striped,'h') 
    kernel([1:14 end-13:end])=0;
end
% Vertical
if strcmp(striped,'v') 
    kernel([1:7:end-6 2:7:end-5 6:7:end-1 7:7:end])=0;
end