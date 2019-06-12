function [ fitting ] = approximateUsingPiecewiseLinear( L,num, marked, ths )

 res = regionprops(L,'PixelList');
 numOfKnots = 20;
 fitting = zeros(num,numOfKnots-1);
 
%   figure; imshow(L); hold on;

for i=1:num
    if (ismember(i,marked))
        fitting(i,:) = 0;
        continue;
    end
    pixelList = res(i,1).PixelList;
    x = pixelList(:,1);
    y = pixelList(:,2);
    % For speed up, we first try to fit a straight line, if the results are
    % really poor. We don't continue.
    p = polyfit(x,y,1);
    y_hat = polyval(p,x);
    fit = norm(y_hat - y,1)/length(x);
    if (fit > ths)
        fitting(i,:) = fit;
        continue;
    end
    try
        slm = slmengine(x,y,'degree',1,'knots',numOfKnots,'plot','off');
    catch
        fprintf('problem in CC %d\n',i);
        continue;
    end
    for j=1:numOfKnots-1
       x_endP = slm.knots(j:j+1);
       y_endP = slm.coef(j:j+1);
       p = polyfit(x_endP,y_endP,1);
       
       indices = find(x >= x_endP(1) & x <= x_endP(2));
       x_ = x(indices);
       y_ = y(indices);
       y_hat = polyval(p,x_);
       
%        plot(x_,y_hat,'LineWidth',5);
       
       fitting(i,j) = norm(y_hat - y_,1)./length(x_);
    end
end
fitting = max(fitting,[],2);
end
