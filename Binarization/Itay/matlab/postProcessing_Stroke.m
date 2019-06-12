%
% Author: Itay Bar-Yosef
%
% Date:  30/5/2010
%postProcessing_Stroke
%
% Input: mask - binary image to evaluate run-length histogram
%
% Output: b - Binary output image filtered (removal of small blobs)


function b=postProcessing_Stroke(mask)

[l,num]=bwlabel(mask);
[dimX,dimY]=size(mask);
s=regionprops(l,'Area','BoundingBox');
area=[s.Area];
%calculate run-length histogram
[h,h1,horSW,verSW]=sw_Length(mask);

[k,strRadius]=max(h+h1);

thsArea=strRadius*strRadius;

idx=find(area>=thsArea);

b=ismember(l,idx);
