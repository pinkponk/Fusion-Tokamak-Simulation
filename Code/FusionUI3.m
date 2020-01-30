function varargout = FusionUI3(varargin)
% FUSIONUI3 MATLAB code for FusionUI3.fig
%      FUSIONUI3, by itself, creates a new FUSIONUI3 or raises the existing
%      singleton*.
%
%      H = FUSIONUI3 returns the handle to a new FUSIONUI3 or the handle to
%      the existing singleton*.
%
%      FUSIONUI3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FUSIONUI3.M with the given input arguments.
%
%      FUSIONUI3('Property','Value',...) creates a new FUSIONUI3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FusionUI3_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FusionUI3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FusionUI3

% Last Modified by GUIDE v2.5 29-May-2016 11:46:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FusionUI3_OpeningFcn, ...
                   'gui_OutputFcn',  @FusionUI3_OutputFcn, ...
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

% --- Executes just before FusionUI3 is made visible.
function FusionUI3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FusionUI3 (see VARARGIN)


%% Setting up handles
handles.currentTimeStep = 1;
handles.contRunningSim = 0;
handles.startTime = -12;
%% Get Data
mode = 0;
animateModes = 0;

if mode == 0
    %Get local data   
%    load('plot_shot_new','-mat')
%    load('plot_br_signals','-mat')

   load('Test8_25742','-mat')
   
   handles.plas_curr = plas_curr;
   handles.plas_curr_tm = plas_curr_tm;
   handles.loop_volt_tor = loop_volt_tor;
   handles.loop_volt_tor_tm = loop_volt_tor_tm;
   handles.btor_ave = btor_ave;
   handles.btor_ave_tm = btor_ave_tm;
   handles.btor_tfc = btor_tfc;
   handles.btor_tfc_tm = btor_tfc_tm;
   
   handles.N_coil = N_coil;
   handles.N_time = N_time;
   handles.theta = theta;
   handles.phi = phi;
   handles.time = time;
   handles.brad_A = brad_A;
   handles.brad_B = brad_B;

   
   
else
    %Get data from network
    prompt = {'Shot number:'};
    titl = 'Run parameters';
    lines = 1;
    answer = inputdlg(prompt, titl, lines);
    shot_number = str2double(answer{1});
    
    
    [handles.N_coil, handles.N_time, handles.theta, handles.phi, handles.time, handles.brad_A, handles.brad_B] = ...
            read_br_signals( shot_number);
   
   % mdsip server at KTH-5717
    mdsconnect( '130.237.45.47');

    mdsopen( 'T2R', shot_number);

    handles.plas_curr = mdsvalue( '\gbl_itor_pla');
    handles.plas_curr_tm = mdsvalue( 'dim_of( \gbl_itor_pla)');

    handles.loop_volt_tor = mdsvalue( '\gbl_vtor_lin');
    handles.loop_volt_tor_tm = mdsvalue( 'dim_of( \gbl_vtor_lin)');

    handles.btor_ave = 1e3 * mdsvalue( '\gbl_btor_ave');
    handles.btor_ave_tm = mdsvalue( 'dim_of( \gbl_btor_ave)');

    handles.btor_tfc = 1e3 * mdsvalue( '\gbl_btor_tfc');
    handles.btor_tfc_tm = mdsvalue( 'dim_of( \gbl_btor_tfc)');

    mdsclose;
   
end

% Choose default command line output for FusionUI3
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using FusionUI3.
if strcmp(get(hObject,'Visible'),'off')
    plot(rand(5));
end

% UIWAIT makes FusionUI3 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FusionUI3_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on slider movement.
function time_slider_Callback(hObject, eventdata, handles)
% hObject    handle to time_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.currentTimeStep = round(get(hObject,'Value'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function time_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.maxCurrentTimeStep = round(8000/5);
set(hObject,'Min',1)
set(hObject,'Max',handles.maxCurrentTimeStep)
set(hObject,'Value',1)
guidata(hObject, handles);

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in play_button.
function play_button_Callback(hObject, eventdata, handles)
% hObject    handle to play_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.contRunningSim = 1;
set(handles.play_button,'UserData',1)
set(handles.runningStatus,'String','Running')


while get(handles.play_button,'UserData')==1
    

    
    simDataToBeProcessed = pickOutData(handles);
    

    if simDataToBeProcessed.currentTimeStep >= handles.maxCurrentTimeStep
        set(handles.play_button,'UserData',0);
        handles.currentTimeStep = handles.maxCurrentTimeStep;
        set(handles.runningStatus,'String','Stopped')
    else
        handles.currentTimeStep = simDataToBeProcessed.currentTimeStep;
    end
    guidata(hObject, handles);
    
    axes(handles.main_axis)
    contents = cellstr(get(handles.main_axis_popup,'String'));
    RunSimulationIncrement(simDataToBeProcessed,contents{get(handles.main_axis_popup,'Value')})
    
    axes(handles.lower_axis)
    contents = cellstr(get(handles.lower_popup,'String'));
    plotHelpPlot(contents{get(handles.lower_popup,'Value')},simDataToBeProcessed,handles)
    
    axes(handles.upper_axis)
    contents = cellstr(get(handles.upper_popup,'String'));
    plotHelpPlot(contents{get(handles.upper_popup,'Value')},simDataToBeProcessed,handles)
    
    set(handles.timeText,'String',['Time step: ' num2str(handles.currentTimeStep)])
    set(handles.timeText2,'String',['Time [ms]: ' num2str((handles.currentTimeStep)/10-12)])
    set(handles.amp_boost_value,'String',[num2str(get(handles.amp_boost,'Value')) 'X'])
    
    set(handles.time_slider,'Value',handles.currentTimeStep)
    pause(0.05)
    
    disp('========')
            disp(get(handles.time_slider,'Min'))
        disp(get(handles.time_slider,'Max'))
       disp(get(handles.time_slider,'Value'))
end



% --- Executes on button press in pause_button.
function pause_button_Callback(hObject, eventdata, handles)
% hObject    handle to pause_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.play_button,'UserData',0)
set(handles.runningStatus,'String','Stopped')
% guidata(hObject, handles);

% --- Executes on selection change in upper_popup.
function upper_popup_Callback(hObject, eventdata, handles)
% hObject    handle to upper_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns upper_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from upper_popup


% --- Executes during object creation, after setting all properties.
function upper_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to upper_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lower_popup.
function lower_popup_Callback(hObject, eventdata, handles)
% hObject    handle to lower_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lower_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lower_popup

% --- Executes during object creation, after setting all properties.
function lower_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lower_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in main_axis_popup.
function main_axis_popup_Callback(hObject, eventdata, handles)
% hObject    handle to main_axis_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% contents = cellstr(get(main_axis_popup,'String'));
% 
% if contents{get(main_axis_popup,'Value')} == 'Freq modes'
%     axes(handles.main_axis)
%     view(0,0)
% elseif contents{get(main_axis_popup,'Value')} == 'Column shape'
%     axes(handles.main_axis)
%     view(0,0)
% end
    
% Hints: contents = cellstr(get(hObject,'String')) returns main_axis_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from main_axis_popup


% --- Executes during object creation, after setting all properties.
function main_axis_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to main_axis_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function time_res_Callback(hObject, eventdata, handles)
% hObject    handle to time_res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function time_res_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Min',1)
set(hObject,'Max',100)
set(hObject,'Value',10)

guidata(hObject, handles);
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function theta_res_Callback(hObject, eventdata, handles)
% hObject    handle to theta_res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider



% --- Executes during object creation, after setting all properties.
function theta_res_CreateFcn(hObject, eventdata, handles)
% hObject    handle to theta_res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Min',1)
set(hObject,'Max',150)
set(hObject,'Value',55)

guidata(hObject, handles);
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function phi_res_Callback(hObject, eventdata, handles)
% hObject    handle to phi_res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function phi_res_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phi_res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Min',1)
set(hObject,'Max',150)
set(hObject,'Value',55)

guidata(hObject, handles);
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function theta_res_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to theta_res_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function phi_res_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phi_res_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on slider movement.
function amp_boost_Callback(hObject, eventdata, handles)
% hObject    handle to amp_boost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function amp_boost_CreateFcn(hObject, eventdata, handles)
% hObject    handle to amp_boost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Min',1)
set(hObject,'Max',10000)
set(hObject,'Value',7000)

guidata(hObject, handles);
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function startTime_Callback(hObject, eventdata, handles)
% hObject    handle to startTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.currentTimeStep
get(handles.time_slider,'Min')
if str2double(get(hObject,'String')) < str2double(get(handles.endTime,'String')) && str2double(get(hObject,'String'))>=-12
tmp = (str2double(get(hObject,'String'))+12)/5/0.02+1

get(handles.time_slider,'Value')

    if handles.currentTimeStep < tmp
        set(handles.time_slider,'Value',tmp)
        disp('hej')
        get(handles.time_slider,'Min')
        get(handles.time_slider,'Max')
        get(handles.time_slider,'Value')
    end
    
    
    
set(handles.time_slider,'Min',tmp)
handles.currentTimeStep = tmp;
handles.startTime = str2double(get(hObject,'String'));

else
set(hObject,'String',-12)    
end
guidata(hObject, handles);

% set(hObject,'String',num2str(handles.maxCurrentTimeStep))



% --- Executes during object creation, after setting all properties.
function startTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String',num2str(-12))
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function endTime_Callback(hObject, eventdata, handles)
% hObject    handle to endTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if str2double(get(hObject,'String'))<=round(handles.maxCurrentTimeStep*5*0.02-12) && str2double(get(hObject,'String'))>=-12 && str2double(get(hObject,'String'))>str2double(get(hObject,'String'))
handles.maxCurrentTimeStep = (str2double(get(hObject,'String'))+12)/5/0.02+1;
set(handles.time_slider,'Max',handles.maxCurrentTimeStep)

    if handles.currentTimeStep >= handles.maxCurrentTimeStep
        set(handles.time_slider,'Value',handles.maxCurrentTimeStep)
    end

else
set(hObject,'String',num2str(handles.maxCurrentTimeStep*5*0.02-12))    
end
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of endTime as text
%        str2double(get(hObject,'String')) returns contents of endTime as a double


% --- Executes during object creation, after setting all properties.
function endTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.maxCurrentTimeStep = round(8000*5*0.02-12);

guidata(hObject, handles);

set(hObject,'String',num2str(handles.maxCurrentTimeStep*5*0.02-12))
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in saveImage.
function saveImage_Callback(hObject, eventdata, handles)
% hObject    handle to saveImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
F = getframe(handles.main_axis);
Image = frame2im(F);
%TODO: Add parameter name when generating image
imwrite(Image, 'savedImage.png')


guidata(hObject, handles);
