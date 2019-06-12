function  [P, RArea, GTArea, GTMask] =  evalLD_SaintGallOrParzival(GT_filename, Result, bin, isSaintGall)

if(isSaintGall)
    [GTMask, GTLinesNum] = parseGTfileSG(GT_filename);
else
    [GTMask, GTLinesNum] = parseGTfileParzival(GT_filename, Result);
end

[Result,RLinesNum] =  RelabelLines(Result);

intersect = zeros(RLinesNum, GTLinesNum);

LF = Result(:);
GmaskF = GTMask(:);
bin = bin & (GTMask > 0);
imF = bin(:);

RArea = zeros(1,RLinesNum);
GTArea = zeros(1,GTLinesNum);

for i=1:length(LF)
    if (imF(i) ~= 0)
        if (LF(i) && GmaskF(i))
            intersect(LF(i), GmaskF(i)) = intersect(LF(i), GmaskF(i)) + 1;
        end
        if (LF(i))
            RArea(LF(i))=RArea(LF(i))+1;
        end
        if (GmaskF(i))
            GTArea(GmaskF(i))=GTArea(GmaskF(i))+1;
        end
    end
end

P = intersect';


end %function

function [GTMask, GTLinesNum] = parseGTfileSG(GT_filename)

fid = fopen(GT_filename);
if(fid == -1) % error to open the file
    fprintf('ERROR: Unable to open the file %s \n', GT_filename);
    return;
end

% skip first three lines
fgetl(fid);fgetl(fid);
% extract the dimentions of the image
l = fgetl(fid);
k = strfind(l, 'viewBox=');
dim = sscanf(l(k:end), 'viewBox="%d%d%d%d');
width = dim(3);
height = dim(4);
GTLinesNum = 0;
while ~feof(fid)
    GTLinesNum = GTLinesNum  + 1;
    line{GTLinesNum} = fgetl(fid);
end

% the last line is </svg>; remove it
line{GTLinesNum} = [];
GTLinesNum = GTLinesNum - 1;

GTMask = zeros(height, width);
col_min = width; col_max = 1;

for i=1:GTLinesNum
    ind = find(line{i} == 'M');
    coord = sscanf(line{i}(ind:end), 'M %f%f');
    ind = find(line{i} =='L');
    pointsNum = length(ind);
    poly_x = zeros(1, pointsNum+1); poly_y = zeros(1, pointsNum+1);
    poly_x(1) = coord(1); poly_y(1) = coord(2);
    
    for j = 1: pointsNum
        coord_next = sscanf(line{i}(ind(j):end), 'L %f%f');
        poly_x(j+1) = coord_next(1); poly_y(j+1) = coord_next(2);
    end % for j
    
    mask = poly2mask(poly_x, poly_y, height, width);
    GTMask(mask) = i;
    [~, col_ind] = find(mask);
    
    if(min(col_ind) < col_min)
        col_min = min(col_ind);
    end
    if(max(col_ind) > col_max)
        col_max = max(col_ind);
    end
end % for i
end

function [GTMask, GTLinesNum] = parseGTfileParzival(GT_filename,result)

load(GT_filename);

[height, width] = size(result);

GTLinesNum = 0;
seams_num = length(seams);

GTMask = zeros(height, width);
%col_min = width; col_max = 1;
im_mask = zeros(height, width);

for i = 1 : seams_num-1
    if(seams{i}.y(1) < seams{i+1}.y(1) ) % the same column
        % coord of two consequtive line define the coord of
        % bounding polygon of the line; put the coordinate of two lines in
        % clockwise order
        poly_x = [seams{i}.x ; seams{i+1}.x(end:-1:1)];
        poly_y = [seams{i}.y ; seams{i+1}.y(end:-1:1)];
        mask = poly2mask(poly_x, poly_y, height, width);
        GTLinesNum =  GTLinesNum + 1;
        GTMask(mask) = GTLinesNum;
        im_mask = im_mask | mask;
    end
end    
end

function [Result,RLinesNum] =  RelabelLines(Result)
    Labels = unique(Result);
    Labels(1) = [];
    temp = Result;

    for i=1:length(Labels)
        temp(Result == Labels(i)) = i;
    end
    Result = temp;
    RLinesNum = length(Labels);
end
