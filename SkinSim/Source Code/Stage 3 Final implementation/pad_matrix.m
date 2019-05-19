function padded = pad_matrix( grid,conv )
%PADMATRIX Add padded border to CA grid with wrap-around values.
%   
%   Padded border size is set depending on the size of the convolution
%   matrix, in order to ensure every cell has a full neighbourhood.
%
%   Inputs:
%    grid - CA grid to be padded
%    conv - convolution matrix to be used (used to get size of border)
%
%   Output: wrap-around padded version of grid

% Set padding size
border_size=(size(conv)-1)/2;

% Call function to pad grid with the specified size
padded=padarray(grid,border_size,'circular');
end