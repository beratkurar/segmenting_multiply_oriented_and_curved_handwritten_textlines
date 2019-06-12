function [finalResult,finalLines,rect] = postProcessByRect( LabedLines,result)
    linesMask = logical(LabedLines>0);
    [verSW]=ver_sw_Length(linesMask);
    temp = verSW(:);
    temp(temp == 0) = [];
    Height = mode(temp);
    newLines = imclose(linesMask,ones(round(Height*1.85),1));
    newLines = imdilate(newLines,ones(45,1));
    [L,~] = bwlabel(newLines);
    STATS = regionprops(L, 'Area','BoundingBox');
    area = [STATS.Area];
    [~,loc] = max(area);
    bb = STATS(loc).BoundingBox;
    initialRect = round(bb);
    sz = size(linesMask);
    rect = RectAC(imfill(newLines,'holes'), initialRect,max(sz(1),sz(2))); 
    [finalResult,finalLines,rect] = postProcessByRectHelper(LabedLines,result,rect);
end

function [finalResult,finalLines,rect] = postProcessByRectHelper(LabedLines,result,rect)
    sz = size(LabedLines);
    rectMask = false(sz);
    rectMask(rect(2):rect(2)+rect(4), rect(1):rect(1)+rect(3)) = true;
    intersection = rectMask & LabedLines;
    finalLines = LabedLines;
    finalLines(~intersection) = 0;
    lineIndices = unique(finalLines);
    if (lineIndices(1) == 0)
        lineIndices(1) = [];
    end
    
    mask = ismember(result,lineIndices);
    mask(~rectMask) = 0;
    finalResult=result;
    finalResult(~mask)=0;
    
    % Removing very short lines (regarded as noise).
    STATS = regionprops(finalLines, 'BoundingBox');
    bb = [STATS.BoundingBox];
    idx = 1:length(bb);
    % rect = [x y width height]
    Width = bb(mod(idx,4) == 3);   
    [maxWidth] = max(Width);
    shortLineIndices = find((Width./maxWidth) < 0.2);
    pixels2remove = ismember(finalResult,shortLineIndices);
    finalResult(pixels2remove) = 0;
    lines2remove = ismember(finalLines,shortLineIndices);
    finalLines(lines2remove) = 0;

end