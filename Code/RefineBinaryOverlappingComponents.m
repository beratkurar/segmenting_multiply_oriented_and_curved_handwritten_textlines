function [ result ] = RefineBinaryOverlappingComponents( CCsL,CCsNum,linesL,linesNum)

sz = size(CCsL);
result = zeros(sz);

res = zeros(CCsNum,linesNum);
CCsLF = CCsL(:);
linesLF = linesL(:);

for i=1:length(CCsLF)
    if (CCsLF(i) && linesLF(i))
        res(CCsLF(i),linesLF(i)) = 1;
    end
end

temp = sum(res,2);
CCindices = find(temp > 1);
skel = bwmorph(linesL,'skel', Inf);

%handling overlapping components
for i=1:length(CCindices)
    idx = CCindices(i);
    cc = (CCsL == idx);
    linesIndices =  find(res(idx,:));
    %Checking if it is really an overlapping component or just an
    %ascender/descender
    if (length(linesIndices) == 2)
        skelLabels = bwlabel(skel & ismember(linesL, linesIndices));
        temp = imreconstruct(cc & skelLabels,skelLabels>0);
        [~,num] = bwlabel(temp);
        if (num < 2)
            continue;
        end
    end
    ccPixels = regionprops(cc,'PixelList','PixelIdxList');
    ccPixelList = ccPixels.PixelList; 
    Dist = zeros(length(ccPixelList),length(linesIndices));
    for j=1:length(linesIndices)
        line = (linesL == linesIndices(j));
        linePixelList = regionprops(line,'PixelList');
        linePixelList = linePixelList.PixelList;
        [~,Dist(:,j)] = knnsearch(linePixelList,ccPixelList);
    end
     [~,loc] =  min(Dist,[],2);
     PixelIdxList =  ccPixels.PixelIdxList;
     for j=1:length(linesIndices)
         indices = loc == j;
         result(PixelIdxList(indices)) = linesIndices(j);
     end
end
end

