function [baseline_points,baseline_indices] = baseline_extractor(I)
    format shortG
    s=regionprops(I,'Extrema');
    left_bottom=round(s.Extrema(7,:));
    right_bottom=round(s.Extrema(4,:));
    [~,width]=size(I);
    C=cumsum(I,1);
    [~,y]=max(C,[],1);
    x=(1:width);
    out=excludedata(x',y','domain',[left_bottom(1) right_bottom(1)]);
    try
        options = fitoptions('poly2', 'Normalize', 'on', 'Robust', 'Bisquare','Exclude',out);
        fit1 = fit(x',y','poly2',options);
    catch
        options = fitoptions('poly1', 'Normalize', 'on', 'Robust', 'Bisquare','Exclude',out);
        fit1 = fit(x',y','poly1',options);
    end
    
    y_est=feval(fit1,x');
    x_sel=x(left_bottom(1): right_bottom(1)-1)';
    y_sel=round(y_est(left_bottom(1): right_bottom(1)-1));
    [x_last,y_last]=reducem(x_sel,y_sel);
    baseline_points=[x_last,y_last];
    
    
    %baseline_indices=sub2ind(size(I),y_last,x_last);
    baseline_indices=[];

end