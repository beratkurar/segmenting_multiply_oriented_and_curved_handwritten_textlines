function [combinedLines, newSegments] = JoinSegmentsSkew(L, newLines, newLinesNum, max_scale)

numOfKnots = 20;
pixelList = regionprops(newLines, 'PixelList');

endPoints = zeros(newLinesNum, 8);
%figure; imshow(newLines); hold on;
for i=1:newLinesNum
    X = pixelList(i,1).PixelList;
    try
        [COEFF] = princomp(X);
        pca = COEFF(:,1);
        theta = atan(pca(2)/pca(1));
        R = [cos(-theta) -sin(-theta); sin(-theta), cos(-theta)];
        X_Rot = R*X';
    catch
        fprintf('princomp failed\n');
        continue;
    end
    
    x = X_Rot(1,:);
    y = X_Rot(2,:);
    
    try
        slm = slmengine(x,y,'degree',1,'knots',numOfKnots,'plot','off');
    catch
        fprintf('problem in CC %d\n',i);
        continue;
    end
    
    x_endP = slm.knots([4,1, numOfKnots-3,numOfKnots]);
    y_endP = slm.coef([4,1, numOfKnots-3,numOfKnots]);
    
    R_inv = [cos(theta) -sin(theta); sin(theta), cos(theta)];
    temp = R_inv*[x_endP,y_endP]';
    endPoints(i,:) = temp(:)';
end

externalEP = zeros(2*newLinesNum,2);
externalEP(1:newLinesNum,:) = endPoints(:,3:4);
externalEP(1+newLinesNum:2*newLinesNum,:) = endPoints(:,7:8);

K = min(4,2*newLinesNum-1);
[IDX,D] = knnsearch(externalEP,externalEP,'K',K+1);
IDX(:,1) = [];
D(:,1) = [];

DistMatrix = Inf((2*newLinesNum),K);

for j=1:K
    for i=1:2*newLinesNum
        lhsIdx = mod(i,newLinesNum);
        if (lhsIdx == 0)
            lhsIdx = newLinesNum;
        end
        rhsIdx = mod(IDX(i,j),newLinesNum);
        if (rhsIdx == 0)
            rhsIdx = newLinesNum;
        end
        if (lhsIdx == rhsIdx)
            DistMatrix(i,j) = Inf;
        else
            if (IDX(i,j) > newLinesNum)
                rhsOuterIndices = 7:8;
                rhsInnerIndices = 5:6;
            else
                rhsOuterIndices = 3:4;
                rhsInnerIndices = 1:2;
            end
            if (i > newLinesNum)
                lhsOuterIndices = 7:8;
                lhsInnerIndices = 5:6;
            else
                lhsOuterIndices = 3:4;
                lhsInnerIndices = 1:2;
            end
            l = norm(endPoints(lhsIdx,lhsOuterIndices) -  endPoints(lhsIdx,lhsInnerIndices)) +...
                norm(endPoints(rhsIdx,rhsOuterIndices) -  endPoints(rhsIdx,rhsInnerIndices)) +...
                norm(endPoints(rhsIdx,rhsOuterIndices) -  endPoints(lhsIdx,lhsOuterIndices));
            l1 = norm(endPoints(rhsIdx,rhsInnerIndices) - endPoints(lhsIdx,lhsInnerIndices));
            DistMatrix(i,j) = l/l1;
        end
    end
end

DistMatrix = exp(15*(DistMatrix-1));
tempMat = Inf(2*newLinesNum, 2*newLinesNum);
for i=1:2*newLinesNum
    [~,j] = min(DistMatrix(i,:));
    tempMat(i,IDX(i,j)) = DistMatrix(i,j);
    tempMat(IDX(i,j),i) = DistMatrix(i,j);
end


for i=1:newLinesNum
    tempMat(i,i+newLinesNum) = 0;
    tempMat(i+newLinesNum,i) = 0;
end

cnt = sum(sum(tempMat ~= Inf));
E = zeros(cnt+ 4*newLinesNum,2);
w = zeros(cnt+ 4*newLinesNum,1);

idx = 1;
for j=1:2*newLinesNum
    for i=1:2*newLinesNum
        if (tempMat(i,j) ~= Inf)
            E(idx,1:2) = [i,j];
            w(idx) = tempMat(i,j);
            idx = idx + 1;
        end
    end
end

DensityLabelCost = extractDensity(L,newLines, newLinesNum);
DensityLabelCost(DensityLabelCost > 10000) = 10000;

% n + 1 will be the total size of the graph.
n = 2*newLinesNum;
% root = n+1;

E(cnt+1:cnt+n,1) = n+1;
E(cnt+1:cnt+n,2) = 1:n;
E(cnt+n+1:cnt+2*n,1) = 1:n;
E(cnt+n+1:cnt+2*n,2) = n+1;
w(cnt+1:cnt+2*n) = repmat(DensityLabelCost,4,1);

A = sparse(E(:,1), E(:,2), w, n+1, n+1); % create a weighted sparse matrix
As = sparse(E(:,1), E(:,2), true, n+1, n+1);
options.edge_weight = edge_weight_vector(As,A);
options.root = n+1;
[i, j, v] = mst(As,options);

newE = [i,j];
[row,~] = find(newE == n+1);
newE(row,:) = [];

newA = sparse(newE(:,1), newE(:,2), 1, n, n);
newA = newA + newA';
[ci, sizes] = components(newA);

newLabeling = ci(1:newLinesNum);

LUT = zeros(1,65536,'uint16');
LUT(2:length(newLabeling)+1) = newLabeling';
combinedLines = double(intlut(uint16(newLines), LUT));
newSegments = zeros(size(newLines));
newSegmentsCnt = 1;
cache = cell(newLinesNum,1);
for i=1:length(newE)
    lhsIdx = mod(newE(i,1),newLinesNum);
    if (lhsIdx == 0)
        lhsIdx = newLinesNum;
    end
    rhsIdx = mod(newE(i,2),newLinesNum);
    if (rhsIdx == 0)
        rhsIdx = newLinesNum;
    end
    if (lhsIdx == rhsIdx)
        continue;
    else
         [mask, LabelNum] = JoinSegmentsHelper(L, newLines, combinedLines, [lhsIdx,rhsIdx], max_scale, pixelList);
         if (LabelNum)
             newSegments(mask) = newSegmentsCnt;
             combinedLines(mask) = LabelNum;
             newSegmentsCnt = newSegmentsCnt + 1;
         end
    end
end


%fixing labels that are not contiguous.
cnt = max(max(combinedLines));
for i=1:cnt
    [L, num] = bwlabel(combinedLines == i);
    if (num > 1)
        for j=1:num
            combinedLines(L==j) = cnt+1;
            cnt = cnt + 1;
        end
    end
end

[combinedLines, ~] = permuteLabels(combinedLines);


end

% TODO: change the join operaton to occur after changing the labels.
function [mask, LabelNum] = JoinSegmentsHelper(L, Lines, combinedLines, segments2Join, max_scale, pixelList)

mask = Lines;
len = length(segments2Join);

minX=Inf; minY=Inf; maxX=0; maxY=0;
for i=1:length(segments2Join)
    X = pixelList(segments2Join(i),1).PixelList;
    minX = min(min(X(:,1)),minX);
    minY = min(min(X(:,2),minY));
    maxX = max(max(X(:,1),maxX));
    maxY = max(max(X(:,2),maxY));
end

CroppedLines = Lines(minY:maxY,minX:maxX);

for i=1:len-1;
    bw1 = (CroppedLines == segments2Join(i));
    bw2 = (CroppedLines == segments2Join(i+1));
    D1 = bwdist(bw1, 'quasi-euclidean');
    D2 = bwdist(bw2, 'quasi-euclidean');
    D = round((D1 + D2) * 32) / 32;
    paths = imregionalmin(D);
    paths = bwmorph(paths,'skel',Inf);
    SE = strel('square', 10);
    tempMask = imdilate(paths,SE);
    mask = false(size(L)); mask(minY:maxY,minX:maxX) = tempMask;
    AdjacentIndices = unique(combinedLines(mask));
    AdjacentIndices(AdjacentIndices == 0) = [];
    if ((length(AdjacentIndices) > 1) || any(any(mask & L)) == 0)
        LabelNum = false;
    else
        mask = mask &~ combinedLines;
        bw1 = (Lines == segments2Join(i));
        bw2 = (Lines == segments2Join(i+1));
        t = imreconstruct(bw1 | bw2, combinedLines == AdjacentIndices | mask);
        [ fitting ] = approximateUsingPiecewiseLinearPCA( t,1, 0, 0 );
        if (fitting < 0.8 * max_scale)
            LabelNum = AdjacentIndices;
        else
            LabelNum = false;
        end
    end
end
end

function DensityLabelCost = extractDensity(L,Lines,numLines)
% TODO: unite with the other code.
acc = zeros(numLines,1);
mask_ = L(:);
L_ = Lines(:);

for i=1:length(L_)
    if ((L_(i)) && (mask_(i)))
        acc(L_(i)) = acc(L_(i))+1;
    end
end

DensityLabelCost = max(exp(0.2*max(acc)./acc),6.5);
end
