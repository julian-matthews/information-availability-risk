function windows = createWindows(cfg,nWindows,width,height,location)

% Make a base Rect of width by height pixels
baseRect = [0 0 width height];
if strcmpi(location,'centre')
    scaleFactor = 8;
elseif strcmpi(location,'left')
    scaleFactor = 8;
elseif strcmpi(location,'right')
    scaleFactor = 8;
end

squareXpos = [];
baseColours  = [];
        
for rect_i=1:nWindows
    if strcmpi(location,'left')
    squareXpos   =[squareXpos  ...
        (cfg.width * ((rect_i+1)/(scaleFactor*2)))];
    elseif strcmpi(location,'right')
         squareXpos   =[squareXpos  ...
        cfg.width-(cfg.width*((rect_i+1)/(scaleFactor*2)))];
    else
         squareXpos   =[squareXpos  ...
        (cfg.width * ((rect_i+1)/(scaleFactor*2))+cfg.xCentre/2)];
    end
    baseColours = [baseColours;192 197 206];
end
if strcmpi(location,'right')
    squareXpos = fliplr(squareXpos);
end
baseColours = baseColours';

% Make our rectangle coordinates
allRects = nan(4, nWindows);
for i = 1:nWindows
    allRects(:, i) = CenterRectOnPointd(baseRect, squareXpos(i), cfg.yCentre);
end

windows.squareXpos = squareXpos;
windows.baseColours = baseColours;
windows.allRects   = allRects;