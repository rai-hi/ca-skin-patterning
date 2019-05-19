function kernel = get_rule()
%GET_RULE Returns the kernel of the currently selected rule
%
%   Output: convolution kernel of rule currently selected in GUI

handles=guidata(gcf);
selected_rule=get_popup_string(handles.select_rule);
switch selected_rule % Case statements for default-specific rules and custom rules in otherwise
    case 'Young'
        kernel=get_young_matrix();
    case 'Wolfram'
        kernel=get_wolfram_matrix();
    otherwise
        % Load matrix from rules.mat if not custom
         kernel=cell2mat(struct2cell(load('rules.mat',selected_rule)));
end