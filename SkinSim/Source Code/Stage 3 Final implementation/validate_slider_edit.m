function validate_slider_edit(hObject)
%VALIDATE_SLIDER_EDIT Validation function for text boxes linked to a slider
%
%   Firstly checks value is numeric, and then checks slider value is not
%   out of range. If value is less than the the slider's minimum, it is set
%   to 0. If it is greater than the maximum, it is set to 1.
%
%   Input: hObject - the GUI object to be vaidated

% Check value is numeric
validate_edit_numeric(hObject)

% Get numeric value
slider_value=get_numeric(hObject);

% Check value is within slider min and max values and set if not
if  slider_value > 1
    set(hObject,'String','1');
end

if slider_value < 0
    set(hObject,'String','0');
end

end

