function [result,Labels, linesMask, newLines] = ExtractLines(I, bin, varargin)
    if (nargin == 2)
        options = struct('EuclideanDist',true, 'mergeLines', true, 'EMEstimation',false,... 
            'cacheIntermediateResults', false, 'thsLow',15,'thsHigh',Inf,'Margins', 0);
    else
        options = varargin{1};
    end
    charRange=estimateCharsHeight(I,bin,options);
    if (isnan(charRange(1)))
        charRange=[13,16];
    end
    if (options.cacheIntermediateResults &&...
            exist([options.dstPath,'masks/',options.sampleName,'.png'], 'file') == 2)
        linesMask = imread([dstPath,'masks/',sampleName,'.png']);
    else
        linesMask = LinesExtraction(I, charRange(1):charRange(2));
    end
    [L,num] = bwlabel(bin);
    if (num<=2)
        fprintf('only one component \n')
        result=L;
        Labels=1;
        newLines=[];
    else
        [result,Labels,newLines] = PostProcessByMRF(L,num,linesMask,charRange,options);
    end
end
