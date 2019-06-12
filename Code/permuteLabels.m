function [newLines, newLinesNum] = permuteLabels(Lines)
    Lines = uint16(Lines);
    uniqueLabels = unique(Lines);
    uniqueLabels(uniqueLabels == 0) = [];
    p = randperm(length(uniqueLabels));
    LUT = zeros(1,65536,'uint16');
    newLinesNum = length(uniqueLabels);
    for i = 1:newLinesNum
        LUT(uniqueLabels(i)+1) = p(i);
    end
    newLines = double(intlut(Lines, LUT));
end
