function [ result,Labels, finalLines, newLines, oldLines ] = multiSkewLinesExtraction(I, bin, varargin)
    if (nargin == 2)
        delta_theta = 2.5;
        theta = 0:delta_theta:180-delta_theta;
        options = struct('EuclideanDist',true, 'mergeLines', true, 'EMEstimation',false, 'theta',theta, 'skew',false,...
            'cacheIntermediateResults', false, 'thsLow',10,'thsHigh',200,'Margins', 0.03);
    else
        options = varargin{1};
    end
    charRange=estimateCharsHeight(I,bin,options);
    if (options.cacheIntermediateResults && exist([options.dstPath,'masks/',options.sampleName,'.mat'], 'file') == 2)
        load([options.dstPath,'masks/',options.sampleName]);
    else
        [max_orientation, ~, max_response] = MS_filterDocument(~bin,charRange(1):charRange(2), options.theta);
        if (options.cacheIntermediateResults)
            save([options.dstPath,'masks/',options.sampleName],'max_response','max_orientation');
        end
    end
    [L,num] = bwlabel(bin);
    if (options.cacheIntermediateResults && exist([options.dstPath,'broken_lines/',options.sampleName,'.mat'], 'file') == 2)
        load([options.dstPath,'broken_lines/',options.sampleName]);
    else
        [~, oldLines] = NiblackPreProcess(max_response, bin, 2.*round(charRange(2))+1);
        [LabeledLines, LabeledLinesNum, intactLinesNum] = splitLines(oldLines, charRange(2));
        [LabelCost] = MS_computeLinesLabelCost( L,LabeledLines,LabeledLinesNum, intactLinesNum, max_orientation, max_response, options.theta);
        [~,~,newLines ] = MS_PostProcessByMRF(L, num, LabeledLines, LabeledLinesNum, LabelCost, charRange, options);
        [newLines, newLinesNum] = permuteLabels(newLines);
        figure; imshow(imfuse(L>0,label2rgb(newLines),'blend'));
        if (options.cacheIntermediateResults)
            save([options.dstPath,'broken_lines/',options.sampleName],'newLines','newLinesNum', 'oldLines');
        end
    end

    [combinedLines, newSegments] = JoinSegmentsSkew(L, newLines, newLinesNum, charRange(2));
    
    combinedLinesNum = max(max(combinedLines));
    [LabelCost] = MS_computeLinesLabelCost(L,combinedLines,combinedLinesNum, combinedLinesNum, max_orientation, max_response, options.theta);
    [result,Labels,finalLines] = MS_PostProcessByMRF(L, num, combinedLines, combinedLinesNum, LabelCost, charRange, options);
end