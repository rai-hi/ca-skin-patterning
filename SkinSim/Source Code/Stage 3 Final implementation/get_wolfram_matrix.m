function conv_matrix = get_wolfram_matrix()
%GET_WOLFRAM_MATRIX Retrieve values from GUI and make a call to
%wolfram_kernel() to generate the kernel.
%
%   Output: kernel of Wolfram rule

% Get handles from current GUI figure
handles=guidata(gcf);

% Get both wolfram parameter values
dist2=get_numeric(handles.edit_dist2);
dist3=get_numeric(handles.edit_dist3);

% If striped checkbox ticked, set striped string to be either horizontal or
% vertical, depending on which radio button is selected
if get(handles.check_wolfram_striped,'value')
    if get(handles.radio_wolfram_horizontal,'value')
        % Generate kernel (horizontal stripes)
        conv_matrix=wolfram_kernel(dist2,dist3,'h');
    else
        % Generate kernel (vertical stripes)
        conv_matrix=wolfram_kernel(dist2,dist3,'v');
    end
else
    % Otherwise generate kernel (no stripes)
    conv_matrix=wolfram_kernel(dist2,dist3);
end

end

