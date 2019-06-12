function [ fitting ] = approximateUsingPiecewiseLinearPCA( L,num, marked, ths )

 res = regionprops(L,'PixelList');
 numOfKnots = 20;
 fitting = zeros(num,numOfKnots-1);
 
 %h= figure; imshow(L); title(num2str(ths)); hold on; drawnow;

for i=1:num
    if (ismember(i,marked))
        fitting(i,:) = 0;
        continue;
    end 
    X = res(i,1).PixelList;
    try
        [COEFF] = princomp(X);

        pca = COEFF(:,1);
        theta = atan(pca(2)/pca(1));
        R = [cos(-theta) -sin(-theta); sin(-theta), cos(-theta)];
        X_Rot = R*X';
    catch
        fitting(i,:) = Inf;
        continue;
    end
    
    x = X_Rot(1,:);
    y = X_Rot(2,:);
    
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
       
       % For display
       %R_inv = [cos(theta) -sin(theta); sin(theta), cos(theta)];  
       %temp = R_inv*[x_;y_hat];
       %plot(temp(1,:),temp(2,:),'LineWidth',2); drawnow;
       
       fitting(i,j) = norm(y_hat - y_,1)./length(x_);
    end
end
fitting = max(fitting,[],2);
end
