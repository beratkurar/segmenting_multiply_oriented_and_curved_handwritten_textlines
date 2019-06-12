function [ X ] = extractCentroids( L )
    temp = regionprops(L,'Centroid');
    centroids = [temp.Centroid];
    idx = 1:size(centroids,2);
    x = centroids(mod(idx,2) == 1);
    y = centroids(mod(idx,2) == 0);
    X = [x',y'];
end

