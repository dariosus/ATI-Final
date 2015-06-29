function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 29-Jun-2015 17:38:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
handles.file = get(hObject, 'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
colorImage = imread(handles.file);
figure; imshow(colorImage); title('Original image')


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
colorImage = imread(handles.file);
grayImage = rgb2gray(colorImage);
mserRegions = detectMSERFeatures(grayImage,'RegionAreaRange',[150 2000]);
mserRegionsPixels = vertcat(cell2mat(mserRegions.PixelList));
figure; imshow(colorImage); hold on;
plot(mserRegions, 'showPixelList', true,'showEllipses',false);
title('MSER regions');


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
colorImage = imread(handles.file);
grayImage = rgb2gray(colorImage);
mserRegions = detectMSERFeatures(grayImage,'RegionAreaRange',[150 2000]);
mserRegionsPixels = vertcat(cell2mat(mserRegions.PixelList));
mserMask = false(size(grayImage));
ind = sub2ind(size(mserMask), mserRegionsPixels(:,2), mserRegionsPixels(:,1));
mserMask(ind) = true;
edgeMask = edge(grayImage, 'Canny');
edgeAndMSERIntersection = edgeMask & mserMask;
figure; imshowpair(edgeMask, edgeAndMSERIntersection, 'montage');
title('Canny edges and intersection of canny edges with MSER regions')


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
colorImage = imread(handles.file);
grayImage = rgb2gray(colorImage);
mserRegions = detectMSERFeatures(grayImage,'RegionAreaRange',[150 2000]);
mserRegionsPixels = vertcat(cell2mat(mserRegions.PixelList));
mserMask = false(size(grayImage));
ind = sub2ind(size(mserMask), mserRegionsPixels(:,2), mserRegionsPixels(:,1));
mserMask(ind) = true;
edgeMask = edge(grayImage, 'Canny');
edgeAndMSERIntersection = edgeMask & mserMask;
[~, gDir] = imgradient(grayImage);
gradientGrownEdgesMask = helperGrowEdges(edgeAndMSERIntersection, gDir, 'LightTextOnDark');
figure; imshow(gradientGrownEdgesMask); title('Edges grown along gradient direction')


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
colorImage = imread(handles.file);
grayImage = rgb2gray(colorImage);
mserRegions = detectMSERFeatures(grayImage,'RegionAreaRange',[150 2000]);
mserRegionsPixels = vertcat(cell2mat(mserRegions.PixelList));
mserMask = false(size(grayImage));
ind = sub2ind(size(mserMask), mserRegionsPixels(:,2), mserRegionsPixels(:,1));
mserMask(ind) = true;
edgeMask = edge(grayImage, 'Canny');
edgeAndMSERIntersection = edgeMask & mserMask;
[~, gDir] = imgradient(grayImage);
gradientGrownEdgesMask = helperGrowEdges(edgeAndMSERIntersection, gDir, 'LightTextOnDark');
edgeEnhancedMSERMask = ~gradientGrownEdgesMask & mserMask;
figure; imshowpair(mserMask, edgeEnhancedMSERMask, 'montage');
title('Original MSER regions and segmented MSER regions')


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
colorImage = imread(handles.file);
grayImage = rgb2gray(colorImage);
mserRegions = detectMSERFeatures(grayImage,'RegionAreaRange',[150 2000]);
mserRegionsPixels = vertcat(cell2mat(mserRegions.PixelList));
mserMask = false(size(grayImage));
ind = sub2ind(size(mserMask), mserRegionsPixels(:,2), mserRegionsPixels(:,1));
mserMask(ind) = true;
edgeMask = edge(grayImage, 'Canny');
edgeAndMSERIntersection = edgeMask & mserMask;
[~, gDir] = imgradient(grayImage);
gradientGrownEdgesMask = helperGrowEdges(edgeAndMSERIntersection, gDir, 'LightTextOnDark');
edgeEnhancedMSERMask = ~gradientGrownEdgesMask & mserMask;
regionFilteredTextMask = edgeEnhancedMSERMask;
regionFilteredTextMask(vertcat(connComp.PixelIdxList{[stats.Eccentricity] > .995})) = 0;
regionFilteredTextMask(vertcat(connComp.PixelIdxList{[stats.Area] < 150 | [stats.Area] > 2000})) = 0;
regionFilteredTextMask(vertcat(connComp.PixelIdxList{[stats.Solidity] < .4})) = 0;
figure; imshowpair(edgeEnhancedMSERMask, regionFilteredTextMask, 'montage');
title('Text candidates before and after region filtering')


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
colorImage = imread(handles.file);
grayImage = rgb2gray(colorImage);
mserRegions = detectMSERFeatures(grayImage,'RegionAreaRange',[150 2000]);
mserRegionsPixels = vertcat(cell2mat(mserRegions.PixelList));
mserMask = false(size(grayImage));
ind = sub2ind(size(mserMask), mserRegionsPixels(:,2), mserRegionsPixels(:,1));
mserMask(ind) = true;
edgeMask = edge(grayImage, 'Canny');
edgeAndMSERIntersection = edgeMask & mserMask;
[~, gDir] = imgradient(grayImage);
gradientGrownEdgesMask = helperGrowEdges(edgeAndMSERIntersection, gDir, 'LightTextOnDark');
edgeEnhancedMSERMask = ~gradientGrownEdgesMask & mserMask;
distanceImage    = bwdist(~edgeEnhancedMSERMask);  % Compute distance transform
strokeWidthImage = helperStrokeWidth(distanceImage); % Compute stroke width image
figure; imshow(strokeWidthImage);
caxis([0 max(max(strokeWidthImage))]); axis image, colormap('jet'), colorbar;
title('Visualization of text candidates stroke width')


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
colorImage = imread(handles.file);
grayImage = rgb2gray(colorImage);
mserRegions = detectMSERFeatures(grayImage,'RegionAreaRange',[150 2000]);
mserRegionsPixels = vertcat(cell2mat(mserRegions.PixelList));
mserMask = false(size(grayImage));
ind = sub2ind(size(mserMask), mserRegionsPixels(:,2), mserRegionsPixels(:,1));
mserMask(ind) = true;
edgeMask = edge(grayImage, 'Canny');
edgeAndMSERIntersection = edgeMask & mserMask;
[~, gDir] = imgradient(grayImage);
gradientGrownEdgesMask = helperGrowEdges(edgeAndMSERIntersection, gDir, 'LightTextOnDark');
edgeEnhancedMSERMask = ~gradientGrownEdgesMask & mserMask;
distanceImage    = bwdist(~edgeEnhancedMSERMask);  % Compute distance transform
strokeWidthImage = helperStrokeWidth(distanceImage); % Compute stroke width image
connComp = bwconncomp(edgeEnhancedMSERMask);
afterStrokeWidthTextMask = edgeEnhancedMSERMask;
for i = 1:connComp.NumObjects
    strokewidths = strokeWidthImage(connComp.PixelIdxList{i});
    % Compute normalized stroke width variation and compare to common value
    if std(strokewidths)/mean(strokewidths) > 0.35
        afterStrokeWidthTextMask(connComp.PixelIdxList{i}) = 0; % Remove from text candidates
    end
end
figure; imshowpair(edgeEnhancedMSERMask, afterStrokeWidthTextMask,'montage');
title('Text candidates before and after stroke width filtering')


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
colorImage = imread(handles.file);
grayImage = rgb2gray(colorImage);
mserRegions = detectMSERFeatures(grayImage,'RegionAreaRange',[150 2000]);
mserRegionsPixels = vertcat(cell2mat(mserRegions.PixelList));
mserMask = false(size(grayImage));
ind = sub2ind(size(mserMask), mserRegionsPixels(:,2), mserRegionsPixels(:,1));
mserMask(ind) = true;
edgeMask = edge(grayImage, 'Canny');
edgeAndMSERIntersection = edgeMask & mserMask;
[~, gDir] = imgradient(grayImage);
gradientGrownEdgesMask = helperGrowEdges(edgeAndMSERIntersection, gDir, 'LightTextOnDark');
edgeEnhancedMSERMask = ~gradientGrownEdgesMask & mserMask;
distanceImage    = bwdist(~edgeEnhancedMSERMask);  % Compute distance transform
strokeWidthImage = helperStrokeWidth(distanceImage); % Compute stroke width image
connComp = bwconncomp(edgeEnhancedMSERMask);
afterStrokeWidthTextMask = edgeEnhancedMSERMask;
for i = 1:connComp.NumObjects
    strokewidths = strokeWidthImage(connComp.PixelIdxList{i});
    % Compute normalized stroke width variation and compare to common value
    if std(strokewidths)/mean(strokewidths) > 0.35
        afterStrokeWidthTextMask(connComp.PixelIdxList{i}) = 0; % Remove from text candidates
    end
end
se1=strel('disk',25);
se2=strel('disk',7);

afterMorphologyMask = imclose(afterStrokeWidthTextMask,se1);
afterMorphologyMask = imopen(afterMorphologyMask,se2);
displayImage = colorImage;
displayImage(~repmat(afterMorphologyMask,1,1,3)) = 0;
figure; imshow(displayImage); title('Image region under mask created by joining individual characters')


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
colorImage = imread(handles.file);
grayImage = rgb2gray(colorImage);
mserRegions = detectMSERFeatures(grayImage,'RegionAreaRange',[150 2000]);
mserRegionsPixels = vertcat(cell2mat(mserRegions.PixelList));
mserMask = false(size(grayImage));
ind = sub2ind(size(mserMask), mserRegionsPixels(:,2), mserRegionsPixels(:,1));
mserMask(ind) = true;
edgeMask = edge(grayImage, 'Canny');
edgeAndMSERIntersection = edgeMask & mserMask;
[~, gDir] = imgradient(grayImage);
gradientGrownEdgesMask = helperGrowEdges(edgeAndMSERIntersection, gDir, 'LightTextOnDark');
edgeEnhancedMSERMask = ~gradientGrownEdgesMask & mserMask;
distanceImage    = bwdist(~edgeEnhancedMSERMask);  % Compute distance transform
strokeWidthImage = helperStrokeWidth(distanceImage); % Compute stroke width image
connComp = bwconncomp(edgeEnhancedMSERMask);
afterStrokeWidthTextMask = edgeEnhancedMSERMask;
for i = 1:connComp.NumObjects
    strokewidths = strokeWidthImage(connComp.PixelIdxList{i});
    % Compute normalized stroke width variation and compare to common value
    if std(strokewidths)/mean(strokewidths) > 0.35
        afterStrokeWidthTextMask(connComp.PixelIdxList{i}) = 0; % Remove from text candidates
    end
end
se1=strel('disk',25);
se2=strel('disk',7);

afterMorphologyMask = imclose(afterStrokeWidthTextMask,se1);
afterMorphologyMask = imopen(afterMorphologyMask,se2);
displayImage = colorImage;
displayImage(~repmat(afterMorphologyMask,1,1,3)) = 0;
areaThreshold = 5000; % threshold in pixels
connComp = bwconncomp(afterMorphologyMask);
stats = regionprops(connComp,'BoundingBox','Area');
boxes = round(vertcat(stats(vertcat(stats.Area) > areaThreshold).BoundingBox));
for i=1:size(boxes,1)
    figure;
    imshow(imcrop(colorImage, boxes(i,:))); % Display segmented text
    title('Text region')
end


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

colorImage = imread(handles.file);
grayImage = rgb2gray(colorImage);
mserRegions = detectMSERFeatures(grayImage,'RegionAreaRange',[150 2000]);
mserRegionsPixels = vertcat(cell2mat(mserRegions.PixelList));
mserMask = false(size(grayImage));
ind = sub2ind(size(mserMask), mserRegionsPixels(:,2), mserRegionsPixels(:,1));
mserMask(ind) = true;
edgeMask = edge(grayImage, 'Canny');
edgeAndMSERIntersection = edgeMask & mserMask;
[~, gDir] = imgradient(grayImage);
gradientGrownEdgesMask = helperGrowEdges(edgeAndMSERIntersection, gDir, 'LightTextOnDark');
edgeEnhancedMSERMask = ~gradientGrownEdgesMask & mserMask;
distanceImage    = bwdist(~edgeEnhancedMSERMask);  % Compute distance transform
strokeWidthImage = helperStrokeWidth(distanceImage); % Compute stroke width image
connComp = bwconncomp(edgeEnhancedMSERMask);
afterStrokeWidthTextMask = edgeEnhancedMSERMask;
for i = 1:connComp.NumObjects
    strokewidths = strokeWidthImage(connComp.PixelIdxList{i});
    % Compute normalized stroke width variation and compare to common value
    if std(strokewidths)/mean(strokewidths) > 0.35
        afterStrokeWidthTextMask(connComp.PixelIdxList{i}) = 0; % Remove from text candidates
    end
end
se1=strel('disk',25);
se2=strel('disk',7);

afterMorphologyMask = imclose(afterStrokeWidthTextMask,se1);
afterMorphologyMask = imopen(afterMorphologyMask,se2);
displayImage = colorImage;
displayImage(~repmat(afterMorphologyMask,1,1,3)) = 0;
areaThreshold = 5000; % threshold in pixels
connComp = bwconncomp(afterMorphologyMask);
stats = regionprops(connComp,'BoundingBox','Area');
boxes = round(vertcat(stats(vertcat(stats.Area) > areaThreshold).BoundingBox));
ocrtxt = ocr(afterStrokeWidthTextMask, boxes); % use the binary image instead of the color image
set(handles.text2,'String',strcat('Final Text: ',ocrtxt.Text));


% --- Executes on key press with focus on edit1 and none of its controls.
function edit1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
