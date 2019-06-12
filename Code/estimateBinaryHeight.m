function  [lower,upper] =  estimateBinaryHeight(bin,thsLow,thsHigh,Margins)
    cleanBin = clearMargins(bin,Margins);
    [L,~] = bwlabel(cleanBin);
    s = regionprops(L,'BoundingBox');
    bb=[s.BoundingBox];
    idx = 1:size(bb,2);
    Height = bb(mod(idx,4) == 0);
    robustHeight = Height;
    robustHeight(Height < thsLow) = [];
    robustHeight(robustHeight > thsHigh) = [];
    mu = mean(robustHeight);
    sigma = std(robustHeight);
    lower = (mu)/2;
    upper = (mu+sigma/2)/2;
end

function res = clearMargins(bin,Margins)
    if (Margins == 0)
        res = bin;
    else
        [L, ~] = bwlabel(bin);
        [row, col] = size(bin);
        centralRow=floor(row*Margins);  
        centralCol=floor(col*Margins);
        Mask = false(row,col);
        Mask(centralRow:end-centralRow,centralCol:end-centralCol)=true;
        res = imreconstruct(Mask,L>0); 
    end
end

