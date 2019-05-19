function kernel = young_kernel(act_range,act_field,act_a,act_b,inh_range,inh_field,inh_a,inh_b)
%YOUNG_KERNEL Creates a convolution kernel for the Young model.
%
%   Uses circle_matrix to generate a kernel representing Young model. If
%   called without parameters then default values used.
%
%   Inputs:
%    act_range - Range of the activator
%    act_field - Field value of the activator
%    act_a - Elliptical scaling value for activator X axis (0-1)
%    act_b - Elliptical scaling value for activator Y axis (0-1)
%    inh_range - Range of the inhibitor
%    inh_field - Field value of the inhibitor (negative value)
%    inh_a - Elliptical scaling value for inhibitor X axis (0-1)
%    inh_b - Elliptical scaling value for inhibitor Y axis (0-1)
%
%   Output: convolution kernel of neighbourhood

% Set default values 
if nargin<8
    act_field=1;
    inh_field=-0.24;
    act_range=2.3;
    inh_range=6;
    [act_a act_b inh_a inh_b]=deal(1);
end

% Kernel size is double the radius, plus the centre value. The radius is
% rounded upwards to the nearest integer so that decimal values can be used
% in the inhibitor range.
kernel_size=ceil(inh_range)*2+1;

% Initialise kernel
kernel=zeros(kernel_size);

% Get two index matrixes
activator_circle=circle_matrix(kernel_size,(inh_range*2+1)/kernel_size,inh_a,inh_b);
inhibitor_circle=circle_matrix(kernel_size,(act_range*2+1)/kernel_size,act_a,act_b);

% Using the index matrixes, the final kernel matrix is indexed and
% appropriate values set.
kernel(activator_circle==1)=inh_field;
kernel(inhibitor_circle==1)=act_field;

end