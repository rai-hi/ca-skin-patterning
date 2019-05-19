function number = get_numeric( hObject )
%GET_NUMERIC Retrieve the value of a text box as a numeric value
%   Input:
%    hObject - GUI handle of the text box
%
%   Output: numeric version of text box string

number=str2double(get(hObject,'String'));

end

