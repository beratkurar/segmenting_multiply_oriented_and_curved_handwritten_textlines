function [ Dc ] = computeLinesDC(Lines,numLines,L,num, upperHeight )
X =extractCentroids(L);
temp = regionprops(Lines,'PixelList');
Dc = zeros(numLines+1,num);

%Cov = [1 0; 0 1/3];

for i=1:numLines
    pixelList = temp(i,1).PixelList;
    
   % [~,D] = knnsearch(pixelList,X,'K',1,'Distance','mahalanobis','Cov',Cov);
    [~,D] = knnsearch(pixelList,X,'K',1);
    if (isempty(pixelList))
        Dc(i,:) = Inf;
    else
    Dc(i,:) = D';
end
Dc(numLines+1,:) = 5*upperHeight;

end