function [ LabelCost ] = MS_computeLinesLabelCost( L,Lines,numLines, intactLinesNum, max_orientation, max_response, theta )

acc = zeros(numLines+1,1);
mask_ = L(:);
L_ = Lines(:);

for i=1:length(L_)
    if ((L_(i)) && (mask_(i)))
        acc(L_(i)) = acc(L_(i))+1;
    end
end

DensityLabelCost = exp(0.2*max(acc)./acc);
DensityLabelCost(intactLinesNum+1:end) = 0;
if (intactLinesNum ~= numLines)
    OrientationLabelCost = LocalOrientationLabelCost(Lines, numLines, intactLinesNum, max_orientation, max_response, theta);
else
    OrientationLabelCost = zeros(numLines+1,1); 
end
LabelCost = OrientationLabelCost + DensityLabelCost;

% displayCost(Lines, OrientationLabelCost, 'Orientation');
% displayCost(Lines, DensityLabelCost, 'Density');
% displayCost(Lines, LabelCost, 'Sum');

end

function [LabelCost] = LocalOrientationLabelCost(Lines, numLines, intactLinesNum, max_orientation, max_response, theta)

PixelList = regionprops(Lines,'PixelList');

LabelCost = zeros(numLines+1,1);
localMaxOrientation = zeros(numLines,1);
border_mask = (Lines > 0)  &~ imerode(Lines > 0,ones(3));
SW = sum(sum(Lines > 0))/sum(sum(border_mask));
SE = strel('square', round(SW*18));
LineTheta = zeros(numLines,1);
for i=(intactLinesNum+1):numLines
    X = PixelList(i,1).PixelList;
    try
        [COEFF] = princomp(X);
        pca = COEFF(:,1);
        LineTheta(i) = atan(pca(2)/pca(1));
    catch
        LineTheta(i) = Inf;
        continue;
    end
    mask = imdilate(Lines == i, SE);
    res = estimateLocalOrientations(max_orientation, max_response, theta, mask);
    [~,I] = max(res(:,2));
    localMaxOrientation(i) = res(I,1);
    LabelCost(i) = 10*exp(50*(1-abs(cos(degtorad(localMaxOrientation(i)) - LineTheta(i)))));
end
end


function displayCost(Lines, LabelCost, titleTxt)
% TODO: use LUT
L_ = Lines(:);
displayCost = Lines*0;
for i=1:length(L_)
    if (L_(i))
        displayCost(i) = (LabelCost(L_(i)));
    end
end
figure; image(displayCost); title(titleTxt); axis image;

end