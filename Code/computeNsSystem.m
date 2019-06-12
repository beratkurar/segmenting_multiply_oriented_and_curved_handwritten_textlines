function [ sparseNs ] = computeNsSystem( L,num, options )

X = extractCentroids(L);
% Number of Neighbours.
K = 2;
if (options.EuclideanDist)
    [IDX,D] = knnsearch(X,X,'K',K+1);
    IDX(:,1) = []; D(:,1) = [];
else % Non-Euclidean distance.
    Cov = [1 0; 0 1/3];
    [IDX,D] = knnsearch(X,X,'K',K+1,'Distance','mahalanobis','Cov',Cov);
end

sparseNs = zeros(num,num);
for j=1:K
    for i=1:num
        sparseNs(i,IDX(i,j)) = D(i,j);
    end
end

temp = abs(min(sparseNs-sparseNs',0))+sparseNs;
sparseNs = triu(temp);

end

