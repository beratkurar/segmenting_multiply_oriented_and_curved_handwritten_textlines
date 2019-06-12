function [ mask ] = preProcessSaintGall( I )
[M, N, n] = size(I);
Q = M*N;
X = reshape(I, Q, n);
nanflag = true;

while (nanflag)
    [IDX, C] = kmeans(double(X), 2, 'maxiter',200, 'emptyaction', 'drop');
    nanflag = any(any(isnan(C)));
end

labels = reshape(IDX, size(I,1), size(I,2));
 [mask, ~] = extractPaperMask(labels);
 mask = imfill(mask,'holes');
 mask = imerode(mask,ones(100));
end

function [mask, bb] = extractPaperMask(kMeansRes)
    [L1,num1] =bwlabel(kMeansRes == 1); features1 = getCCfeatures(L1,num1,true);
    [val1, loc1] = max(features1(:,3));
    [L2,num2] =bwlabel(kMeansRes == 2); features2 = getCCfeatures(L2,num2,true);
    [val2, loc2] = max(features2(:,3));    
    
    if (val1 > val2)
        mask = L1 == loc1;
    else
        mask = L2 == loc2;
    end
    bb=regionprops(mask,'BoundingBox');
    bb = bb.BoundingBox;
end
