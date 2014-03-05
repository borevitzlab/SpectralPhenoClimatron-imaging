% Copyright (C) 2014 Joel Granados <joel.granados@gmail.com>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

function varargout = rosettedetect_gui(varargin)
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @rosettedetect_gui_OpeningFcn, ...
                       'gui_OutputFcn',  @rosettedetect_gui_OutputFcn, ...
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


% --- Executes just before rosettedetect_gui is made visible.
function rosettedetect_gui_OpeningFcn(hObject, eventdata, handles, varargin)

    % Choose default command line output for rosettedetect_gui
    handles.output = hObject;

    % This is where we will initialize the gui specific data structures.
    handles.current_dir = pwd;

    % Changes with every img. width/height
    handles.imgRatio = 1.5;

    % Contains all detected rosettes
    handles.rosettes = [];

    handles.zoom = zoom(handles.figure1);

    handles.ctr_pressed = 0;

    % Initialize the figure1 callback definitions.
    addlistener(handles.figure1, 'WindowKeyRelease', @on_key_release_callback);

    % Update handles structure
    guidata(hObject, handles);
    handles = put_image_in_axis(hObject);
    guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = rosettedetect_gui_OutputFcn(hObject, eventdata, handles)
    % Get default command line output from handles structure
    varargout{1} = handles.output;

% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
    close(handles.figure1);
    %exit;

% --- Called when an image needs to be uploaded to an axis.
function hl = put_image_in_axis (hObject)
    %initialize handles.
    handles = guidata(hObject);

    imagetypes = '*.gif;*.jpg;*.png;*.jpeg,*.GIF;*.JPG;*.PNG;*.JPEG';
    filename = double(0);
    pathname = double(0);

    % Don't accept the user pressing the cancel button.
    while ( ~ischar(filename) || ~ischar(pathname) )
        [filename, pathname, filterindex] =...
            uigetfile(imagetypes, 'Pick an image file',...
            'MultiSelect', 'off', handles.current_dir);

        if ( ~ischar(filename) || ~ischar(pathname) )
            msgboxText{1} =  'File name needed: You must select a file.';
            uiwait(msgbox(msgboxText,'You must select a file.'));
        end
    end

    input_image = fullfile(pathname, filename);
    if ( exist (char(input_image)) > 0 )
        handles.img = imread(char(input_image));

        % Changes with every img. width/height
        handles.imgRatio = size(handles.img,2)/size(handles.img,1);
        image(handles.img, 'Parent', handles.image_axis);

    else
        msgboxText{1} =  strcat('File not found: ', input_image);
        msgbox(msgboxText,'File Not Found', 'error');
    end

    % Remember to save the changes.
    hl = handles;
    guidata(hObject, handles);

% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % get new resized position
    globalPos = get(handles.figure1, 'Position');
    cpolp = get(handles.image_axis, 'Position'); % image axis.

    % Don't resize if it gets too small
    if ( globalPos(4) < 200 )
        globalPos(4) = cpolp(4) + 100 + 50;
        globalPos(3) = cpolp(3) + 50 + 50;
        set(handles.figure1, 'Position', globalPos);
        return;
    end

    % 100 -> lower margin, 50 upper margin.
    cpolp(4) = globalPos(4) - 100 - 50;
    cpolp(3) = cpolp(4) * handles.imgRatio;

    % 50 -> right margint, 50 left margin.
    globalPos(3) = cpolp(3) + 50 + 50;

    %make the changes.
    set(handles.image_axis, 'Position', cpolp);
    set(handles.figure1, 'Position', globalPos);

    % Remember to save the changes.
    guidata(hObject, handles);

% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, hndls)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
    %initialize handles.
    handles = guidata(hObject);

    if ( strcmp(eventdata.Key, 'l') == 1 || strcmp(eventdata.Key, 'L') == 1 )
        handles = put_image_in_axis ( hObject );
    end

    if ( strcmp ( eventdata.Modifier, 'control' ) == 1 )
        handles.ctr_pressed = 1;
        set( handles.zoom, 'Enable', 'on' );
    end

    % Remember to save the changes.
    guidata(hObject, handles);

% --- Executes on key release with focus on figure1 or any of its controls.
function figure1_WindowKeyReleaseFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was released, in lower case
%	Character: character interpretation of the key(s) that was released
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) released
% handles    structure with handles and user data (see GUIDATA)
    if ( strcmp ( eventdata.Key, 'control' ) == 1 )
        handles.ctr_pressed = 0;
    end

    % Remember to save the changes.
    guidata(hObject, handles);

% Specifically here to catch the callbacks in zoom mode. We can't do this with
% the normal figure1_WindowKeyPressFcn.
function on_key_release_callback (hObject, eventdata)
    %initialize handles
    handles = guidata(hObject);

    % if ctr_pressed == 1 and its not in figure1; then control was released.
    if ( handles.ctr_pressed == 1 ...
            && ~ismember('control',get(handles.figure1,'currentModifier')) )
        set ( handles.zoom, 'Enable', 'off' );
    end

    % Remember to save the changes.
    guidata(hObject, handles);

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % What button did the user click?
    % normal -> left click
    % alt -> right click
    % extend -> middle button. (might be different for mice
    % that dont have a middle button).

    mouseid = get(handles.figure1,'SelectionType');
    if ( strcmp( mouseid, 'normal' ) == 1 )
        mpos = get( handles.image_axis, 'CurrentPoint');
        lh = line ( [ mpos(1,1)-10 mpos(1,1)+10 ...
                      mpos(1,1)+10 mpos(1,1)-10 mpos(1,1)-10], ...
                    [ mpos(1,2)-10 mpos(1,2)-10 ...
                      mpos(1,2)+10 mpos(1,2)+10 mpos(1,2)-10], ...
                    'Color', [1 0 0], 'LineWidth', 1 );
        ud.center = [mpos(1,1) mpos(1,2)];
        ud.id = -1;
        set( lh, 'UserData', ud );

        set( lh, 'ButtonDownFcn',...
             @(src,event)button_press_on_line(src, event, lh));
    end

    % Remember to save the changes.
    guidata(hObject, handles);

function button_press_on_line(hObject, ~, line_handle)
    %initialize handles.
    handles = guidata(hObject);

    mouseid = get(handles.figure1,'SelectionType');
    if ( strcmp( mouseid, 'alt' ) == 1 )
        delete(line_handle);
    elseif ( strcmp( mouseid, 'extend' ) == 1 )
        ud = get(line_handle, 'UserData');
        answer = inputdlg({'Enter rosette id'},'Input',1,{num2str(ud.id)});
        if ( size(answer,1) > 0 )
            ud.id = str2num(answer{1});
            set(line_handle, 'UserData', ud);
        end
    end

function rosettes = populate_rosette_struct_from_lines ( userlines )
    rosettes = [];
    for ( i = 1:size(userlines,1) )
        rosettes(i).xdata = get(userlines(i), 'XData');
        rosettes(i).ydata = get(userlines(i), 'YData');
        rosettes(i).color = get(userlines(i), 'Color');
        rosettes(i).linewidth = get(userlines(i), 'LineWidth');
        ud = get(userlines(i), 'UserData');
        rosettes(i).center = ud.center;
        rosettes(i).id = ud.id;
        rosettes(i).subimg = [];

        clickCoords = rosettes(i).center;
        imgR = struct ( 'yFrom', clickCoords(2), 'yTo', clickCoords(2), ...
                        'xFrom', clickCoords(1), 'xTo', clickCoords(1) );
        rosettes(i).imgRange = imgR;
        rosettes(i).area = -1;
    end

function draw_lines ( rosettes )
    for ( i = 1:size(rosettes, 2) )
        ud.center = rosettes(i).center;
        ud.id = rosettes(i).id;
        lh = line ( rosettes(i).xdata, rosettes(i).ydata, ...
                    'Color', rosettes(i).color, ...
                    'LineWidth', rosettes(i).linewidth, ...
                    'UserData', ud );

        set( lh, 'ButtonDownFcn',...
             @(src,event)button_press_on_line(src, event, lh));
    end

% --- Executes on button press in segment.
function segment_Callback(hObject, eventdata, hndls)
% hObject    handle to segment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    %initialize handles.
    handles = guidata(hObject);

    % We want to reuse the original image. paint on a temp one.
    tmpimg = handles.img;

    % Create the rosettes struct with the image squares.
    handles.rosettes = []; % Remove previous rosettes.
    userlines = findobj(handles.figure1,'Type','line');
    handles.rosettes = populate_rosette_struct_from_lines(userlines);

    % Analyze handles.img
    [handles.rosettes, tmpimg] = analyzeImgRosette ( handles.rosettes, ...
                                                     handles.img );
    imshow(tmpimg, 'Parent', handles.image_axis);

    % Re-draw all lines
    draw_lines ( handles.rosettes );

    % Remember to save the changes.
    guidata(hObject, handles);


% --- Executes on button press in show.
function show_Callback(hObject, eventdata, handles)
% hObject    handle to show (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    %initialize handles.
    handles = guidata(hObject);

    imagetypes = '*.gif;*.jpg;*.png;*.jpeg,*.GIF;*.JPG;*.PNG;*.JPEG';
    pathname = double(0);

    % Don't accept the user pressing the cancel button.
    while ( ~ischar(pathname) )
        pathname = uigetdir(handles.current_dir);

        if ( ~ischar(pathname) )
            msgboxText{1} =  'Directory path needed: You must select a dir.';
            uiwait(msgbox(msgboxText,'You must select a directory.'));
        end
    end

    userlines = findobj(handles.figure1,'Type','line');
    handles.rosettes = populate_rosette_struct_from_lines ( userlines );
    filelist = dir(pathname);
    msgSize = 0; % used to output progress
    for ( i = 1:size(filelist, 1) )

        % Output progress
        progress = (i/size(filelist,1))*100;
        msg = sprintf('%4.2f -- %s  ', progress, filelist(i).name);
        fprintf(repmat('\b', 1, msgSize));
        fprintf( msg );
        msgSize = numel(msg);

        fregexp = regexp(filelist(i).name, '.*\.[jJ][pP][gGeE][gG]*');
        if ( size(fregexp, 1) == 0 )
            continue;
        end

        imgpath = fullfile ( pathname, filelist(i).name );
        img = imread(imgpath);

        [handles.rosettes, img] = analyzeImgRosette ( handles.rosettes,img );
    end


% --- Executes on button press in imgseries.
function imgseries_Callback(hObject, eventdata, handles)
% hObject    handle to imgseries (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    %initialize handles.
    handles = guidata(hObject);

    imagetypes = '*.gif;*.jpg;*.png;*.jpeg,*.GIF;*.JPG;*.PNG;*.JPEG';
    srcpath = double(0);
    dstpath = double(0);

    % Get the source directory
    msgboxText{1} =  'Select source directory.';
    uiwait(msgbox(msgboxText,'Select source directory.'));
    srcpath = uigetdir(handles.current_dir, 'Select Source');
    if ( ~ischar(srcpath) ) % End method if user hits cancel
        return;
    end

    % Get destination directory
    msgboxText{1} =  'Select destination directory.';
    uiwait(msgbox(msgboxText,'Select Destination.'));
    dstpath = uigetdir(handles.current_dir, 'Select destination directory');
    if ( ~ischar(dstpath) ) % End method if user hits cancel
        return;
    end

    userlines = findobj(handles.figure1,'Type','line');
    handles.rosettes = populate_rosette_struct_from_lines ( userlines );
    filelist = dir(srcpath);
    msgSize = 0; % used to output progress
    for ( i = 1:size(filelist, 1) )

        % Output progress
        progress = (i/size(filelist,1))*100;
        msg = sprintf('%4.2f -- %s  ', progress, filelist(i).name);
        fprintf(repmat('\b', 1, msgSize));
        fprintf( msg );
        msgSize = numel(msg);

        fregexp = regexp(filelist(i).name, '.*\.[jJ][pP][gGeE][gG]*');
        if ( size(fregexp, 1) == 0 )
            continue;
        end
        filelist(i).name

        frompath = fullfile ( srcpath, filelist(i).name );
        topath = fullfile ( dstpath, filelist(i).name );

        img = imread(frompath);
        [handles.rosettes, img] = analyzeImgRosette ( handles.rosettes,img );

        imwrite ( img, topath );

        %FIXME: Do we really want to show progress with images?
        imshow(img, 'Parent', handles.image_axis);
        pause(1);
    end

    % End by showing original image. No lines!
    imshow(handles.img, 'Parent', handles.image_axis);
    handles.rosettes = [];

    % Remember to save the changes.
    guidata(hObject, handles);

% --- Executes on button press in vector.
function vector_Callback(hObject, eventdata, handles)
% hObject    handle to vector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
