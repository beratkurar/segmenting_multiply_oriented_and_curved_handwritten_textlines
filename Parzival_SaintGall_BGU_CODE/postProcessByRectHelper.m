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
    
%     STATS = regionprops(L, 'Area','BoundingBox');
%     area = [STATS.Area];
%     [~,loc] = max(area);
%     bb = STATS(loc).BoundingBox;

end