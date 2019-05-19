
function varargout = young_gui_2(varargin)
% young_gui_2 M-file for young_gui_2.fig
%      young_gui_2, by itself, creates a new young_gui_2 or raises the existing
%      singleton*.
%
%      H = young_gui_2 returns the handle to a new young_gui_2 or the handle to
%      the existing singleton*.
%
%      young_gui_2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in young_gui_2.M with the given input arguments.
%
%      young_gui_2('Property','Value',...) creates a new young_gui_2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before young_gui_2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to young_gui_2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help young_gui_2

% Last Modified by GUIDE v2.5 01-May-2012 17:17:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @young_gui_2_OpeningFcn, ...
                   'gui_OutputFcn',  @young_gui_2_OutputFcn, ...
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


% --- Executes just before young_gui_2 is made visible.
function young_gui_2_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to young_gui_2 (see VARARGIN)

% Choose default command line output for young_gui_2
handles.output = hObject;

% Load playback button icons
i1 = imread('/PLAY.png');
i2 = imread('/FORWARD.png');
i3 = imread('/BACK.png');
set(handles.button_play,'cdata',i1)
set(handles.button_forward,'cdata',i2)
set(handles.button_back,'cdata',i3)

% Checks for existence of rule data file, creates if not. Stores other
% current variables and restores them after.
if exist('rules.mat','file')~=2 
    save('current')
    clear;
    save('rules');
    load('current');
    delete('current.mat');
end

% Set list box for initial conditions
conditions_list={'Random distribution';'Blank grid';};
set(handles.select_initial,'String',conditions_list);

% Set list box for rules on form load
set_rule_list();

% Set initial image state (random 10%)
grid=random_distribution(200,200,10);
handles.initial_grid=grid;
handles=create_states(handles); %#ok<NASGU>


function updated_handles = create_states(handles)
% Used to regenerate the states at each generation when a change is made to
% the grid or the rule used.

% Set number of generations, and set current to 1.
handles.generation=1;
handles.num_states=8;

% Get grid size
grid_size=size(handles.initial_grid);

% Create array of grids, one grid for each generation. Initialise to zeros.
handles.states=zeros(grid_size(1),grid_size(2),handles.num_states);

% Store initial grid to 1st space in array
handles.states(:,:,1)=handles.initial_grid;

% For each subsequent grid, apply the rule to the previous grid to get new
% states.
for i=1:handles.num_states-1
    handles.states(:,:,i+1)=apply_rule(handles.states(:,:,i),get_rule);
end

% Updated GUI handles stored to the GUI
updated_handles=handles;
guidata(gcf,updated_handles);

% Clear warning text box and hide apply changes button
set(handles.text_warning,'string','')
set(handles.button_apply,'visible','off')

%Set image to current (1st) state
set_state(updated_handles); 


function set_state(handles)
% Set the image on screen to the grid of the current generation

% Set the generation display to the current number
set(handles.label_generation,'String',strcat('Current generation: ',num2str(handles.generation)))

% Set the image to the current state
grid=handles.states(:,:,handles.generation);

% Set the on-screen display as the active image
axes(handles.grid_display);

% Draw the grid (*100 for contrast)
im=image(grid*100);

% Prevent the image from listening for mouse-clicks
set(im,'hittest','off')

% Reset the axes on-click function to as it was before (gets reset when
% image changed)
set(handles.grid_display, 'ButtonDownFcn', @(hObject, ev) grid_display_ButtonDownFcn(hObject, ev, handles))



function set_rule_list()
% Set list box for rules

% Get handles structure
handles = guidata(gcf);

% Get custom rules from file and their names
rules_data=load('rules.mat');
rule_names=fieldnames(rules_data);

% Concatenate default rule names with custom rules
default={'Young','Wolfram'};
set(handles.select_rule,'String',cat(1,default',rule_names));


function set_warning()
handles=guidata(gcf);
set(handles.button_apply,'visible','on')
set(handles.text_warning,'string', 'Warning: Values modified since creating the grid. Press create to store new values!')
rule_name=get_popup_string(handles.select_rule);
if strcmp(rule_name,'Wolfram')
    set(handles.button_apply,'position',[141 15 18 1.6] )
    set(handles.text_warning,'position',[124 17 53 2] )
else
    set(handles.button_apply,'position',[141 3.4 18 1.6] )
    set(handles.text_warning,'position',[124 5.4 53 2] )
end


%---Gets the values from the size text boxes/displays error
function [size_x, size_y] = get_size()

% Get handles
handles=guidata(gcf);

% Get size values
size_x=get(handles.edit_size_x,'String');
size_y=get(handles.edit_size_y,'String');

% Convert strings to doubles
size_x=str2double(size_x);
size_y=str2double(size_y);

% If non-numeric then set default size and show error message
if isnan(size_x) || isnan(size_y) || size_x>2000 || size_y>2000
    size_x=200;
    size_y=200;
    errordlg('Grid sizes must be numeric and <2000. Using default 200*200 values.','Non-Numeric Value','modal')
    uiwait
      return
end

% --- Outputs from this function are returned to the command line.
function varargout = young_gui_2_OutputFcn(hObject, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in button_play.
function button_play_Callback(hObject, ~, handles)
% Cycle through each generation of cells on-screen
for i=1:handles.num_states
    handles.generation=i;
    set_state(handles);
    guidata(hObject,handles);
    
    % Pause for a value dependent on button_play
    % speed slider value (controls speed, min. wait 0.1s)
    pause(2*(1-get(handles.slider_play_speed, 'value'))+0.1)
end
    
    
% --- Executes on button press in button_forward.
function button_forward_Callback(hObject, ~, handles)
% For pregenerated states.
if handles.generation+1 <= handles.num_states;
    handles.generation=handles.generation+1;
    set_state(handles);
    guidata(hObject,handles);
elseif handles.generation == handles.num_states;
    % If final state reached
    if ~isequal(handles.states(:,:,handles.generation),handles.states(:,:,handles.generation-1));
        % If previous two states were different (stability not reached),
        % increment num_states, compute next state, and change current
        % generation.
        updated_handles=handles;
        updated_handles.num_states=handles.num_states+1;
        updated_handles.states(:,:,handles.num_states+1)=apply_rule(handles.states(:,:,handles.num_states),get_rule);
        handles.generation=handles.generation+1;
        set_state(updated_handles);
        guidata(hObject,updated_handles);
    else
        % Previous two generations are same, so stability reached.
        errordlg('Pattern completely stable. No further generations!'...
            , 'No further generations', 'modal')
    end
end


% --- Executes on button press in button_back.
function button_back_Callback(hObject, ~, handles)
% Wont go lower than state 1
if handles.generation ~= 1
    handles.generation=handles.generation-1;
    set_state(handles);
    guidata(hObject,handles);
end


% --- Executes on button press in button_save_all.
function button_save_all_Callback(~, ~, handles)
% For each of the states
for i=1:handles.num_states
    % Store image file to Images/image_name#.png
    img_name=get(handles.edit_image_name,'string');
    file_name=strcat('Images/',img_name,num2str(i),'.png');
    imwrite(handles.states(:,:,i),file_name);
end


% --- Executes on button press in button_save_single.
function button_save_single_Callback(~, ~, handles)
% Store image file to Images/image_name.png
img_name=get(handles.edit_image_name,'string');
file_name=strcat('Images/',img_name,'.png');
imwrite(handles.states(:,:,handles.generation),file_name);


% --- Executes on button press in button_create.
function button_create_Callback(hObject, eventdata, handles)
% hObject    handle to button_create (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Called on pressing the create button
initial_condition = get_popup_string(handles.select_initial); 

[size_x size_y]=get_size(); % Get sizes of grid

switch initial_condition
    case 'Random distribution'
        % If random, validate percentage box and store value
        validate_edit_numeric(handles.edit_percentage,10);
        percentage=get_numeric(handles.edit_percentage);
        grid=random_distribution(size_x,size_y,percentage);
    case 'Blank grid'
        % If manual set grid to empty
        grid=zeros(size_x,size_y);
    otherwise
        errordlg('Invalid initial conditions')
        grid=zeros(size_x,size_y);
end

% Store initial grid and generate new states
handles.initial_grid=grid;
handles=create_states(handles);


% --- Toggle the state of a clicked cell
function toggle_cell(x,y)
% Get handles structure
handles=guidata(gcf);

% Only allow modifications to the initial grid
if (handles.generation==1)
    grid=handles.states(:,:,handles.generation);
    
    %Invert value
    grid(y,x)=~grid(y,x);
    
    % Set new initial grid and regenerate states
    handles.initial_grid=grid;
    handles=create_states(handles);
    
    % Update handles
    guidata(gcf,handles);
elseif handles.generation~=1
    % If not initial grid show error msg.
    errordlg('You can only modify cells on the initial grid','Cannot modify state','modal');
end


% --- Executes on mouse press over axes background.
function grid_display_ButtonDownFcn(hObject, ~, handles)
initial_method = get_popup_string(handles.select_initial);
% If the checkbox to toggle values is selected
if get(handles.checkbox_toggle,'value')
    % Get mouse location
    t=get(hObject,'currentpoint');
    
    % Round to nearest cell and toggle cell
    x=round(t(1,1));
    y=round(t(1,2));
    toggle_cell(x,y);
end

% --- Executes on selection change in select_colours.
function select_colours_Callback(hObject, ~, ~)
colour=get_popup_string(hObject);
switch colour
    case 'Blue/Red'
        colormap(jet)
    case 'Black/White'
        colormap(gray)
    case 'Pink/Yellow'
        colormap(spring)
    case 'Green/Yellow'
        colormap(summer)
    case 'Red/Yellow'
        colormap(autumn)
    case 'Blue/Green'
        colormap(winter)
    case 'Black/Yellow'
        colormap(copper)
end


% --- Executes on selection change in select_initial.
function select_initial_Callback(hObject, eventdata, handles)
% hObject    handle to select_initial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns select_initial contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_initial

% Disable/enable the initial percentage text depending on initial method
contents = get(hObject,'Value');
if contents~=1
    set(handles.edit_percentage,'enable','off')
    set(handles.initial_label,'enable','off')
else
    set(handles.edit_percentage,'enable','on')
    set(handles.initial_label,'enable','on')
end


% --- Executes on button press in save_initial.
function save_initial_Callback(~, ~, handles)
% Show input box for filename, and get initial grid. Save to file.
user_name=inputdlg('Enter a filename to save the initial condition as');
filename=genvarname(user_name{1});
init=handles.initial_grid;
string=strcat('Initial Conditions/',filename,'.mat');
save(string,'init');


% --- Executes on button press in load_initial.
function load_initial_Callback(~, ~, handles)
% Show file chooser dialog to select initial rules
filename=uigetfile( 'Initial Conditions/*.mat');
grid=load(strcat('Initial Conditions/',filename),'init');

% Set initial grid to loaded file and generate new states
handles.initial_grid=grid.init;
handles=create_states(handles);


% --- Executes on button press in button_apply.
function button_apply_Callback(hObject, eventdata, handles)
% hObject    handle to button_apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=create_states(handles);


% --- Executes on button press in check_young_striped.
function check_young_striped_Callback(hObject, eventdata, handles)
% hObject    handle to check_young_striped (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% If Young striped checkbox ticked enable striping options. Otherwise
% disable.
if get(hObject,'value')
    set(handles.edit_act_ellipse_a,'enable','on')
    set(handles.edit_act_ellipse_b,'enable','on')
    set(handles.edit_inh_ellipse_a,'enable','on')
    set(handles.edit_inh_ellipse_b,'enable','on')
    set(handles.slider_act_ellipse_a,'enable','on')
    set(handles.slider_act_ellipse_b,'enable','on')
    set(handles.slider_inh_ellipse_a,'enable','on')
    set(handles.slider_inh_ellipse_b,'enable','on')
else
    set(handles.edit_act_ellipse_a,'enable','off')
    set(handles.edit_act_ellipse_b,'enable','off')
    set(handles.edit_inh_ellipse_a,'enable','off')
    set(handles.edit_inh_ellipse_b,'enable','off')
    set(handles.slider_act_ellipse_a,'enable','off')
    set(handles.slider_act_ellipse_b,'enable','off')
    set(handles.slider_inh_ellipse_a,'enable','off')
    set(handles.slider_inh_ellipse_b,'enable','off')
end
set_warning();


% --- Executes on button press in check_wolfram_striped.
function check_wolfram_striped_Callback(hObject, eventdata, handles)
% hObject    handle to check_wolfram_striped (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_wolfram_striped

% If Wolfram striped checkbox ticked enable striping options. Otherwise
% disable. 
if get(hObject,'Value')
    set(handles.radio_wolfram_horizontal,'enable','on')
    set(handles.radio_wolfram_vertical,'enable','on')
    set(handles.edit_dist2,'String','-0.7')
    set(handles.edit_dist3,'String','-0.7')
else
    set(handles.radio_wolfram_horizontal,'enable','off')
    set(handles.radio_wolfram_vertical,'enable','off')
    set(handles.edit_dist2,'String','-0.4')
    set(handles.edit_dist3,'String','-0.4')
end
set_warning();


% --- Executes on selection change in select_rule.
function select_rule_Callback(hObject, ~, handles)
% hObject    handle to select_rule (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns select_rule contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_rule

% When rule is changed, create states and update display
handles=create_states(handles);

% Get current window location (will be altered for rules which have
% additional parameter panel)
current_pos=get(handles.figure1,'position');

current_rule=get_popup_string(hObject);

button_pos=get(handles.button_save_custom,'position');

if strcmp(current_rule,'Wolfram')
    % Extend display to show parameter panel
    current_pos(3)=183;
    set(handles.figure1,'position',current_pos)
    
    % Hide Young panel and show Wolfram panel. Move 'save as custom' button
    % and warning message.
    set(handles.panel_young,'visible','off')
    set(handles.panel_wolfram,'visible','on')
    
    button_pos(2)=20.46;
    set(handles.button_save_custom,'position',button_pos)

elseif strcmp(current_rule,'Young')
    % Extend display to show parameter panel
    current_pos(3)=183;
    set(handles.figure1,'position',current_pos)
    
    % Hide Wolfram panel and show Young panel. Move 'save as custom' button
    % and warning message.
    set(handles.panel_young,'visible','on')
    set(handles.panel_wolfram,'visible','off')
    
    button_pos(2)=9;
    set(handles.button_save_custom,'position',button_pos)
else
    % Otherwise reduce size and hide parameter panel
    current_pos(3)=122;
    set(handles.figure1,'position',current_pos)
end


% --- Executes on button press in button_save_custom.
function button_save_custom_Callback(hObject, eventdata, handles)
% hObject    handle to button_save_custom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Show dialog to get file name. Generate a valid variable name from input,
% and store rule kernel as a variable of the specified name. Save to
% rules.mat.
rule_name=inputdlg('Choose a rule name');
rule_name=genvarname(rule_name{1});
rule_data=get_rule();
eval(strcat(rule_name,'=rule_data'));
save('rules',rule_name,'-append');

% Update rule dropdown to include new rule
set(handles.select_rule,'string',...
        cat(1,get(handles.select_rule,'String'),rule_name))
    
% --- Executes on button press in button_custom.
function button_custom_Callback(hObject, eventdata, handles)
% hObject    handle to button_custom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Calls the rule editor screen
rule_creator('main', handles.figure1);

    
    % ---------------------------------------------------------------------
    % ---------------------------------------------------------------------
    % ---------------------------------------------------------------------
    % FOLLOWING CODE CONSISTS OF SETUP & VALIDATION CODE FOR EACH COMPONENT
    % ---------------------------------------------------------------------
    % ---------------------------------------------------------------------
    % ---------------------------------------------------------------------
    
    
% --- Executes during object creation, after setting all properties.
function select_rule_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_rule (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function select_initial_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_initial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_percentage_Callback(hObject, eventdata, handles)
% hObject    handle to edit_percentage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_percentage as text
%        str2double(get(hObject,'String')) returns contents of edit_percentage as a double
validate_edit_numeric(hObject,'10')


% --- Executes during object creation, after setting all properties.
function edit_percentage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_percentage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function slider_play_speed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_play_speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function select_colours_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_colours (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_size_x_Callback(hObject, eventdata, handles)
% hObject    handle to edit_size_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_size_x as text
%        str2double(get(hObject,'String')) returns contents of edit_size_x as a double

validate_edit_numeric(hObject,'200');


% --- Executes during object creation, after setting all properties.
function edit_size_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_size_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_size_y_Callback(hObject, eventdata, handles)
% hObject    handle to edit_size_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_size_y as text
%        str2double(get(hObject,'String')) returns contents of edit_size_y as a double

validate_edit_numeric(hObject,'200');


% --- Executes during object creation, after setting all properties.
function edit_size_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_size_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit_image_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_image_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_inh_field_Callback(hObject, eventdata, handles)
% hObject    handle to edit_inh_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_inh_field as text
%        str2double(get(hObject,'String')) returns contents of edit_inh_field as a double
validate_edit_numeric(hObject,'-0.2')
set_warning();


% --- Executes during object creation, after setting all properties.
function edit_inh_field_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_inh_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_inh_range_Callback(hObject, eventdata, handles)
% hObject    handle to edit_inh_range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_inh_range as text
%        str2double(get(hObject,'String')) returns contents of edit_inh_range as a double
validate_edit_numeric(hObject,'6')
set_warning();


% --- Executes during object creation, after setting all properties.
function edit_inh_range_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_inh_range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_inh_ellipse_a_Callback(hObject, eventdata, handles)
% hObject    handle to edit_inh_ellipse_a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_inh_ellipse_a as text
%        str2double(get(hObject,'String')) returns contents of edit_inh_ellipse_a as a double
validate_slider_edit(hObject)
set(handles.slider_inh_ellipse_a,'value',get_numeric(hObject));
set_warning();


% --- Executes during object creation, after setting all properties.
function edit_inh_ellipse_a_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_inh_ellipse_a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_inh_ellipse_b_Callback(hObject, eventdata, handles)
% hObject    handle to edit_inh_ellipse_b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_inh_ellipse_b as text
%        str2double(get(hObject,'String')) returns contents of edit_inh_ellipse_b as a double
validate_slider_edit(hObject)
set(handles.slider_inh_ellipse_b,'value',get_numeric(hObject));
set_warning();


% --- Executes during object creation, after setting all properties.
function edit_inh_ellipse_b_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_inh_ellipse_b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_inh_ellipse_b_Callback(hObject, eventdata, handles)
% hObject    handle to slider_inh_ellipse_b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.edit_inh_ellipse_b,'String',get(hObject,'Value'))
set_warning();


% --- Executes during object creation, after setting all properties.
function slider_inh_ellipse_b_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_inh_ellipse_b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_inh_ellipse_a_Callback(hObject, eventdata, handles)
% hObject    handle to slider_inh_ellipse_a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.edit_inh_ellipse_a,'String',get(hObject,'Value'))
set_warning();


% --- Executes during object creation, after setting all properties.
function slider_inh_ellipse_a_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_inh_ellipse_a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function edit_act_field_Callback(hObject, eventdata, handles)
% hObject    handle to edit_act_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_act_field as text
%        str2double(get(hObject,'String')) returns contents of edit_act_field as a double
validate_edit_numeric(hObject,'1')
set_warning();


% --- Executes during object creation, after setting all properties.
function edit_act_field_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_act_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_act_range_Callback(hObject, ~, ~)
% hObject    handle to edit_act_range (see GCBO)
validate_edit_numeric(hObject,'2.5')

% Pauses execution to wait for main form to regain control, so that
% set_warning is 'looking' at correct form
uiwait
set_warning();


% --- Executes during object creation, after setting all properties.
function edit_act_range_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_act_range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_act_ellipse_a_Callback(hObject, eventdata, handles)
% hObject    handle to edit_act_ellipse_a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_act_ellipse_a as text
%        str2double(get(hObject,'String')) returns contents of edit_act_ellipse_a as a double
validate_slider_edit(hObject)
set(handles.slider_act_ellipse_a,'value',get_numeric(hObject));
set_warning();


% --- Executes during object creation, after setting all properties.
function edit_act_ellipse_a_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_act_ellipse_a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_act_ellipse_b_Callback(hObject, eventdata, handles)
% hObject    handle to edit_act_ellipse_b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_act_ellipse_b as text
%        str2double(get(hObject,'String')) returns contents of edit_act_ellipse_b as a double
validate_slider_edit(hObject)
set(handles.slider_act_ellipse_b,'value',get_numeric(hObject));
set_warning();


% --- Executes during object creation, after setting all properties.
function edit_act_ellipse_b_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_act_ellipse_b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_act_ellipse_b_Callback(hObject, eventdata, handles)
% hObject    handle to slider_act_ellipse_b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.edit_act_ellipse_b,'String',get(hObject,'Value'))
set_warning();


% --- Executes during object creation, after setting all properties.
function slider_act_ellipse_b_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_act_ellipse_b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_act_ellipse_a_Callback(hObject, eventdata, handles)
% hObject    handle to slider_act_ellipse_a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.edit_act_ellipse_a,'String',get(hObject,'Value'))
set_warning();


% --- Executes during object creation, after setting all properties.
function slider_act_ellipse_a_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_act_ellipse_a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in button_preview.
function button_preview_Callback(hObject, eventdata, handles)
% hObject    handle to button_preview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
visualise_rule(get_rule());


function edit_dist2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dist2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dist2 as text
%        str2double(get(hObject,'String')) returns contents of edit_dist2 as a double
validate_edit_numeric(hObject,'-0.4')
set_warning();


% --- Executes during object creation, after setting all properties.
function edit_dist2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dist2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_dist3_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dist3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dist3 as text
%        str2double(get(hObject,'String')) returns contents of edit_dist3 as a double
validate_edit_numeric(hObject,'-0.4')
set_warning();


% --- Executes during object creation, after setting all properties.
function edit_dist3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dist3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in panel_wolfram_striped.
function panel_wolfram_striped_SelectionChangeFcn(~, ~, ~)
% hObject    handle to the selected object in panel_wolfram_striped 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
set_warning();
