function [linesMask] = MS_linesExtraction(I, scales, options, varargin)
% Extraction using local adaptive threshold.

if (nargin == 3)
    [~, ~, max_response] = filterDocument(I,scales, options.theta);
else
    max_response = varargin{1};
end

max_scale = max(scales);
close all;

endThs = 50;
beginThs = findRootThreshold(max_response,endThs);
Thresholds = beginThs:endThs;
linesMask = TraverseTree(max_response,Thresholds, max_scale, options);
end


function res = TraverseTree(max_response,Thresholds,max_scale, options)
sz = size(max_response);
res = false(sz);
markedChilds=[];
for i=1:length(Thresholds)
    ths = Thresholds(i);
    
    parentMask = max_response > ths;
    childMask = max_response > ths+1;
    
    [childL,childNum] = bwlabel(childMask);
    [parentL, parentNum] = bwlabel(parentMask);
    links = BuildTreeLayer( parentL, parentNum, childL, childNum);
    
    marked = markedChilds;
    if (options.skew)
        fitting = approximateUsingPiecewiseLinearPCA(parentL,parentNum,marked, 3*max_scale);
    else
        fitting = approximateUsingPiecewiseLinear(parentL,parentNum,marked, 3*max_scale);
    end
      
    LineIndices = find(fitting < 0.8*max_scale);
    
    newIndices = setdiff(LineIndices,marked);
    marked = union(marked,newIndices);
    markedChilds = links(:,marked);
    markedChilds = setdiff(markedChilds,0);
    res = res | ismember(parentL, newIndices);
    if (isequal(marked',1:parentNum))
        break;
    end
end
end

function beginThs = findRootThreshold(max_response,my_max)
my_min = min(min(max_response));

interval = my_max - my_min;
i = interval/2+my_min;

while(interval > 0.5)
    mask = max_response > i;
    [~,num] = bwlabel(mask);
    if (num == 1)
        my_min = i;
    else
        my_max = i;
    end
    interval = my_max - my_min;
    i = interval/2+my_min;
end
beginThs = i-0.5;
end