function Lines = PostProcessParzival(I, Result, Lines, rect)

sz = size(Result);
mask = false(sz);
mask(rect(2):rect(2)+rect(4)-1,rect(1):rect(1)+rect(3)-1) = true;

K = 4;

[data, ~] = imstack2vectors(I,mask);
[IDX,C] = kmeans(double(data),K);
kmeansResult = reshape(IDX,[rect(4) rect(3)]);
res = zeros(K,1);
for i=1:K
    res(i) = norm(C(i,:));
end
[~,loc] = min(res);

mask = false(sz);
mask(rect(2):rect(2)+rect(4)-1,rect(1):rect(1)+rect(3)-1) = (kmeansResult == loc);

[L_lines,~] = bwlabel(Lines);
[lines] = CompactTextLines(Result>0, L_lines);


temp = imclose(mask & lines,ones(60,1));
[L,~] = bwlabel(temp);
%Extract 2 largest connected components
STATS = regionprops(L, 'Area','ConvexImage','BoundingBox');
area = [STATS.Area];
tempArea = sort(area);
max1 = tempArea(end);
max2 = tempArea(end-1);

loc1 = find(area == max1);
loc2 = find(area == max2);

bb1 = round(STATS(loc1).BoundingBox);
bb2 = round(STATS(loc2).BoundingBox);

conv1 = STATS(loc1).ConvexImage;
conv2 = STATS(loc2).ConvexImage;

sz = size(temp);
temp = zeros(sz);

temp(bb1(2):bb1(2)+bb1(4)-1,bb1(1):bb1(1)+bb1(3)-1) = conv1;
temp(bb2(2):bb2(2)+bb2(4)-1,bb2(1):bb2(1)+bb2(3)-1) = conv2;

Lines = lines & temp;
Lines = bwareaopen(Lines, 2000);

end

