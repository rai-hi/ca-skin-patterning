function matrix = circle_matrix( matrix_size, fraction, x_ellipse, y_ellipse)
%CIRCLE_MATRIX Generates a matrix containing a circular region of 1s, used
%to generate kernels with circular neighbourhoods.
%   Inputs: 
%    matrix_size - Size of neighbourhood. Since output matrix is
%    square, value used for both x and y. 
%
%    fraction - Decimal value between 0 and 1 representing the proportion 
%    of the matrix that the circular region occupies. 
%
%    x_ellipse, y_ellipse - Decimal value between 0 and 1 representing
%    the scaling factor in the corresponding dimension, used for elliptical 
%    areas.
%
%   Output: matrix containing a circle/ellipse of 1s

% If ellipse values unspecified then make circle
if nargin==2
    x_ellipse=1;
    y_ellipse=1;
end

% Calculate mid point of the matrix
mid=((matrix_size-1)/2)+1;

% Calculate radius of circle
radius=fraction*(matrix_size/2);

% Initialise matrix
matrix=zeros(matrix_size);

% Create meshgrid containing all indexes for the matrix
[y x]=deal(1:matrix_size);
[X Y] = meshgrid(x,y);

% Using equation for an ellipse/circle, set all values within circle to 1.
% Circle centred at midpoint.
matrix(((X-mid).^2)/x_ellipse^2+((Y-mid).^2)/y_ellipse^2<radius^2)=1; 

end

