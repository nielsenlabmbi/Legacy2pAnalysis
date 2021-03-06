function varargout = TuningMap(varargin)
% TUNINGMAP MATLAB code for TuningMap.fig
%      TUNINGMAP, by itself, creates a new TUNINGMAP or raises the existing
%      singleton*.
%
%      H = TUNINGMAP returns the handle to a new TUNINGMAP or the handle to
%      the existing singleton*.
%
%      TUNINGMAP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TUNINGMAP.M with the given input arguments.
%
%      TUNINGMAP('Property','Value',...) creates a new TUNINGMAP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TuningMap_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TuningMap_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TuningMap

% Last Modified by GUIDE v2.5 05-Jun-2015 14:29:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TuningMap_OpeningFcn, ...
                   'gui_OutputFcn',  @TuningMap_OutputFcn, ...
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

% --- Executes just before TuningMap is made visible.
function TuningMap_OpeningFcn(hObject,~,handles,varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TuningMap (see VARARGIN)

% Choose default command line output for TuningMap
handles.output = hObject;

%%%%% SET UP VIEW DATA GUI HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Blank the main image
axes(handles.Image);colormap(gray);image(0);set(gca,'XTick',[],'YTick',[]);
% Establish the Z data file name and path
if ~isempty(varargin)
    zFile = varargin{1};
    zFile = zFile{1};   % converting from cell to string, necessary because string inputs to GUI are treated as callback functions
    [handles.filePath,handles.zFile,ext] = fileparts(zFile);
    handles.zFile = [handles.zFile ext];
    % Set file name in GUI
    set(handles.FileName,'String',handles.zFile);
    % If it exists, enable data viewing
    if exist(zFile,'file')
        set(handles.FileOK,'Value',1);
        set(handles.ViewData,'Enable','On');
    end
else
    handles.zFile = '';
    handles.filePath = '';
end

% Update handles structure
guidata(hObject,handles);

% --- Outputs from this function are returned to the command line.
function varargout = TuningMap_OutputFcn(hObject,~,handles)  %#ok<*INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%%%%% DATA FILE PANEL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%---- Data file name ------------------------------------------------------
function FileName_CreateFcn(~,~,~)
function FileOK_Callback(~,~,~)
function FileName_Callback(hObject, eventdata, handles)
zFile = get(hObject,'String');
[handles.filePath,handles.zFile,ext] = fileparts(zFile);
handles.zFile = [handles.zFile ext];
if exist(zFile,'file')
    set(handles.FileOK,'Value',1);
    set(handles.ViewData,'Enable','On');
else
    set(handles.FileOK,'Value',0);
    set(handles.ViewData,'Enable','Off');
end
% Update handles structure
guidata(hObject,handles);

%---- FIND AN EXISTING DATA FILE ------------------------------------------
function FindData_Callback(hObject, eventdata, handles)
% hObject    handle to FindDataFile (see GCBO)
% handles    structure with handles and user data (see GUIDATA)
[zFile,filePath] = uigetfile('*.zdata','Choose a data file.');
% if user didn't cancel selection
if zFile ~= 0
    handles.zFile = zFile;
    handles.filePath = filePath;
    set(handles.FileName,'String',zFile);
    set(handles.FileOK,'Value',1);
    set(handles.ViewData,'Enable','On');
end
% Update handles structure
guidata(hObject,handles);

%---- VIEW Z DATA ---------------------------------------------------------
function ViewData_Callback(hObject, eventdata, handles)
% Load Z data and settings
load(fullfile(handles.filePath,handles.zFile),'-mat');
handles.Z = Z_session;
handles.S = Stimuli;
handles.I = Info;

set(handles.SettingsPanel,'Visible','On');  % Turn panel on

% Use the settings structure to fill out the parameters panel
handles.param1 = 1;     % Parameter 1 by default is 1
set(handles.Param1,'String',handles.S.params','Value',handles.param1);
handles.scaleColor = 0;%1; % Default is that parameter 1 values are NOT scaled according to unit strength
handles.circ = 0;       % Default is that parameter 1 is not considered circular
% Make circular if parameter name is 'ori'
% if strcmp(handles.S.params{handles.param1},'ori')
%     handles.circ = 1;
% end
% set(handles.Circ,'Value',handles.circ);

%%
handles.param2 = 0;    
if length(handles.S.params) > 1 
    handles.param2 = 2;     
    set(handles.Param2,'String',handles.S.params','Value',handles.param2);
    exclude = isnan(handles.S.unique_stimuli(:,handles.param2));                   
    param2values = num2str(unique(handles.S.unique_stimuli(~exclude,handles.param2)));           
    %while size(param2values,2) < 3; param2values = [repmat(' ',[size(param2values,1) 1]) param2values]; end % Get param 2 values as long as 'All'
    best = {'best'}; %means = 'mean';%while size(all,2) < size(param2values,2); all = [' ' all]; end % get all as long as param 2 values
    set(handles.Param2Value,'String',[best;param2values],'Value',1);
    handles.param2value = 0;
    % Note that param2value is Param2Value's 'Value' - 1
    set(handles.Param2,'Enable','On');
    set(handles.Param2Value,'Enable','On');
else
    set(handles.Param2,'Enable','Off');
    set(handles.Param2Value,'Enable','Off');
end
set(handles.ViewingPanel,'Visible','On');   % Turn panel on

% Set unit to 1
handles.unitNumber = 1;
set(handles.UnitNumber,'String',num2str(handles.unitNumber));

% Update the image
handles = UpdateImage(handles);
exclude = isnan(handles.S.unique_stimuli(:,handles.param1));    
handles.x = unique(handles.S.unique_stimuli(~exclude,handles.param1));
% Update handles
guidata(hObject,handles);


%%%%% VIEWING PANEL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%---- PARAMETER SELECTION -------------------------------------------------
function Param1_CreateFcn(~,~,~)
function Param1_Callback(hObject,~,handles)
handles.param1 = get(hObject,'Value');
% eventdata = [];
% Param2_Callback(hObject,eventdata,handles);
handles.param2 = 0; 
set(handles.Param2Value,'String','best','Value',1);
handles = UpdateImage(handles);
guidata(hObject,handles);

function Circ_Callback(hObject,~,handles)
handles.circ = get(handles.Circ,'Value');
handles = UpdateImage(handles);
guidata(hObject,handles);

function ScaleColor_Callback(hObject,~,handles)
handles.scaleColor = get(handles.ScaleColor,'Value');
handles = UpdateImage(handles);
guidata(hObject,handles);

function Param2_CreateFcn(~,~,~)
function Param2_Callback(hObject,~,handles)
handles.param2 = get(hObject,'Value');

exclude = isnan(handles.S.unique_stimuli(:,handles.param2));                   
param2values = num2str(unique(handles.S.unique_stimuli(~exclude,handles.param2)));           
% while size(param2values,2) < 3; param2values = [repmat(' ',[size(param2values,1) 1]) param2values]; end % Get param 2 values as long as 'All'
 best = {'best'}; %while size(best,2) < size(param2values,2); best = [' ' best]; end % get all as long as param 2 values
 set(handles.Param2Value,'String',[best; param2values],'Value',1);
handles.param2value = 0;% Parameter 2 by default is collapsed across all parameter values

handles = UpdateImage(handles);
guidata(hObject,handles);


function Param2Value_CreateFcn(~,~,~)
function Param2Value_Callback(hObject,~,handles)
handles.param2value = get(hObject,'Value')-1;
handles = UpdateImage(handles);
guidata(hObject,handles);

%---- UNIT SELECTION ------------------------------------------------------
function UnitNumber_CreateFcn(~,~,~)
function UnitNumber_Callback(hObject,~,handles)
handles.unitNumber = str2double(get(hObject,'String'));
handles.unitNumber = UpdateUnitNumber(handles);
guidata(hObject,handles);

% --- Executes on button press in UpUnit.
function UpUnit_Callback(hObject,~,handles)
handles.unitNumber = handles.unitNumber+1;
handles.unitNumber = UpdateUnitNumber(handles);
set(handles.UnitNumber,'String',num2str(handles.unitNumber));
guidata(hObject, handles);

% --- Executes on button press in DownUnit.
function DownUnit_Callback(hObject,~,handles)
handles.unitNumber = handles.unitNumber-1;
handles.unitNumber = UpdateUnitNumber(handles);
set(handles.UnitNumber,'String',num2str(handles.unitNumber));
guidata(hObject, handles);

%---- TIMECOURSE OPTIONS --------------------------------------------------
% --- Executes on button press in WorstResponse.
function WorstResponse_Callback(~,~,handles)
handles.unitNumber = str2double(get(handles.UnitNumber,'String'));
UpdateUnitNumber(handles);

% --- Executes on button press in AllTrials.
function AllTrials_Callback(~,~,handles)
handles.unitNumber = str2double(get(handles.UnitNumber,'String'));
UpdateUnitNumber(handles);

% --- Executes on button press in BestResponse.
function BestResponse_Callback(~,~,handles)
handles.unitNumber = str2double(get(handles.UnitNumber,'String'));
UpdateUnitNumber(handles);

% --- Executes on button press in FilterResponse.
function FilterResponse_Callback(~,~,handles)
handles.unitNumber = str2double(get(handles.UnitNumber,'String'));
UpdateUnitNumber(handles);


%%%%% SETTINGS FILE PANEL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%% AXES UPDATE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%---- Update the Image of All Units ---------------------------------------
function handles = UpdateImage(handles)

global mean_over_phase max_over_ori sf_vect_mx_mx best_ori...
    pref_sf best_sf_in_window time_delay_sf max_over_sf ...
    or_vect_mx_mx  best_sf  pref_or  best_or_in_window time_delay_ori...
    max_over_time best_timecourse worst_timecourse domains

[mean_over_phase, max_over_ori, sf_vect_mx_mx, best_ori, pref_sf, best_sf_in_window, time_delay_sf] ...
     = sf_pref0(handles.Z, handles.S, handles.I);
 
[~, max_over_sf, or_vect_mx_mx, best_sf, pref_or, best_or_in_window, time_delay_ori]...
    = or_pref0(handles.Z, handles.S, handles.I);

max_over_time = cell(1,handles.I.ncells);

domains.oridom = unique(handles.S.unique_stimuli(:,1));
domains.sfdom = unique(handles.S.unique_stimuli(:,2));

for n = 1:handles.I.ncells
    max_over_time{n} = zeros(length(domains.oridom),length(domains.sfdom));
    for i = 1:length(mean_over_phase{n}(:))
        max_over_time{n}(i) = mean_over_phase{n}{i}(time_delay_ori(n));
    end
end
% best timecourses
best_timecourse = cell(handles.I.ncells,1);
 for n = 1:handles.I.ncells
    [a,b] = max(max_over_time{n}(:));
    best_timecourse{n} = mean_over_phase{n}{b};
end
worst_timecourse = cell(handles.I.ncells,1);
for n = 1:handles.I.ncells
    [a,b] = min(max_over_time{n}(:));
    worst_timecourse{n} = mean_over_phase{n}{b};
end

% TAKE SETTINGS OUT OF HANDLES FOR CONVENIENCE
S = handles.S;

im = handles.I.image;   % Load the unmodified image from settings

exclude = isnan(S.unique_stimuli(:,handles.param1));    
handles.x = unique(S.unique_stimuli(~exclude,handles.param1));
kernel_window = find(handles.I.approx_kernel_times >=0 & handles.I.approx_kernel_times < 1000);


A = nan(1,handles.I.ncells);   % Strength of that variable
ix = zeros(1,handles.I.ncells);
handles.unitCond = ones(1,handles.I.ncells);   % Starting condition for time courses will be the max response
global map
        map =     [1, 0, 0
                    1,.5,0
                    1, 1, 0
                    0, 1, 0
                    0, 1, 1
                    0, 0, 1
                    .5,0,.7
                    1, 0, 1];   
                
if strcmp(S.params{handles.param1},'orientation');
for i = 1:handles.I.ncells
    if handles.param2 && handles.param2value
        x2 = unique(S.unique_stimuli(~exclude,handles.param2));             % unique parameter 2 values
        mat = cell2mat(mean_over_phase{i}(:,domains.sfdom==x2(handles.param2value)));
        y = max(mat(:,kernel_window),[],1);
        [a,b] = max(y);
        y = mat(:,kernel_window(b));
        [a,b] = max(y);
        ix(i) = find(domains.oridom == domains.oridom(b));
    else
        y = max(max_over_time{i},[],2);
        ix(i) = find(domains.oridom==pref_or(i));
    end
    maxR = max(y); minR = min(y); 
    A(i) = maxR-minR;
    handles.unitCond(i) = find(y==maxR);
end
A = A/max(A);   % Normalize tuning strength to the unit with the strongest tuning
  
for n = 1:handles.I.ncells
    [i,j] = find(handles.I.mask==n);
    for k = 1:length(i)                         % Going pixel by pixel
        col1 = squeeze(im(i(k),j(k),:));                    % grab the original color
        col2 = map(ix(n),:)';        % grab the color corresponding to the parameter value
        if handles.scaleColor   % If scaling color to the tuning strength
            im(i(k),j(k),:) = A(n)*col2 + (1-A(n))*col1;  % the hue of the paramter value corresponds to strength
        else                    % Tuning is indicated independent of tuning strength
            im(i(k),j(k),:) = .3*col2 + col1;
        end
    end
end
map1 = map(1:length(domains.oridom),:);

axes(handles.Image); image(im); colorbar; colormap(map1); 
elseif strcmp(S.params{handles.param1},'spatial frequency');
for i = 1:handles.I.ncells
    if handles.param2 && handles.param2value
         x2 = unique(S.unique_stimuli(~exclude,handles.param2));
         mat = cell2mat(mean_over_phase{i}(domains.oridom==x2(handles.param2value),:)');
         y = max(mat(:,kernel_window),[],1);
         [a,b] = max(y);
                 y = mat(:,kernel_window(b));
        [a,b] = max(y);
        ix(i) = find(domains.sfdom == domains.sfdom(b));
    else
        y = max(max_over_time{i},[],1);
        ix(i) = find(domains.sfdom==pref_sf(i));
    end
    maxR = max(y); minR = min(y); 
    A(i) = maxR-minR;
    handles.unitCond(i) = find(y==maxR);
end
A = A/max(A);   % Normalize tuning strength to the unit with the strongest tuning
  
for n = 1:handles.I.ncells
    [i,j] = find(handles.I.mask==n);
    for k = 1:length(i)                         % Going pixel by pixel
        col1 = squeeze(im(i(k),j(k),:));                    % grab the original color
        col2 = map(ix(n),:)';        % grab the color corresponding to the parameter value
        if handles.scaleColor   % If scaling color to the tuning strength
            im(i(k),j(k),:) = A(n)*col2 + (1-A(n))*col1;  % the hue of the paramter value corresponds to strength
        else                    % Tuning is indicated independent of tuning strength
            im(i(k),j(k),:) = .3*col2 + col1;
        end
    end
end
map1 = map(1:length(domains.sfdom),:);
axes(handles.Image);image(im);colorbar; colormap(map1);
end


handles.im = im; 
UpdateUnitNumber(handles);

%---- Update the Selected Unit Plots --------------------------------------
function [unitNumber,unitCond] = UpdateUnitNumber(handles)

% FOR CONVENIENCE, MOVE SETTINGS OUT OF HANDLES
S = handles.S;
I = handles.I;
%%%%% CHECK UNIT NUMBER %%%%%
unitNumber = handles.unitNumber;
unitCond = handles.unitCond;
if isnan(unitNumber); unitNumber = 1; end;
if unitNumber < 1; unitNumber = 1; end;
if unitNumber > max(I.mask(:)); unitNumber = max(I.mask(:)); end;

%%%%% HIGHLIGHT THE CURRENT UNIT %%%%%
axes(handles.Image);
im = handles.im;

mask = I.mask == unitNumber; %if I don't do this, neighboring units will sometimes create border for their difference
top = diff([zeros(1,796);mask]) == 1;
bot = flipud(diff([zeros(1,796);flipud(mask)])) == 1;
lef = diff([zeros(512,1) mask],1,2) == 1;
rig = fliplr(diff([zeros(512,1) fliplr(mask)],1,2)) == 1;
bord = top | bot | lef | rig;
[i,j] = find(bord);
for k = 1:length(i); im(i(k),j(k),:) = 1; end;
% PLACE THE BORDER IN THE IMAGE, AT THIS POINT GIVE THE IMAGE A CLICKABLE FUNCTION 
axes(handles.Image);h = image(im); colorbar; %set(handles.Image,'XTick',[],'YTick',[]);
set(h,'ButtonDownFcn',@(hObject,eventdata)TuningMap('axes_ButtonDownFcn',hObject,eventdata,guidata(hObject)));
set(h,'ButtonDownFcn',@(hObject,eventdata)TuningMap('axes_ButtonDownFcn',hObject,eventdata,guidata(hObject)));

 global max_over_time or_vect_mx_mx sf_vect_mx_mx domains mean_over_phase max_over_sf max_over_ori

    % best within these events
    kernel_window = find(handles.I.approx_kernel_times >=0 & handles.I.approx_kernel_times < 1000);
        exclude = isnan(S.unique_stimuli(:,handles.param1));    
     if strcmp(S.params{handles.param1},'orientation');
         if handles.param2 && handles.param2value
             x2 = unique(S.unique_stimuli(~exclude,handles.param2));             % unique parameter 2 values
             mat = cell2mat(mean_over_phase{unitNumber}(:,domains.sfdom==x2(handles.param2value)));
             y = max(mat(:,kernel_window),[],1);
             [a,b] = max(y);
             y = mat(:,kernel_window(b));
             axes(handles.Tuning); cla; hold on; box on;
             plot([.5 length(handles.x)+.5],[0 0],':','Color',[.5 .5 .5]);
             plot(1:length(handles.x),y,'k','LineWidth',2); 
             set(gca,'XTick',1:length(handles.x), 'XTickLabel',handles.x)
         else
             y = max(max_over_time{unitNumber},[],2);
             axes(handles.Tuning); cla; hold on; box on;
             plot([.5 length(handles.x)+.5],[0 0],':','Color',[.5 .5 .5]);
             plot(1:length(handles.x),or_vect_mx_mx(unitNumber,:),'k','LineWidth',2); 
             set(gca,'XTick',1:length(handles.x), 'XTickLabel',handles.x)
         end
     elseif strcmp(S.params{handles.param1},'spatial frequency');
         if handles.param2 && handles.param2value
              x2 = unique(S.unique_stimuli(~exclude,handles.param2));
              mat = cell2mat(mean_over_phase{unitNumber}(domains.oridom==x2(handles.param2value),:)');
             y = max(mat(:,kernel_window),[],1);
             [a,b] = max(y);
             y = mat(:,kernel_window(b));
              axes(handles.Tuning); cla; hold on; box on;
             plot(1:length(handles.x),y,'k','LineWidth',2);
             set(gca,'XTick',1:length(handles.x), 'XTickLabel',round(handles.x,2))
         else
             y = max(max_over_time{unitNumber},[],1);
             axes(handles.Tuning); cla; hold on; box on;
             plot(1:length(handles.x),sf_vect_mx_mx(unitNumber,:),'k','LineWidth',2);
             set(gca,'XTick',1:length(handles.x), 'XTickLabel',round(handles.x,2))
         end
     end

axes(handles.Tuning); hold on; box on;
% plot([.5 length(handles.x)+.5],[0 0],':','Color',[.5 .5 .5]);
if get(handles.WorstResponse,'Value'); e = find(y == min(y)); plot([e e],[min(y) max(y)],'--r'); end
if get(handles.BestResponse,'Value'); e = find(y == max(y)); plot([e e],[min(y) max(y)],'--b'); end
plot([unitCond(unitNumber) unitCond(unitNumber)],[min(y) max(y)],'--k'); 

%%%%%%% Plot time course of selected parameter conditions
axes(handles.Timing); cla; hold on; box on;
% plot([handles.kernelPre handles.kernelPost]...
%     ,[0 0],':','Color',[.5 .5 .5]);
% plot([0 0],[-10 10],'Color',[.5 .5 .5]);
% plot([1000 1000],[-10 10],'Color',[.5 .5 .5]);
global best_timecourse worst_timecourse best_sf best_ori
Z = handles.Z;

if strcmp(S.params{handles.param1},'orientation');
    plot(I.approx_kernel_times,mean(cell2mat(mean_over_phase{unitNumber}(handles.unitCond(unitNumber),:)')),'k','LineWidth',2);
elseif strcmp(S.params{handles.param1},'spatial frequency');
    plot(I.approx_kernel_times,mean(cell2mat(mean_over_phase{unitNumber}(:,handles.unitCond(unitNumber)))),'k','LineWidth',2);
end

if get(handles.WorstResponse,'Value')
    if get(handles.FilterResponse,'Value')
        plot(I.approx_kernel_times,worst_timecourse{unitNumber},'r','LineWidth',2)
    end
end

if get(handles.BestResponse,'Value')
    if get(handles.FilterResponse,'Value')
        plot(I.approx_kernel_times,best_timecourse{unitNumber},'b','LineWidth',2)
    end
end


if get(handles.AllTrials,'Value')
    if strcmp(S.params{handles.param1},'orientation')
        if  handles.param2 && handles.param2value
            IX = S.unique_stimuli(:,1) == domains.oridom(unitCond(unitNumber)) & S.unique_stimuli(:,2) == x2(handles.param2value);
        else
            IX = S.unique_stimuli(:,1) == domains.oridom(unitCond(unitNumber));
        end
            alltrials = Z(unitNumber).mean_dFstim(IX,:);
        plot(I.approx_kernel_times,alltrials,'Color',[.5 .5 .5],'LineWidth',1)
        
    elseif strcmp(S.params{handles.param1},'spatial frequency');
        if  handles.param2 && handles.param2value
            IX = S.unique_stimuli(:,2) == domains.sfdom(unitCond(unitNumber)) & S.unique_stimuli(:,1) == x2(handles.param2value);
        else
            IX = S.unique_stimuli(:,2) == domains.sfdom(unitCond(unitNumber));
        end
            alltrials = Z(unitNumber).mean_dFstim(IX,:);
        plot(I.approx_kernel_times,alltrials,'Color',[.5 .5 .5],'LineWidth',1)
    end
unitCond = handles.unitCond;

end


% --- Executes on button press in IncreaseCond.
function IncreaseCond_Callback(hObject,~,handles)
handles.unitNumber = str2double(get(handles.UnitNumber,'String'));
handles.unitCond(handles.unitNumber) = handles.unitCond(handles.unitNumber)+1;
if handles.unitCond(handles.unitNumber) > length(handles.x)
    handles.unitCond(handles.unitNumber) = 1;
end
[~,handles.unitCond] = UpdateUnitNumber(handles);
guidata(hObject,handles);

% --- Executes on button press in DecreaseCond.
function DecreaseCond_Callback(hObject,~,handles)
handles.unitNumber = str2double(get(handles.UnitNumber,'String'));
handles.unitCond(handles.unitNumber) = handles.unitCond(handles.unitNumber)-1;
if handles.unitCond(handles.unitNumber) < 1
    handles.unitCond(handles.unitNumber) = length(handles.x);
end
[~,handles.unitCond] = UpdateUnitNumber(handles);
guidata(hObject,handles);

% --- Executes on mouse press over axes background.
function axes_ButtonDownFcn(hObject, eventdata, handles)

xy = get(handles.Image,'CurrentPoint');
x = round(xy(1,1)); y = round(xy(1,2));

if x < 1; x = 1; end; if x > size(handles.I.mask,2); x = size(handles.I.mask,2); end;
if y < 1; y = 1; end; if y > size(handles.I.mask,1); y = size(handles.I.mask,1); end;

unit = handles.I.mask(y,x);

if unit > 0
    handles.unitNumber = unit;
    set(handles.UnitNumber,'String',num2str(unit));
    UpdateUnitNumber(handles);
end

% --- Executes on button press in ZoomButton.
function ZoomButton_Callback(hObject, eventdata, handles)
axes(handles.Timing);
[~,y,b] = ginput(1);
if b == 1   % if mouse button 1, zoom in
    d = diff(get(gca,'YLim'))/4;
    set(gca,'YLim',[y-d y+d]);
    set(handles.Tuning,'YLim',[y-d y+d]);
else        % if any other mouse button, zoom out
    d = diff(get(gca,'YLim'));
    set(gca,'YLim',[y-d y+d]);
    set(handles.Tuning,'YLim',[y-d y+d]);
end



function FilterWidth_Callback(hObject, eventdata, handles)
% hObject    handle to FilterWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FilterWidth as text
%        str2double(get(hObject,'String')) returns contents of FilterWidth as a double


% --- Executes during object creation, after setting all properties.
function FilterWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FilterWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function kernelPre_Callback(hObject, eventdata, handles)
% hObject    handle to kernelPre (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of kernelPre as text
%        str2double(get(hObject,'String')) returns contents of kernelPre as a double


% --- Executes during object creation, after setting all properties.
function kernelPre_CreateFcn(hObject, eventdata, handles)
% hObject    handle to kernelPre (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function kernelPost_Callback(hObject, eventdata, handles)
% hObject    handle to kernelPost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of kernelPost as text
%        str2double(get(hObject,'String')) returns contents of kernelPost as a double


% --- Executes during object creation, after setting all properties.
function kernelPost_CreateFcn(hObject, eventdata, handles)
% hObject    handle to kernelPost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%% Support Functions
function [mean_over_phase, max_over_sf, or_vect_mx_mx, best_sf, pref_or, best_or_in_window,...
    time_delay_ori] = or_pref0(Z_session, Stimuli, Info)

ncells = Info.ncells;
domains.oridom = unique(Stimuli.unique_stimuli(:,1));
domains.sfdom = unique(Stimuli.unique_stimuli(:,2));
%%
kernel_length = length(Info.approx_kernel_times);
kernel_window = find(Info.approx_kernel_times >=0 & Info.approx_kernel_times < 1000);
%%
mean_over_phase = cell(1,ncells);
%average over spatial phase
for i = 1:length(domains.oridom);
    for j = 1:length(domains.sfdom);
        IX = Stimuli.unique_stimuli(:,1) == domains.oridom(i) & Stimuli.unique_stimuli(:,2) == domains.sfdom(j);
        for n = 1:ncells
          mean_over_phase{n}{i,j}= mean(Z_session(n).mean_dFstim(IX,:),1);
        end
    end
end

% orientation v time

max_over_sf = cell(1,ncells);
or_vect_mx_mx = zeros(ncells,length(domains.oridom));
best_or_in_window = zeros(ncells,length(domains.oridom));
best_sf = cell(1,ncells);
pref_or = zeros(ncells,1);
time_delay_ori = zeros(ncells,1);

for n = 1:ncells
    max_over_sf{n} = zeros(length(domains.oridom),kernel_length);
    best_sf{n} = zeros(1,length(domains.oridom));
    for i = 1:length(domains.oridom)
        matrix = cell2mat(mean_over_phase{n}(i,:)');
        [x(i), best_sf{n}(i)] = max(max(matrix(:,kernel_window),[],2)); %when the cell has the highest response in 0-1s 
    end
    [~,ix] = max(x);
    max_over_sf{n} = cell2mat(mean_over_phase{n}(:,best_sf{n}(ix))); %at the given orientation and best sf.
    
    [a,b] = max(max(max_over_sf{n}(:,kernel_window),[],1));
    time_delay_ori(n) = kernel_window(b);
    or_vect_mx_mx(n,:) = max_over_sf{n}(:,time_delay_ori(n)); %mean(max_over_sf{n}(:,kernel_window),2);%
    [a,b] = max(or_vect_mx_mx(n,:));
    pref_or(n) = domains.oridom(b);
end

function [mean_over_phase, max_over_ori, sf_vect_mx_mx, best_ori, pref_sf, best_sf_in_window, ...
     time_delay_sf] = sf_pref0(Z_session, Stimuli, Info)
 
ncells = Info.ncells;
domains.oridom = unique(Stimuli.unique_stimuli(:,1));
domains.sfdom = unique(Stimuli.unique_stimuli(:,2));

kernel_length = length(Info.approx_kernel_times);
kernel_window = find(Info.approx_kernel_times >=0 & Info.approx_kernel_times < 1000);

mean_over_phase = cell(1,ncells);
%average over spatial phase
for i = 1:length(domains.oridom);
    for j = 1:length(domains.sfdom);
        IX = Stimuli.unique_stimuli(:,1) == domains.oridom(i) & Stimuli.unique_stimuli(:,2) == domains.sfdom(j);
        for n = 1:ncells
          mean_over_phase{n}{i,j}= mean(Z_session(n).mean_dFstim(IX,:),1);
        end
    end
end
% spatial frequency v time

max_over_ori = cell(1,ncells);
sf_vect_mx_mx = zeros(ncells,length(domains.sfdom));
best_sf_in_window = zeros(ncells,length(domains.sfdom));
best_ori = cell(1,ncells);
pref_sf = zeros(ncells,1);
time_delay_sf = zeros(ncells,1);
for n = 1:ncells
    max_over_ori{n} = zeros(length(domains.sfdom),kernel_length);
    best_ori{n} = zeros(1,length(domains.sfdom));
    for i = 1:length(domains.sfdom)
        matrix = cell2mat(mean_over_phase{n}(:,i));
        [x(i), best_ori{n}(i)] = max(max(matrix(:,kernel_window),[],2)); %when and at what orientation the cell has the highest response in 0-1s 
    end
     [~,ix] = max(x);
     max_over_ori{n} = cell2mat(mean_over_phase{n}(best_ori{n}(ix),:)'); %at the given sf and best orientation.
    
    [a,b] = max(max(max_over_ori{n}(:,kernel_window),[],1));
    time_delay_sf(n) = kernel_window(b);
    sf_vect_mx_mx(n,:) = max_over_ori{n}(:,time_delay_sf(n));% mean(max_over_ori{n}(:,kernel_window),2);%
    [a, b] = max(sf_vect_mx_mx(n,:));
    pref_sf(n) = domains.sfdom(b);
    
end