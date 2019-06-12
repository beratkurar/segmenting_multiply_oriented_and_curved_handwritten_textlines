function [lines] = CompactTextLines(handwriting, L_lines)
    line_indices = unique(L_lines(handwriting)); 
    line_indices=setdiff(line_indices,0);
    sz = size(L_lines); lines = false(sz(1),sz(2));
    for i=1:length(line_indices)
        line = L_lines==line_indices(i);
        lines = lines | cutline(handwriting,line,sz);
    end
end


function new_line =cutline(handwriting,line,sz)
    intersection = handwriting&line;
    [L,~] = bwlabel(intersection);
    s=regionprops(L,'BoundingBox');
    bb=[s.BoundingBox];
    idx = 1:size(bb,2);

    % rect = [x y width height]
    X = bb(mod(idx,4) == 1);   
    Y = bb(mod(idx,4) == 2);   
    Width = bb(mod(idx,4) == 3);   
    Height = bb(mod(idx,4) == 0);

    maxHeight = max(Height);
    intersection = imdilate(intersection,ones(maxHeight,maxHeight*2));
    
    min_col = max(round(min(X))-1,1);
    max_col = min(round(max(X+Width)),sz(2));
    min_row = max(round(min(Y))-1,1);
    max_row = min(round(max(Y+Height)),sz(1));
    mask = line*0;
    mask(min_row:max_row,min_col:max_col) = true;
    
    new_line = line&intersection;
end
