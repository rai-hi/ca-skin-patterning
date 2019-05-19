function run_simulation(time,size_x,size_y,act_range,act_field,act_a,act_b,inh_range,inh_field,inh_a,inh_b)
%RUN_SIMULATION Top level function which iteratively updates grid and
%displays at each step

% If only time parameter specified, use default values
if nargin==1 
    % Set size values to 200
    [size_x size_y]=deal(377);
   
    % Set ellipse values to 1
    [act_a act_b inh_a inh_b]=deal(1); 
    
    %Set model parameters
    act_range=2.3;
    act_field=1;
    inh_range=6;
    inh_field=-0.22;
end

plot_height=ceil(time/2); % Set number of rows of plots

grid=random_distribution(size_x, size_y,10); % Initial grid

for i=1:time
    % Set current plot area and display current grid in it
    subplot(plot_height,2,i); 
    display_grid(grid)
    
    % Generate convolution matrix for Young model
  	conv=young_kernel(act_range,act_field,act_a,act_b,inh_range,inh_field,inh_a,inh_b);
    
    % Update by young rule
    grid=apply_rule(grid,conv);
end

figure % Create new, separate display for final image
display_grid(grid) % Draw final grid onto separate image
end