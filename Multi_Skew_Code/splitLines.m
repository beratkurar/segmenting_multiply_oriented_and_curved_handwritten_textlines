function [LabeledLines,LabeledLinesNum, intactLinesNum] = splitLines( lines, max_scale)
    [LabeledLines,num] = bwlabel(lines);
    fitting = approximateUsingPiecewiseLinearPCA(LabeledLines,num,[],0);    
    indices = (fitting < 0.8*max_scale) | (fitting == Inf);
    LineIndices = find(indices);
    NonLinesIndices = find(~indices);
    [intactLines, intactLinesNum] = bwlabel(ismember(LabeledLines,LineIndices));
    Lines2Split = ismember(LabeledLines,NonLinesIndices); 
    LabeledLinesNum = intactLinesNum;
    skel = bwmorph(Lines2Split,'skel',inf);
    B = bwmorph(skel, 'branchpoints');
    B_fat = imdilate(B,ones(3));
    brokenLines = skel & ~B_fat;
    [temp, LabeledLinesNum] = labelBrokenLines(Lines2Split, brokenLines, LabeledLinesNum);
    intactLines(temp > 0) = temp(temp > 0);
    LabeledLines = intactLines;
    
    %fixing labels that are not contiguous.
    for i=1:LabeledLinesNum
        [L, num] = bwlabel(LabeledLines == i);
        if (num > 1)
            Area = regionprops(L, 'Area');
            Area = [Area.Area];
            [~,loc] = max(Area);
            L(L == loc) = 0;
            LabeledLines(L > 0) = 0;
        end
    end
    
    %Display nice figure.
%     lines_fig = lines(1:1035,1:1500);
%     B_fig = B(1:1035,1:1500);
%     skel_fig = skel(1:1035,1:1500);
%     skel_fig = imdilate(skel_fig,ones(5));
%     fig = uint8(zeros(1035,1500));
%     fig(~lines_fig) = 128;
%     fig(lines_fig) = 0;
%     fig(skel_fig) = 255;
%     imshow(fig); hold on;
%     [y,x] = find(B_fig); plot(x,y,'ro','LineWidth',2); 
%     print('improvedExample','-djpeg','-r600');
 end

