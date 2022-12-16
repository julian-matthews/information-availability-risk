function machine=createMachine(cfg,nWindows,width,height,location)
% Make a base Rect of width by height pixels
baseRect = [0 0 width height];
if strcmpi(location,'centre')
    scaleFactor = 1/2;
elseif strcmpi(location,'left')
    scaleFactor = 1/4;
elseif strcmpi(location,'right')
    scaleFactor = 3/4;
end

squareXpos = [];
baseColours  = [];
for rect_i=1:nWindows
    squareXpos = [squareXpos (cfg.width * scaleFactor)];
    baseColours = [baseColours;192 197 206];
end

baseColours = baseColours';

% Make our rectangle coordinates
allRects = nan(4, nWindows);
for i = 1:nWindows
    allRects(:, i) = CenterRectOnPointd(baseRect, squareXpos(i), cfg.yCentre);
end

machine.squareXpos = squareXpos;
machine.baseColours = baseColours;
machine.allRects   = allRects;