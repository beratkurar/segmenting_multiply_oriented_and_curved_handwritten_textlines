function [ result,Labels, finalLines, newLines, oldLines ] = multiSkewDatasetLinesExtraction(I, bin, varargin)
    if (nargin == 2)
        delta_theta = 2.5;
        theta = 0:delta_theta:180-delta_theta;
        options = struct('EuclideanDist',true, 'mergeLines', true, 'EMEstimation',false, 'theta',theta, 'skew',false,...
            'cacheIntermediateResults', false, 'thsLow',10,'thsHigh',200,'Margins', 0.03);
    else
        options = varargin{1};
    end
    charRange=estimateCharsHeight(I,bin,options);

    [max_orientation, ~, max_response] = MS_filterDocument(~bin,charRange(1):charRange(2), options.theta);

    [L,num] = bwlabel(bin);

    [~, oldLines] = NiblackPreProcess(max_response, bin, 2.*round(charRange(2))+1);
    [LabeledLines, LabeledLinesNum, intactLinesNum] = splitLines(oldLines, charRange(2));
    [LabelCost] = MS_computeLinesLabelCost( L,LabeledLines,LabeledLinesNum, intactLinesNum, max_orientation, max_response, options.theta);
    [~,~,newLines ] = MS_PostProcessByMRF(L, num, LabeledLines, LabeledLinesNum, LabelCost, charRange, options);
    [newLines, newLinesNum] = permuteLabels(newLines);
    %figure; imshow(imfuse(L>0,label2rgb(newLines),'blend'));

    [combinedLines, newSegments] = JoinSegmentsSkew(L, newLines, newLinesNum, charRange(2));
    
    combinedLinesNum = max(max(combinedLines));
    [LabelCost] = MS_computeLinesLabelCost(L,combinedLines,combinedLinesNum, combinedLinesNum, max_orientation, max_response, options.theta);
    [result,Labels,finalLines] = MS_PostProcessByMRF(L, num, combinedLines, combinedLinesNum, LabelCost, charRange, options);
end