function [ res ] = estimateLocalOrientations(max_orientation, max_response, theta, mask)
    
    res = zeros(length(theta),2);
    flatImg = max_orientation(:);
    flatMask = mask(:);
    flatResponse = max_response(:);
    for i=1:length(flatImg)
        if (flatMask(i) && flatImg(i))
            [loc] = flatImg(i);
            res(loc,1) = theta(loc);
            res(loc,2) = res(loc,2) + flatResponse(i);
        end
    end
end