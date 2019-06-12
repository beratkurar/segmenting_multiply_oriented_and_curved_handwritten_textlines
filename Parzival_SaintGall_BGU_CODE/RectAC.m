function [ rect ] = RectAC(mask,rect, stepSize)

IntegralImg1 =  integralImage(mask);
IntegralImg2 =  integralImage(~mask);

rect(1) = rect(1) + 1;
rect(2) = rect(2) + 1;

partialSum = zeros(stepSize,2);

sz = size(mask);

for loop =1:2
    
    % Right
    i = 1;
    tempRect = rect;
    rb = min(rect(3)+stepSize/2,sz(2)-rect(1));
    partialSum = partialSum*0;
    for width = 1:rb
        tempRect(3) = width;
        partialSum(i,1) = computeCost(IntegralImg1,IntegralImg2,tempRect);
        partialSum(i,2) = width;
        i= i+1;
    end
    [~,loc] = max(partialSum);
    rect(3) = partialSum(loc(1),2);
    
    % Left
    i = 1;
    tempRect = rect;
    lb = max(1,rect(1)-stepSize/2+1);
    rb = min(rect(1)+rect(3)-1,rect(1)+stepSize/2);
    partialSum = partialSum*0;
    for leftEdge = lb:rb
        offset = leftEdge - rect(1);
        tempRect(1) = leftEdge; tempRect(3) = rect(3)-offset;
        partialSum(i,1) = computeCost(IntegralImg1,IntegralImg2,tempRect);
        partialSum(i,2) = leftEdge;
        i= i+1;
    end
    [~,loc] = max(partialSum);
    leftEdge = partialSum(loc(1),2);
    offset = leftEdge - rect(1);
    rect(1) = leftEdge; rect(3) = rect(3)-offset;
    
    % Up
    i = 1;
    tempRect = rect;
    lb = max(1,rect(2)-stepSize/2+1);
    ub = min(rect(2)+rect(4)-1,rect(2)+stepSize/2);
    partialSum = partialSum*0;
    for upperEdge = lb:ub
        offset = upperEdge - rect(2);
        tempRect(2) = upperEdge; tempRect(4) = rect(4)-offset;
        partialSum(i,1) = computeCost(IntegralImg1,IntegralImg2,tempRect);
        partialSum(i,2) = upperEdge;
        i= i+1;
    end
    [~,loc] = max(partialSum);
    upperEdge = partialSum(loc(1),2);
    offset = upperEdge - rect(2);
    rect(2) = upperEdge; rect(4) = rect(4)-offset;
    
    
    % Down
    i = 1;
    tempRect = rect;
    lb = min(rect(4)+stepSize/2-1,sz(1)-rect(2));
    partialSum = partialSum*0;
    for height = 1:lb
        tempRect(4) = height;
        partialSum(i,1) = computeCost(IntegralImg1,IntegralImg2,tempRect);
        partialSum(i,2) = height;
        i= i+1;
    end
    [~,loc] = max(partialSum);
    rect(4) = partialSum(loc(1),2);
end

end

function cost = computeCost(intImg1,intImg2,rect)
    rect2_4 = max(round(rect(2)+rect(4)-1),1);
    rect1_3 = max(round(rect(1)+rect(3)-1),1);
    rect2 = max(round(rect(2)-1),1);
    rect1 = max(round(rect(1)-1),1);

    sum1 = intImg1(rect2_4,rect1_3)+intImg1(rect2,rect1)...
        -intImg1(rect2,rect1_3)-intImg1(rect2_4,rect1);

    sum2 = intImg2(rect2_4,rect1_3)+intImg2(rect2,rect1)...
        -intImg2(rect2,rect1_3)-intImg2(rect2_4,rect1);

    cost = sum1-sum2;
end


