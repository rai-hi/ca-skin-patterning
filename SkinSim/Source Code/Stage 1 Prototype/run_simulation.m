function run_simulation( time, size_x, size_y, act_range, act_field, inh_range, inh_field)
%RUN_SIMULATION Top level function which iteratively updates grid and
%displays at each step

if nargin==1 % If only time specified, use default values
    [size_x size_y]=deal(50); % Set both values to 50
    act_range=2.3;
    act_field=1;
    inh_range=6.01;
    inh_field=0.24;
end

plot_height=ceil(time/2); % Set number of rows of plots
    
grid=random_distribution(size_x, size_y,10); % Initial grid

for i=1:time
    subplot(plot_height,2,i); % Set current plot area
    display_grid(grid)
    imwrite(imresize(grid,4),strcat('image',num2str(i),'.png'))
    grid=apply_young(grid, act_range, inh_range, act_field, inh_field ); 
    % Update by young rule
    
end

figure % Create new, seperate display for final image
display_grid(grid) % Draw final grid onto seperate image

end

