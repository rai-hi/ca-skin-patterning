function  display_grid( grid )
%DISPLAY_GRID Takes a matrix of cell states and displays them onscreen
colormap(jet); % Sets the colours to use
image(grid*100); % Displays the image (*100 for increased contrast)

% Set the unit size to be the same in each direction, and fit the plot box
% around the data
axis image; 

end

