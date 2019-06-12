function [res, brokenLinesNum] = labelBrokenLines(Lines2Split, brokenLines, LabeledLinesNum)

pixels = regionprops(Lines2Split,'PixelList');
Y = concatenatePixelLists(pixels);
pixels = regionprops(brokenLines,'PixelList');
X = concatenatePixelLists(pixels);


IDX = knnsearch(X(:,1:2),Y(:,1:2));


res = zeros(size(Lines2Split));
for i=1:length(Y)
    res(Y(i,2),Y(i,1)) = X(IDX(i),3)+LabeledLinesNum;
end

brokenLinesNum = max(max(max(res)),LabeledLinesNum);
end

function res = concatenatePixelLists(pixels)
structsNum = length(pixels);

sz = 0;
for i = 1:structsNum
    temp = pixels(i).PixelList;
    sz = sz + size(temp,1);
end

res =  zeros(sz,3);
sz = 0;
for i = 1:structsNum
    temp = pixels(i).PixelList;
    res(sz+1:sz+size(temp,1),1:2) = temp;
    res(sz+1:sz+size(temp,1),3) = i;
    sz = sz + size(temp,1);
end    
end
