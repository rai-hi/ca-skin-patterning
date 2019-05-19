function validate_edit_numeric(hObject,set_value)
%VALIDATE_EDIT_NUMERIC Function that checks a text box value is numeric,
%and sets it to a default value if not. Returns an error message if invalid
%informing the user of what the value is changed to.
%
%   Inputs:
%    hObject - GUI object to be validated
%    set_value - (Optional) Value to set if invalid. Default is 1.

% If set value not specified
if nargin==1
    set_value='1';
end

% Display error message and set value if current value not numeric
if isnan(get_numeric(hObject))
    set(hObject,'String',set_value);
    errordlg(strcat({'Invalid value entered. Value set to '},set_value,'.'))
end

end

