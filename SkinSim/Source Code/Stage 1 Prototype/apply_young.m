function new_grid = apply_young( grid, act_range, inh_range, act_field, inh_field )
%APPLY_YOUNG Applies the Young model to a grid of binary cell states
 % Using bwdist to calculate the distance from the current cell to every
 % other, the two field areas are indexed and the sums calculated. 

if nargin==1
    act_range=2.5;
    inh_range=6;
    act_field=1;
    inh_field=-0.23;
end
    
 
new_grid=grid; % Initialise next states to be same as current
[cell dist field_value]=deal(zeros(size(grid)));

for x = 1:(size(grid,1))
    for y = 1:(size(grid,2))
        
        cell=zeros(size(grid)); % Create position grid empty
        cell(x,y)=1; % Set current position
        dist=bwdist(cell); % Build distances to each cell
        
        sum_act =size(grid((dist<=act_range)&(grid==1)),1); 
        %Get sum of DCs in activation area
        
        sum_inh =size(grid((dist<=inh_range)&(dist>act_range)&(grid==1)),1); 
        %Get sum of DCs in inhibition area
        
        field_value=(sum_act*act_field)+(sum_inh*inh_field);
        %Set field values based on neighbourhood sums
        
        if field_value>0
            new_grid(x,y)=1; % Positive sum cells set to alive
        elseif field_value<0
            new_grid(x,y)=0; % Negative sum cells set to dead
        end                 
    end
end

end


