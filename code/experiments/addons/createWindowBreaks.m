function windowBreaks=createWindowBreaks(windows)
windowBreaks.xStart = windows.allRects(1,:) + std(windows.allRects(1,:))*.03;
windowBreaks.yStart = windows.allRects(2,:);
windowBreaks.xEnd   = windows.allRects(3,:) - std(windows.allRects(1,:))*.03;
windowBreaks.yEnd   = windows.allRects(4,:);
windowBreaks.colour = windows.baseColours(:,1);