function [ mask, joinedFlag ] = JoinSegments(mask)

joinedFlag  = false;
while (1)
    [Lines,LinesNum] = bwlabel(mask);
    [ NsMatrixX, NsMatrixY] = computeDistBetweenLines(Lines,LinesNum);

     %estimating maximal line Height.
    [~, verSW]=my_sw_Length(mask > 0);
    thsY = max(max(verSW));
    %TODO: Replace this with something else.
    thsX = -115;

     NsMatrixY(logical(eye(size(NsMatrixY)))) = Inf;
     [X,Y] = find(NsMatrixY <= thsY & NsMatrixX >= thsX);

     if (isempty(X))
         break;
     end
     
    indices = sub2ind([LinesNum LinesNum], X, Y);
    distances = sqrt(NsMatrixX(indices).^2+NsMatrixY(indices).^2);
    [~,loc] = min(distances);

     newMask = JoinSegmentsHelper(Lines,[X(loc),Y(loc)]);
     [~,newLinesNum] = bwlabel(newMask);
     if (newLinesNum == LinesNum)
         break;
     else
         mask = newMask;
     end
     joinedFlag = true;
end

end


function mask = JoinSegmentsHelper(L,segments2Join)

mask = L;
len = length(segments2Join);
for i=1:len-1;
    bw1 = (L == segments2Join(i));
    bw2 = (L == segments2Join(i+1));
    D1 = bwdist(bw1, 'quasi-euclidean');
    D2 = bwdist(bw2, 'quasi-euclidean');
    D = round((D1 + D2) * 32) / 32;
    paths = imregionalmin(D);
    paths = bwmorph(paths,'skel',Inf);
    temp = mask;
    temp(bw1) = 0; temp(bw2) = 0;
    mask = (imdilate(paths,ones(30)) & ~imdilate(temp,ones(3)) | mask);
end

end

function [ NsMatrixX, NsMatrixY] = computeDistBetweenLines(Lines,LinesNum)

test = regionprops(Lines, 'PixelList');

endPoints = zeros(LinesNum,4);

for i=1:LinesNum
    temp = test(i,1).PixelList;
    [left, LeftLoc] = min(temp(:,1));
    [right, RightLoc] = max(temp(:,1));
    
    endPoints(i,1) = left; endPoints(i,2) = temp(LeftLoc,2);
    endPoints(i,3) = right; endPoints(i,4) = temp(RightLoc,2);
end

% endPoints = x_left, y_left, x_right, y_right.

NsMatrixX = pdist2(endPoints(:,3),endPoints(:,1),@minus);
NsMatrixY = pdist2(endPoints(:,4),endPoints(:,2));

end
