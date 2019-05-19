function visualise_rule(conv_matrix)
%VISUALISE_RULE Displays a visual representation of the neighbourhood
%values
%   Normalises negative values so that they are visible on-screen, and
%   multiplies values by 30 to give better contrast between seperate
%   regions.

figure('Name','Rule shape');
image(sqrt(conv_matrix.^2)*30);
end

