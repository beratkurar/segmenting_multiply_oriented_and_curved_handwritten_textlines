function [polygon_labels] = postProcessByThreshedBoundPolygon(result)
[rows,cols]=size(result);
labels=unique(result);
polygon_labels=zeros(rows,cols);
    for label=2:(length(labels))
        selected_label=labels(label);
        temp=(result==selected_label);
        [y, x]=find(temp);
        k=boundary(x,y,0.5);
        mask=poly2mask(x(k),y(k),rows,cols);
        polygon_labels(mask==1)=selected_label;
    end
end
