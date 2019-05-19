function string = get_popup_string(hObject)
%GET_POPUP_STRING Get the current selected string in a popup menu
%   Input:
%    hObject - GUI handle to a popup menu
%
%   Output: currently selected string from popup box

% Get all strings from popup
contents = cellstr(get(hObject,'String'));

% Get current selected string from list of strings
string=contents{get(hObject,'Value')};

end

