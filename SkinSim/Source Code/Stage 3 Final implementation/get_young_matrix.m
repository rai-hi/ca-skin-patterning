function conv_matrix = get_young_matrix()
%GET_YOUNG_MATRIX Retrieve values from GUI and make a call to
%young_kernel() to generate the kernel.
%
%   Output: kernel of Young rule

% Get handles from current GUI figure
handles=guidata(gcf);

% Get each Young model parameter
actRange=get_numeric(handles.edit_act_range);
actField=get_numeric(handles.edit_act_field);
inhRange=get_numeric(handles.edit_inh_range);
inhField=get_numeric(handles.edit_inh_field);

% If striped checkbox ticked, also retrieve striping parameters
if get(handles.check_young_striped,'value')
    act_a=get_numeric(handles.edit_act_ellipse_a);
    act_b=get_numeric(handles.edit_act_ellipse_b);
    inh_a=get_numeric(handles.edit_inh_ellipse_a);
    inh_b=get_numeric(handles.edit_inh_ellipse_b);
else
    % Otherwise use default non-striped values
    [act_a,act_b,inh_a,inh_b]=deal(1); % If striped not ticked set all ellipse values to 1
end

% Generate kernel using retrieved values
conv_matrix=young_kernel(actRange,actField,act_a,act_b,inhRange,inhField,inh_a,inh_b); % Create young conv matrix

end

