function varargout = rule_creator(varargin)
% RULE_CREATOR MATLAB code for rule_creator.fig
%      RULE_CREATOR, by itself, creates a new RULE_CREATOR or raises the existing
%      singleton*.
%
%      H = RULE_CREATOR returns the handle to a new RULE_CREATOR or the handle to
%      the existing singleton*.
%
%      RULE_CREATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RULE_CREATOR.M with the given input arguments.
%
%      RULE_CREATOR('Property','Value',...) creates a new RULE_CREATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rule_creator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rule_creator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rule_creator

% Last Modified by GUIDE v2.5 25-Apr-2012 19:47:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rule_creator_OpeningFcn, ...
                   'gui_OutputFcn',  @rule_creator_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before rule_creator is made visible.
function rule_creator_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rule_creator (see VARARGIN)

mainGuiInput = find(strcmp(varargin, 'main'));
% Remember the handle which called the rule creator
if (~isempty(mainGuiInput))
    handles.main = varargin{mainGuiInput+1};
end

% Choose default command line output for rule_creator
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes rule_creator wait for user response (see UIRESUME)
% uiwait(handles.figure1);

set(handles.table_kernel, 'ColumnWidth', {40});
set(handles.table_kernel, 'Data', zeros(11));
set(handles.table_kernel, 'ColumnEditable', true(1,11));

% Populate rule list with custom rule names
rules_data=load('rules.mat');
rule_names=fieldnames(rules_data);
set(handles.select_rule,'String',rule_names);

% --- Outputs from this function are returned to the command line.
function varargout = rule_creator_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in button_create_kernel.
function button_create_kernel_Callback(~, ~, handles)
% handles    structure with handles and user data (see GUIDATA)

% Get size from text box
rule_size=get_numeric(handles.edit_neighbourhood_size);

% If even grid size (no centre-point)
if mod(rule_size,2)~=1
    % Make size 1 bigger (odd) and show message.
    rule_size=rule_size+1;
    msg={'Neighbourhood size must be odd to have a centre point. Neighbourhood size set to '}
    errordlg(strcat(msg,num2str(rule_size),'.'))
end

% Set table to show new data, let each cell be editable
set(handles.table_kernel, 'data', zeros(rule_size,rule_size));
set(handles.table_kernel, 'ColumnEditable', true(1,rule_size));


% --- Executes on button press in button_load_existing.
function button_load_existing_Callback(~, ~, handles)
% handles    structure with handles and user data (see GUIDATA)

% Retrieve the kernel based upon the rule selected in the dropdown
kernel=get_rule();

% Set table to corresponding kernel
format short;
set(handles.table_kernel,'data',kernel);
set(handles.table_kernel, 'ColumnWidth', {40});


% --- Executes on button press in button_gen_circle.
function button_gen_circle_Callback(~, ~, handles)
% handles    structure with handles and user data (see GUIDATA)

% Get current kernel values
data=get(handles.table_kernel,'data');

% Retrieve parameters necessary for circle_matrix
grid_size=size(data,1);
circle_size=get_numeric(handles.edit_circle_size);
cell_value=get_numeric(handles.edit_field_value);
replace_value=get_numeric(handles.edit_replace);
x_ellipse=get_numeric(handles.edit_x_ellipse);
y_ellipse=get_numeric(handles.edit_y_ellipse);

% Call circle matrix with parameters, multiply by field value
circle=circle_matrix(grid_size,circle_size,x_ellipse,y_ellipse)*cell_value;

% If overwrite checkbox is set then only replace the specified values
if get(handles.checkbox_replace,'value')
    data(data==replace_value & circle~=0)...
        =circle(data==replace_value & circle~=0);
else
    % Otherwise only insert values from circle which aren't 0
    data(circle~=0)=circle(circle~=0);
end
set(handles.table_kernel,'data',data);


% --- Executes on button press in button_save.
function button_save_Callback(~, ~, handles)
% handles    structure with handles and user data (see GUIDATA)

% Input shown for name to save rule as. Genvarname generates a valid name
% from this, and save file into rules.mat
rule_name=inputdlg('Choose a rule name');
rule_name=genvarname(rule_name{1});
rule_data=get(handles.table_kernel, 'data');
eval(strcat(rule_name,'=rule_data'));
save('rules',rule_name,'-append');
set(handles.select_rule,'String',...
    cat(1,get(handles.select_rule,'String'),rule_name))

% Obtain handles using GUIDATA with the caller's handle, and refresh the
% main page's rule list if it is open. If not, open main page.
if isfield(handles,'main')
    mainHandles = guidata(handles.main);
    set(mainHandles.select_rule,'string',...
        cat(1,get(mainHandles.select_rule,'String'),rule_name))
else
    skin_gui
end


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get current window positions, set consistent height
screen_pos=get(handles.figure1, 'position');
screen_pos(4)=519;
set(handles.figure1, 'position',screen_pos)

% Get width of window
right=screen_pos(3);

% Set new width of table
current_table=get(handles.table_kernel,'position');
current_table(3)=right-290;
set(handles.table_kernel,'position',current_table)


% --- Executes on button press in checkbox_replace.
function checkbox_replace_Callback(hObject, ~, handles)
% hObject    handle to checkbox_replace (see GCBO)
% handles    structure with handles and user data (see GUIDATA)

% Enables/disables the overwrite value text box depending on checkbox state
if get(hObject,'Value')
    set(handles.edit_replace,'Enable','on');
else
    set(handles.edit_replace,'Enable','off');
end


function button_visualise_Callback(~, ~, handles)
current_rule=get(handles.table_kernel,'data');
visualise_rule(current_rule);


function edit_circle_size_Callback(hObject, ~, handles)
% hObject    handle to edit_circle_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_circle_size as text
%        str2double(get(hObject,'String')) returns contents of edit_circle_size as a double

validate_slider_edit(hObject)
set(handles.slider_circle,'value',get_numeric(hObject));


    % ---------------------------------------------------------------------
    % ---------------------------------------------------------------------
    % ---------------------------------------------------------------------
    % FOLLOWING CODE CONSISTS OF SETUP & VALIDATION CODE FOR EACH COMPONENT
    % ---------------------------------------------------------------------
    % ---------------------------------------------------------------------
    % ---------------------------------------------------------------------



% --- Executes during object creation, after setting all properties.
function edit_circle_size_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_circle_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit_field_value_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_field_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_y_ellipse_Callback(hObject, ~, handles)
% hObject    handle to edit_y_ellipse (see GCBO)
% handles    structure with handles and user data (see GUIDATA)

% Validate the inputted value and then set the slider to match
validate_slider_edit(hObject)
set(handles.slider_y,'value',get_numeric(hObject));


% --- Executes during object creation, after setting all properties.
function edit_y_ellipse_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_y_ellipse (see GCBO)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit_x_ellipse_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_x_ellipse (see GCBO)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit_replace_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_replace (see GCBO)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_x_ellipse_Callback(hObject, ~, handles)
% hObject    handle to edit_x_ellipse (see GCBO)
% handles    structure with handles and user data (see GUIDATA)

% Validate the inputted value and then set the slider to match
validate_slider_edit(hObject)
set(handles.slider_x,'value',get_numeric(hObject));


% --- Executes on slider movement.
function slider_circle_Callback(hObject, ~, handles)
% hObject    handle to slider_circle (see GCBO)
% handles    structure with handles and user data (see GUIDATA)

% Set the corresponding text box value to match the slider when value
% changed
set(handles.edit_circle_size,'String',get(hObject,'Value'))


% --- Executes during object creation, after setting all properties.
function slider_circle_CreateFcn(hObject, ~, ~)
% hObject    handle to slider_circle (see GCBO)

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_x_Callback(hObject, ~, handles)
% hObject    handle to slider_x (see GCBO)
% handles    structure with handles and user data (see GUIDATA)

% Set the corresponding text box value to match the slider when value
% changed
set(handles.edit_x_ellipse,'String',get(hObject,'Value'))


% --- Executes during object creation, after setting all properties.
function slider_x_CreateFcn(hObject, ~, ~)
% hObject    handle to slider_x (see GCBO)
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_y_Callback(hObject, ~, handles)
% hObject    handle to slider_y (see GCBO)
% handles    structure with handles and user data (see GUIDATA)

% Set the corresponding text box value to match the slider when value
% changed
set(handles.edit_y_ellipse,'String',get(hObject,'Value'))


% --- Executes during object creation, after setting all properties.
function slider_y_CreateFcn(hObject, ~, ~)
% hObject    handle to slider_y (see GCBO)

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function edit_replace_Callback(hObject, ~, ~)
% hObject    handle to edit_replace (see GCBO)
validate_edit_numeric(hObject,'0')


function edit_field_value_Callback(hObject, ~, ~)
% hObject    handle to edit_field_value (see GCBO)
validate_edit_numeric(hObject)


function edit_neighbourhood_size_Callback(hObject, ~, ~)
% hObject    handle to edit_neighbourhood_size (see GCBO)
validate_edit_numeric(hObject,'8')


% --- Executes during object creation, after setting all properties.
function select_rule_CreateFcn(hObject, ~, ~)
% hObject    handle to select_rule (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit_neighbourhood_size_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_neighbourhood_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
