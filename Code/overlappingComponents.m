function [Labeling] = overlappingComponents( left, right,I)
% left = binary image
% right = lines Mask
[leftL,leftNum] = bwlabel(left);
[rightL,rightNum] = bwlabel(right);
res = zeros(leftNum,rightNum);
leftLF = leftL(:);
rightLF = rightL(:);

for i=1:length(leftLF)
    if (leftLF(i) && rightLF(i))
        res(leftLF(i),rightLF(i)) = 1;
    end
end

temp = sum(res,2);
indices = find(temp > 1);

for i=1:length(indices)
   leftL = cutOverlappingComponent(I,leftL,indices(i),right);
end
Labeling = leftL;
end

function L = cutOverlappingComponent(I,L,index,linesMask)

[dimX,dimY]=size(L);
s=regionprops(L==index,'BoundingBox');
box = s.BoundingBox;
row=max(floor(box(2))-1,1);
col=max(floor(box(1))-1,1);
width=floor(box(3));
height=floor(box(4));
rowEnd=min(row+height+1,dimX);
colEnd=min(col+width+1,dimY);

rect = [col  row (colEnd-col) (rowEnd-row)];

croppedImg = imrotate(imcrop(I,rect),-90);
restricted = imrotate(imcrop(linesMask,rect),-90);
restricted = imdilate(restricted,ones(50,1));
IM2 = imcomplement(restricted);
[Ltemp,~] = bwlabel(IM2);

indices = unique(union(Ltemp(:,1),Ltemp(:,end)));
restricted = restricted | (ismember(Ltemp,indices));

g = carveNSeams(croppedImg,1,restricted,false);
figure; imshow(imrotate(g,90));
seam = (g==1);
seam = imdilate(imrotate(seam,90),ones(3,3));
res = imcrop(L,rect);
diff = (res &~ seam);
L(row:rowEnd,col:colEnd) = diff;
%remainder = res &~ diff;
%figure; imshow(diff); figure; imshow(remainder);
end